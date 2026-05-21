// Mateus - Backend: lógica de compra de tokens
// Roda no servidor Firebase, não no Flutter

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db } from "../shared/firebase";

export const comprarTokens = onCall({ cors: true }, async (request) => {

  // BARREIRA 1: só usuário logado pode comprar
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Você precisa estar logado para comprar tokens."
    );
  }

  const { startupId, quantidade } = request.data;
  const uid = request.auth.uid;

  // BARREIRA 2: valida os dados recebidos do Flutter
  if (!startupId || typeof startupId !== "string") {
    throw new HttpsError("invalid-argument", "ID da startup inválido.");
  }
  if (!quantidade || typeof quantidade !== "number" || quantidade <= 0) {
    throw new HttpsError("invalid-argument", "Quantidade inválida.");
  }

  // Busca dados da startup e do usuário ao mesmo tempo
  const [startupDoc, userDoc] = await Promise.all([
    db.collection("startups").doc(startupId).get(),
    db.collection("usuarios").doc(uid).get(),
  ]);

  // BARREIRA 3: startup existe?
  if (!startupDoc.exists) {
    throw new HttpsError("not-found", "Startup não encontrada.");
  }

  const startup = startupDoc.data()!;
  const usuario = userDoc.data();

  // BARREIRA 4: usuário existe no banco?
  if (!usuario) {
    throw new HttpsError("not-found", "Usuário não encontrado no banco.");
  }

  const precoToken = startup.preco_token as number;
  const saldoAtual = (usuario.saldo ?? 0) as number;
  const totalGasto = quantidade * precoToken;

  // BARREIRA 5: saldo suficiente?
  if (saldoAtual < totalGasto) {
    throw new HttpsError(
      "failed-precondition",
      `Saldo insuficiente. Você tem R$ ${saldoAtual.toFixed(2)} mas a compra custa R$ ${totalGasto.toFixed(2)}.`
    );
  }

  const novoSaldo = saldoAtual - totalGasto;

  // Executa as duas operações ao mesmo tempo:
  // 1. Desconta o saldo do usuário
  // 2. Registra a transação na coleção 'transacoes'
  await Promise.all([
    db.collection("usuarios").doc(uid).update({ saldo: novoSaldo }),
    db.collection("transacoes").add({
      uid_usuario: uid,
      startup_id: startupId,
      startup_nome: startup.nome ?? "",
      tipo: "compra",
      quantidade_tokens: quantidade,
      preco_token: precoToken,
      total_gasto: totalGasto,
      saldo_antes: saldoAtual,
      saldo_depois: novoSaldo,
      data: new Date().toISOString(),
    }),
  ]);

  // Retorna pro Flutter com sucesso
  return {
    sucesso: true,
    mensagem: `Compra realizada! Você comprou ${quantidade} tokens por R$ ${totalGasto.toFixed(2)}.`,
    novoSaldo: novoSaldo,
  };
});