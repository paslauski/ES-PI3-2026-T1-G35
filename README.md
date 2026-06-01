# ES-PI3-2026-T1-G35

## MesclaInvest

Aplicativo mobile desenvolvido para o Projeto Integrador III do curso de Engenharia de Software da PUC-Campinas.

O MesclaInvest simula uma plataforma de investimento em startups vinculadas ao ecossistema Mescla. A proposta é permitir que usuários cadastrados consultem startups, acompanhem informações institucionais, visualizem dados societários e realizem negociações simuladas de tokens dentro do aplicativo.

O projeto tem finalidade exclusivamente acadêmica. Não há uso de dinheiro real, emissão real de tokens, integração com blockchain pública ou operação financeira verdadeira.

---

## 1. Sobre o projeto

O sistema foi desenvolvido para representar, em ambiente controlado, uma experiência parecida com uma plataforma de investimentos. O usuário consegue navegar pelo catálogo de startups, acessar detalhes de cada projeto, consultar dados de capital, tokens, sócios, perguntas e respostas, além de simular compra e venda de tokens.

A negociação pode acontecer de duas formas:

- compra direta pela página da startup;
- criação de ordens de compra e venda pelo balcão de tokens.

O balcão simula um ambiente de ofertas, onde usuários podem registrar ordens de compra ou venda. As transações geradas alimentam o histórico de negociações, a carteira do usuário e o dashboard de valorização.

---

## 2. Funcionalidades implementadas

### Autenticação

- cadastro de usuário;
- login com e-mail e senha;
- recuperação de senha;
- controle de acesso sem navegação anônima.

### Catálogo de startups

- listagem de startups cadastradas;
- filtros por estágio;
- visualização de nome, descrição, setor, status e capital;
- tela detalhada da startup;
- exibição de sumário executivo;
- estrutura societária;
- perguntas e respostas públicas;
- dados simulados de tokens.

### Compra direta de tokens

- compra de tokens diretamente pela página da startup;
- atualização do saldo fictício do usuário;
- atualização dos tokens disponíveis;
- registro da transação;
- atualização da carteira do investidor.

### Balcão de tokens

- criação de ordens de compra;
- criação de ordens de venda;
- cancelamento de ordens abertas;
- integração com Cloud Functions;
- uso da coleção de ordens no Firestore;
- simulação de fluxo de negociação entre usuários.

### Carteira

- exibição do saldo disponível;
- listagem dos tokens comprados;
- quantidade de tokens por startup;
- preço médio;
- total investido;
- atualização conforme compras e vendas.

### Minhas negociações

- histórico de compras e vendas;
- exibição de startup, tipo de operação, quantidade, preço e valor total;
- filtros por tipo de negociação;
- resumo de compras, vendas e saldo líquido das operações.

### Dashboard

- acompanhamento da valorização simulada da carteira;
- filtros por período:
  - diário;
  - semanal;
  - mensal;
  - últimos 6 meses;
  - YTD;
- cálculo com base nas transações registradas;
- gráfico simples de performance do portfólio.

### Perguntas

- envio de perguntas para startups;
- armazenamento das perguntas no Firestore;
- exibição de perguntas e respostas na área da startup.

---

## 3. Tecnologias utilizadas

### Frontend

- Flutter;
- Dart;
- Firebase Core;
- Firebase Auth;
- Cloud Firestore;
- Cloud Functions.

### Backend

- Node.js;
- TypeScript;
- Firebase Cloud Functions;
- Firebase Admin SDK.

### Banco de dados

- Firebase Firestore.

### Ferramentas

- Visual Studio Code;
- Android Studio;
- Git;
- GitHub;
- Firebase CLI;
- Firebase Emulator Suite.

---

## 4. Estrutura do projeto

```text
ES-PI3-2026-T1-G35
│
├── frontend
│   ├── lib
│   │   ├── models
│   │   ├── services
│   │   ├── views
│   │   │   ├── startups
│   │   │   └── tokens
│   │   ├── firebase_options.dart
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── README.md
│
├── functions
│   ├── src
│   │   ├── index.ts
│   │   └── startups
│   │       └── handlers
│   ├── package.json
│   └── tsconfig.json
│
├── firestore.indexes.json
├── firestore.rules
├── firebase.json
└── README.md
```

---

## 5. Principais coleções do Firestore

### `usuarios`

Armazena os dados do usuário cadastrado.

Campos principais:

- nome;
- e-mail;
- CPF;
- telefone;
- tipo;
- saldo fictício;
- data de cadastro.

### `startups`

Armazena os dados das startups disponíveis no catálogo.

Campos principais:

- nome;
- descrição;
- estágio;
- setor;
- status;
- capital;
- sumário executivo;
- total de tokens;
- tokens disponíveis;
- preço do token;
- sócios;
- perguntas e respostas.

### `carteiras`

Armazena a posição atual de cada usuário em cada startup.

Campos principais:

- usuário;
- startup;
- nome da startup;
- quantidade de tokens;
- preço médio;
- total investido;
- data de atualização.

### `transacoes`

Armazena o histórico de negociações realizadas.

Campos principais:

- usuário;
- startup;
- tipo da operação;
- quantidade;
- preço do token;
- valor total;
- data da transação.

### `ordens`

Armazena as ordens de compra e venda do balcão.

Campos principais:

- usuário;
- startup;
- tipo da ordem;
- quantidade;
- quantidade restante;
- preço do token;
- status;
- data de criação.

### `perguntas`

Armazena perguntas enviadas pelos usuários para as startups.

Campos principais:

- usuário;
- startup;
- pergunta;
- resposta;
- data de envio;
- status.

---

## 6. Como rodar o frontend

Entre na pasta do frontend:

```bash
cd frontend
```

Instale as dependências:

```bash
flutter pub get
```

Limpe arquivos antigos de build:

```bash
flutter clean
```

Rode no Chrome:

```bash
flutter run -d chrome
```

---

## 7. Como rodar o backend localmente

Entre na pasta das functions:

```bash
cd functions
```

Instale as dependências:

```bash
npm install
```

Compile o TypeScript:

```bash
npm run build
```

Volte para a raiz do projeto:

```bash
cd ..
```

Rode os emuladores:

```bash
firebase emulators:start --only functions,firestore
```

Caso queira rodar apenas as functions:

```bash
firebase emulators:start --only functions
```

---

## 8. Deploy no Firebase

Antes do deploy, compile as functions:

```bash
cd functions
npm run build
cd ..
```

Deploy das Cloud Functions:

```bash
firebase deploy --only functions --project pi-3--mescla-invest
```

Deploy dos índices e regras do Firestore:

```bash
firebase deploy --only firestore --project pi-3--mescla-invest
```

Deploy completo de Firebase Functions e Firestore:

```bash
firebase deploy --only functions,firestore --project pi-3--mescla-invest
```

Observação: o deploy das Cloud Functions exige que o projeto Firebase esteja em um plano compatível com esse recurso.

---

## 9. Índices do Firestore

O projeto utiliza índices compostos para consultas da coleção `ordens`, principalmente no fluxo do balcão de tokens.

O arquivo responsável é:

```text
firestore.indexes.json
```

Para publicar os índices:

```bash
firebase deploy --only firestore:indexes --project pi-3--mescla-invest
```

---

## 10. Fluxo principal do sistema

### Compra direta

```text
Usuário acessa uma startup
↓
Escolhe comprar token
↓
Sistema valida saldo e tokens disponíveis
↓
Atualiza saldo do usuário
↓
Atualiza tokens disponíveis da startup
↓
Cria transação
↓
Atualiza carteira
```

### Balcão de tokens

```text
Usuário cria uma ordem de compra ou venda
↓
Backend registra a ordem no Firestore
↓
Sistema tenta processar a negociação
↓
Se houver correspondência, a transação é executada
↓
Carteira e saldo são atualizados
↓
Histórico de negociações é registrado
```

### Dashboard

```text
Sistema lê carteira e transações
↓
Calcula total investido
↓
Calcula valor atual simulado
↓
Calcula variação
↓
Exibe gráfico por período
```

---

## 11. Equipe

Grupo 35 — Projeto Integrador III

| Integrante | RA |
|---|---|
| Isabela Aparecida Paslauski Pinto | 25003335 |
| João Pedro Bergamin Diniz | 25007162 |
| Mateus de Souza Campos | 25009935 |
| Mateus Oliveira Rafael | 25001369 |

---

## 12. Observações finais

Este projeto é um protótipo acadêmico. As operações de investimento, tokens, saldo, valorização e transações são simuladas. O sistema não realiza pagamentos reais, não emite ativos digitais reais e não possui finalidade comercial.

O foco da implementação está na arquitetura da aplicação, integração entre Flutter, Firebase Auth, Firestore e Cloud Functions, além da modelagem de dados para simular um ambiente digital de investimento.
