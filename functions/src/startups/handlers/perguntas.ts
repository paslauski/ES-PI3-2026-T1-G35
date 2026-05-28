// Isabela - Handler de Perguntas e Respostas
// ARQUIVO: functions/src/startups/handlers/perguntas.ts

import { onRequest } from "firebase-functions/v2/https";
import { db } from "../shared/firebase";
import { FieldValue } from "firebase-admin/firestore";

/*
Envia uma pergunta para uma startup.

Body esperado:
{
  startupId: string,
  usuarioId: string,
  nomeUsuario: string,
  texto: string,
  tipo: "publica" | "privada"   // privada só aparece para investidores
}

Regra:
- tipo "privada" exige que o usuário tenha tokens da startup (carteira)
- tipo "publica" qualquer usuário autenticado pode enviar
*/
export const enviarPergunta = onRequest(
  { region: "southamerica-east1", cors: true },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ erro: "Método não permitido." });
      return;
    }

    const { startupId, usuarioId, nomeUsuario, texto, tipo } = req.body;

    // Validações básicas
    if (!startupId || !usuarioId || !texto || !tipo) {
      res.status(400).json({ erro: "Campos obrigatórios ausentes." });
      return;
    }

    if (tipo !== "publica" && tipo !== "privada") {
      res.status(400).json({ erro: "Tipo deve ser 'publica' ou 'privada'." });
      return;
    }

    if (texto.trim().length < 5) {
      res.status(400).json({ erro: "Pergunta muito curta." });
      return;
    }

    // Se for privada, verifica se o usuário é investidor da startup
    if (tipo === "privada") {
      const carteiraId = `${usuarioId}_${startupId}`;
      const carteiraSnap = await db
        .collection("carteiras")
        .doc(carteiraId)
        .get();

      if (!carteiraSnap.exists) {
        res.status(403).json({
          erro: "Apenas investidores podem enviar perguntas privadas.",
        });
        return;
      }
    }

    // Salva a pergunta
    await db.collection("perguntas").add({
      startupId,
      usuarioId,
      nomeUsuario: nomeUsuario || "Usuário",
      texto: texto.trim(),
      tipo,                         // "publica" ou "privada"
      respondida: false,
      resposta: "",
      criadoEm: FieldValue.serverTimestamp(),
    });

    res.status(201).json({ sucesso: true });
  }
);
