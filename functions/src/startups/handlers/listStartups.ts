//isabela
// ARQUIVO: functions/src/startups/handlers/listStartups.ts
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db } from "../shared/firebase";

// Esse robô devolve a lista de startups para o Flutter mostrar na tela
    export const listStartups = onCall(async (request) => {
    
    // BARREIRA DE SEGURANÇA: Só quem fez login pode ver as startups!
    if (!request.auth) {
        throw new HttpsError(
        "unauthenticated", 
        "Apenas usuários cadastrados podem ver a lista de startups."
        );
    }

    try {
        // Vai na coleção "startups" do banco e pega TUDO
        const snapshot = await db.collection("startups").get();
        
        // Cria uma lista vazia para guardar os resultados
        const listaDeStartups: any[] = [];

        // Para cada documento que o banco achou, coloca na nossa lista
        snapshot.forEach((doc) => {
        listaDeStartups.push({
            id: doc.id, // O ID que o Google gera
            ...doc.data() // Os dados (nome, descricao, etc)
        });
        });

        // Devolve o pacote pronto pro Flutter!
        return { startups: listaDeStartups };

    } catch (error) {
        console.error("Erro ao buscar startups:", error);
        throw new HttpsError("internal", "Erro interno ao buscar as startups.");
    }
});
