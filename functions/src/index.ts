//isabela
// ARQUIVO: functions/src/index.ts
import { setGlobalOptions } from "firebase-functions/v2";

// Define que as funções vão rodar no servidor de São Paulo 
setGlobalOptions({ region: "southamerica-east1" });

// A lista de todos os nossos robôs disponíveis:
export { createStartup } from "./startups/handlers/createStartup";
export { listStartups } from "./startups/handlers/listStartups";