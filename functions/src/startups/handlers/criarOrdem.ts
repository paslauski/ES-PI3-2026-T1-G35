// Mateus - Backend: criar ordem de compra ou venda no balcão P2P
// Lógica completa: valida → cria ordem → tenta match automático
// CORRIGIDO: carteiras acessadas por ID direto dentro das transactions
// CORRIGIDO: tokens de venda são reservados (descontados) ao entrar na fila

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue } from "firebase-admin/firestore";

function carteiraId(usuarioId: string, startupId: string): string {
  return `${usuarioId}_${startupId}`;
}

export const criarOrdem = onCall({ cors: true }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Você precisa estar logado.");

  const { startupId, nomeStartup, tipo, quantidade, precoToken } = request.data;

  if (!startupId || !tipo || !quantidade || !precoToken) {
    throw new HttpsError("invalid-argument", "Dados incompletos.");
  }
  if (tipo !== "compra" && tipo !== "venda") {
    throw new HttpsError("invalid-argument", "Tipo deve ser 'compra' ou 'venda'.");
  }
  if (quantidade <= 0 || precoToken <= 0) {
    throw new HttpsError("invalid-argument", "Quantidade e preço devem ser positivos.");
  }

  const db = getFirestore();
  const usuarioRef = db.collection("usuarios").doc(uid);
  const usuarioSnap = await usuarioRef.get();

  if (!usuarioSnap.exists) {
    throw new HttpsError("not-found", "Usuário não encontrado.");
  }

  const usuario = usuarioSnap.data()!;
  const valorTotal = quantidade * precoToken;

  // ── VALIDAÇÃO DE COMPRA: tem saldo? ──────────────────────────
  if (tipo === "compra") {
    const saldo = Number(usuario.saldo ?? 0);
    if (saldo < valorTotal) {
      throw new HttpsError(
        "failed-precondition",
        `Saldo insuficiente. Você tem R$ ${saldo.toFixed(2)} mas precisa de R$ ${valorTotal.toFixed(2)}.`
      );
    }
  }

  // ── VALIDAÇÃO DE VENDA: tem tokens? ──────────────────────────
  if (tipo === "venda") {
    const cartRef = db.collection("carteiras").doc(carteiraId(uid, startupId));
    const cartSnap = await cartRef.get();

    if (!cartSnap.exists) {
      throw new HttpsError("failed-precondition", "Você não possui tokens desta startup.");
    }

    const tokensDisponiveis = Number(cartSnap.data()?.quantidade ?? 0);

    if (tokensDisponiveis < quantidade) {
      throw new HttpsError(
        "failed-precondition",
        `Tokens insuficientes. Você tem ${tokensDisponiveis} tokens mas quer vender ${quantidade}.`
      );
    }
  }

  // ── TENTA MATCH AUTOMÁTICO ────────────────────────────────────
  let ordemContraria = null;

  if (tipo === "compra") {
    const vendasSnap = await db
      .collection("ordens")
      .where("startupId", "==", startupId)
      .where("tipo", "==", "venda")
      .where("status", "in", ["aberta", "parcial"])
      .where("precoToken", "<=", precoToken)
      .orderBy("precoToken", "asc")
      .orderBy("criadoEm", "asc")
      .limit(1)
      .get();

    if (!vendasSnap.empty) ordemContraria = vendasSnap.docs[0];

  } else {
    const comprasSnap = await db
      .collection("ordens")
      .where("startupId", "==", startupId)
      .where("tipo", "==", "compra")
      .where("status", "in", ["aberta", "parcial"])
      .where("precoToken", ">=", precoToken)
      .orderBy("precoToken", "desc")
      .orderBy("criadoEm", "asc")
      .limit(1)
      .get();

    if (!comprasSnap.empty) ordemContraria = comprasSnap.docs[0];
  }

  // ── EXECUTAR MATCH ─────────────────────────────────────────────
  if (ordemContraria) {
    const dadosContraria = ordemContraria.data();
    const qtdMatch = Math.min(quantidade, dadosContraria.quantRestante);
    const precoMatch = dadosContraria.precoToken;
    const valorMatch = qtdMatch * precoMatch;

    const compradorId = tipo === "compra" ? uid : dadosContraria.usuarioId;
    const vendedorId  = tipo === "venda"  ? uid : dadosContraria.usuarioId;

    await db.runTransaction(async (tx) => {
      const compradorRef = db.collection("usuarios").doc(compradorId);
      const vendedorRef  = db.collection("usuarios").doc(vendedorId);

      const cartCompRef = db.collection("carteiras").doc(carteiraId(compradorId, startupId));
      const cartVendRef = db.collection("carteiras").doc(carteiraId(vendedorId, startupId));

      const compradorSnap = await tx.get(compradorRef);
      const vendedorSnap  = await tx.get(vendedorRef);
      const cartCompSnap  = await tx.get(cartCompRef);
      const cartVendSnap  = await tx.get(cartVendRef);

      const saldoComprador = Number(compradorSnap.data()?.saldo ?? 0);
      const saldoVendedor  = Number(vendedorSnap.data()?.saldo ?? 0);

      // Transfere saldo
      tx.update(compradorRef, { saldo: saldoComprador - valorMatch });
      tx.update(vendedorRef,  { saldo: saldoVendedor  + valorMatch });

      // Atualiza carteira do comprador (adiciona tokens)
      if (!cartCompSnap.exists) {
        tx.set(cartCompRef, {
          usuarioId: compradorId,
          startupId,
          nomeStartup,
          quantidade: qtdMatch,
          criadoEm: FieldValue.serverTimestamp(),
        });
      } else {
        const qtdAtual = Number(cartCompSnap.data()?.quantidade ?? 0);
        tx.update(cartCompRef, { quantidade: qtdAtual + qtdMatch });
      }

      // Atualiza carteira do vendedor (tokens já foram reservados ao criar a ordem)
      // Só precisa atualizar se o vendedor é quem está criando a ordem agora (match imediato)
      if (tipo === "venda" && cartVendSnap.exists) {
        const qtdAtual = Number(cartVendSnap.data()?.quantidade ?? 0);
        tx.update(cartVendRef, { quantidade: qtdAtual - qtdMatch });
      }

      // Atualiza status da ordem contrária
      const novaQtdContraria = dadosContraria.quantRestante - qtdMatch;
      tx.update(ordemContraria!.ref, {
        quantRestante: novaQtdContraria,
        status: novaQtdContraria <= 0 ? "concluida" : "parcial",
      });

      // Registra transação
      tx.set(db.collection("transacoes").doc(), {
        compradorId, vendedorId, startupId, nomeStartup,
        quantidade: qtdMatch, precoToken: precoMatch,
        valorTotal: valorMatch, tipo: "balcao",
        criadoEm: FieldValue.serverTimestamp(),
      });

      // Atualiza cotação do dia
      const hoje = new Date().toISOString().split("T")[0];
      const cotacaoRef = db.collection("cotacoes").doc(startupId);
      const cotacaoSnap = await tx.get(cotacaoRef);

      if (!cotacaoSnap.exists || cotacaoSnap.data()?.dataUltimaTrade !== hoje) {
        tx.set(cotacaoRef, {
          startupId, ultimoPreco: precoMatch,
          maiorPrecoHoje: precoMatch, menorPrecoHoje: precoMatch,
          volumeHoje: qtdMatch, dataUltimaTrade: hoje,
        });
      } else {
        const d = cotacaoSnap.data()!;
        tx.update(cotacaoRef, {
          ultimoPreco: precoMatch,
          maiorPrecoHoje: Math.max(d.maiorPrecoHoje, precoMatch),
          menorPrecoHoje: Math.min(d.menorPrecoHoje, precoMatch),
          volumeHoje: Number(d.volumeHoje ?? 0) + qtdMatch,
        });
      }
    });

    if (qtdMatch >= quantidade) {
      return { sucesso: true, match: true, mensagem: "Negociação executada com sucesso!" };
    }

    const qtdRestante = quantidade - qtdMatch;
    await db.collection("ordens").add({
      usuarioId: uid, startupId, nomeStartup, tipo,
      quantidade, quantRestante: qtdRestante,
      precoToken, status: "parcial",
      criadoEm: FieldValue.serverTimestamp(),
    });

    return {
      sucesso: true, match: true,
      mensagem: `Match parcial! ${qtdMatch} tokens negociados. ${qtdRestante} aguardando na fila.`,
    };
  }

  // ── SEM MATCH: vai para a fila ────────────────────────────────
  if (tipo === "compra") {
    const saldoAtual = Number(usuario.saldo ?? 0);
    await usuarioRef.update({ saldo: saldoAtual - valorTotal });
  }

  // CORRIGIDO: reserva (desconta) tokens ao criar ordem de venda na fila
  if (tipo === "venda") {
    const cartRef = db.collection("carteiras").doc(carteiraId(uid, startupId));
    const cartSnap = await cartRef.get();
    const qtdAtual = Number(cartSnap.data()?.quantidade ?? 0);
    await cartRef.update({ quantidade: qtdAtual - quantidade });
  }

  await db.collection("ordens").add({
    usuarioId: uid, startupId, nomeStartup, tipo,
    quantidade, quantRestante: quantidade,
    precoToken, status: "aberta",
    criadoEm: FieldValue.serverTimestamp(),
  });

  return {
    sucesso: true, match: false,
    mensagem: tipo === "compra"
      ? "Ordem de compra criada! Aguardando vendedor."
      : "Ordem de venda criada! Aguardando comprador.",
  };
});