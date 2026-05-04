//isabela
// ARQUIVO: functions/src/startups/shared/firebase.ts
// Esse arquivo (Admin) para os nossos robôs mexerem no banco

import { getAuth } from "firebase-admin/auth";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

// Verifica se o Firebase já está ligado. Se não estiver (length === 0), ele liga.
if (getApps().length === 0) {
    initializeApp();
}

// Exportamos as chaves mestras de Autenticação e Banco de Dados para os outros robôs poderem usar
export const auth = getAuth();
export const db = getFirestore();