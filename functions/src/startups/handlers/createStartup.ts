// isabela
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db } from "../shared/firebase";
import { normalizeString } from "../shared/validation";

// { cors: true } resolve o erro de bloqueio do navegador (CORS)
export const createStartup = onCall({ cors: true }, async (request) => { 
  // BARREIRA DE SEGURANÇA 1: BLOQUEIO DE ANÓNIMOS
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Apenas usuários logados podem cadastrar startups!"
    );
  }

  // Pegamos os dados que o Flutter enviou
  const data = request.data;
  const uidEmpreendedor = request.auth.uid; // ID seguro de quem está logado

  // VALIDAÇÃO DOS DADOS (Usando o nosso validation.ts)
  const nome = normalizeString(data.nome);
  const descricao = normalizeString(data.descricao);

  // BARREIRA DE SEGURANÇA 2: VALIDAÇÃO DE CAMPOS
  if (!nome || !descricao) {
    throw new HttpsError(
      "invalid-argument",
      "O nome e a descrição da startup são obrigatórios."
    );
  }

  try {
    // GRAVAÇÃO NO BANCO (Firestore)
    const startupRef = await db.collection("startups").add({
      nome: nome,
      descricao: descricao,
      idEmpreendedor: uidEmpreendedor,
      dataCriacao: new Date().toISOString(),
      status: "analise"
    });

    return {
      id: startupRef.id,
      mensagem: "Startup cadastrada com sucesso via Backend Seguro!"
    };

  } catch (error) {
    console.error("Erro ao salvar:", error);
    throw new HttpsError("internal", "Erro ao salvar no banco de dados.");
  }
});