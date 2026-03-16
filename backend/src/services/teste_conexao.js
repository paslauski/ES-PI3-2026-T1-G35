//isabela

import { config } from 'dotenv';
import { resolve } from 'path';
import { db } from './firebaseConfig.js';
import { collection, getDocs } from "firebase/firestore";
// Isso vai mostrar TODAS as chaves que o dotenv conseguiu carregar
console.log("Chaves carregadas:", Object.keys(process.env).filter(key => key.includes('FIREBASE')));

// onde você está agora no terminal
const rootPath = resolve(process.cwd(), '.env');
console.log("buscando arquivo .env em:", rootPath);
console.log("teste puro:", process.env.TESTE_PURO);
// carrega o aqv da raiz no terminal
config({ path: rootPath });

async function validarFirebase() {
  console.log("Iniciando teste...");
  
  const projectId = process.env.REACT_APP_FIREBASE_PROJECT_ID;
  console.log("Projeto ID lido:", projectId || "❌ NÃO LIDO");

  if (!projectId) {
    console.log("PARA: O Node não viu o .env. Verifique se o aqrv ta na raiz (fora das pastas back e front)");
    return;
  }
//tentar acessar a coleção
  try {
    const querySnapshot = await getDocs(collection(db, "startups"));
    console.log("✅ CONECTADO! Startups encontradas:", querySnapshot.size);
  } catch (error) {
    console.error("❌ Erro de conexão:", error.message);
  }
}

validarFirebase();