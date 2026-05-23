import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue } from "firebase-admin/firestore";

export const comprarTokens = onCall(async (request) => {
  const uid = request.auth?.uid;

  if (!uid) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado.");
  }

  const { startupId, quantidade, precoToken } = request.data;

  if (!startupId || !quantidade || !precoToken) {
    throw new HttpsError("invalid-argument", "Dados incompletos.");
  }

  if (quantidade <= 0 || precoToken <= 0) {
    throw new HttpsError("invalid-argument", "Quantidade ou preço inválido.");
  }

  const db = getFirestore();

  const usuarioRef = db.collection("usuarios").doc(uid);
  const startupRef = db.collection("startups").doc(startupId);
  const transacaoRef = db.collection("transacoes").doc();

  await db.runTransaction(async (transaction) => {
    const usuarioSnap = await transaction.get(usuarioRef);
    const startupSnap = await transaction.get(startupRef);

    if (!usuarioSnap.exists) {
      throw new HttpsError("not-found", "Usuário não encontrado.");
    }

    if (!startupSnap.exists) {
      throw new HttpsError("not-found", "Startup não encontrada.");
    }

    const usuario = usuarioSnap.data()!;
    const startup = startupSnap.data()!;

    const saldoAtual = Number(usuario.saldo ?? 0);
    const tokensDisponiveis = Number(
      startup.tokens_disponiveis ?? startup.total_tokens ?? 0
    );

    const valorTotal = Number(quantidade) * Number(precoToken);

    if (saldoAtual < valorTotal) {
      throw new HttpsError("failed-precondition", "Saldo insuficiente.");
    }

    if (tokensDisponiveis < quantidade) {
      throw new HttpsError("failed-precondition", "Tokens insuficientes.");
    }

    transaction.update(usuarioRef, {
      saldo: saldoAtual - valorTotal,
    });

    transaction.update(startupRef, {
      tokens_disponiveis: tokensDisponiveis - quantidade,
    });

    transaction.set(transacaoRef, {
      usuarioId: uid,
      startupId,
      quantidade,
      precoToken,
      valorTotal,
      tipo: "compra",
      createdAt: FieldValue.serverTimestamp(),
    });
  });

  return {
    sucesso: true,
    mensagem: "Tokens comprados com sucesso.",
  };
});