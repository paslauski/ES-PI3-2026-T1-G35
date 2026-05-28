// Mateus - cancela ordem e devolve saldo/tokens reservados

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";

export const cancelarOrdem = onCall({ cors: true }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Não autenticado.");

  const { ordemId } = request.data;
  if (!ordemId) throw new HttpsError("invalid-argument", "ID da ordem inválido.");

  const db = getFirestore();
  const ordemRef = db.collection("ordens").doc(ordemId);
  const ordemSnap = await ordemRef.get();

  if (!ordemSnap.exists) throw new HttpsError("not-found", "Ordem não encontrada.");

  const ordem = ordemSnap.data()!;

  if (ordem.usuarioId !== uid) {
    throw new HttpsError("permission-denied", "Você não pode cancelar esta ordem.");
  }
  if (ordem.status === "concluida" || ordem.status === "cancelada") {
    throw new HttpsError("failed-precondition", "Esta ordem não pode ser cancelada.");
  }

  const usuarioRef = db.collection("usuarios").doc(uid);

  await db.runTransaction(async (tx) => {
    const usuarioSnap = await tx.get(usuarioRef);
    const saldo = Number(usuarioSnap.data()?.saldo ?? 0);

    // Devolve o saldo reservado se era ordem de compra
    if (ordem.tipo === "compra") {
      const valorReservado = ordem.quantRestante * ordem.precoToken;
      tx.update(usuarioRef, { saldo: saldo + valorReservado });
    }

    // Devolve tokens reservados se era ordem de venda
    // (tokens já ficam na carteira, só marca como cancelada)

    tx.update(ordemRef, { status: "cancelada" });
  });

  return { sucesso: true, mensagem: "Ordem cancelada com sucesso." };
});