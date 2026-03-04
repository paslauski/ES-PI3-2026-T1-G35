//api porta de entrada p programa - servidor pra subir as rotas (funções e partes do sistema)
import express from 'express';
import { config } from 'dotenv';
import cors from 'cors';  //só aceita requisições da porta estabelecida (restringe)
config();//acessa as variaveis do .env
const PORT = process.env.BACKEND_PORT;

const app = express();

app.use(express.json()); //vai aceitar um body como json pra acessar API (comunicação entre back e front)
app.use(cors({
    origin:'http://localhost:64140' //colocar porta do flutter
}))

app.listen(PORT, () => {
    console.log('Rodando')
});

