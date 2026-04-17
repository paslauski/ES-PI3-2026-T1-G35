//isabela
// ARQUIVO: functions/src/startups/handlers/createStartup.ts
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db } from "../shared/firebase";
import { normalizeString } from "../shared/validation";

// Esse é o robô que o Flutter vai chamar
export const createStartup = onCall(async (request) => {
  // BARREIRA DE SEGURANÇA 1: BLOQUEIO DE ANÓNIMOS
  // Se o request.auth não existir, significa que a pessoa não fez login no App
    if (!request.auth) {
        throw new HttpsError(
        "unauthenticated", 
        "Apenas usuários logados podem cadastrar startups!"
    );
    }

  // Pegamos os dados que o Flutter enviou
    const data = request.data;
    const uidEmpreendedor = request.auth.uid; // ID seguro de quem está logado

    // VALIDAÇAO DOS DADOS (Usando o nosso validation.ts)
    const nome = normalizeString(data.nome);
    const descricao = normalizeString(data.descricao);

    //BARREIRA DE SEGURANÇA 2: VALIDAÇÃO DE CAMPOS
    if (!nome || !descricao) {
        throw new HttpsError(
        "invalid-argument",
        "O nome e a descrição da startup são obrigatórios e não podem estar vazios."
        );
    }

    try {
        // GRAVAÇÃO NO BANCO (Firestore)  Admin
        const startupRef = await db.collection("startups").add({
        nome: nome,
        descricao: descricao,
        idEmpreendedor: uidEmpreendedor,
        dataCriacao: new Date().toISOString(),
        status: "analise" // Toda startup nova começa em análise
        });

        return {
        id: startupRef.id,
        mensagem: "Startup cadastrada com sucesso via Backend Seguro!"
        };

    } catch (error) {
        throw new HttpsError("internal", "Erro ao salvar no banco de dados.");
    }
});