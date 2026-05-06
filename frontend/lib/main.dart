// Isabela

/**
flutter clean
flutter pub get
flutter run -d chrome
*/

// firebase login->naos enter->//
// npm install -g firebase-tools->firebase login(ai quando der sucess)->cd frontend
// dart pub global run flutterfire_cli:flutterfire configure_>seleciona o do PI->enter_>

/*
Platform  Firebase App Id
web       1:696645311566:web:262642b6ec4224f562771f
android   1:696645311566:android:990b5a04d47eacf262771f
ios       1:696645311566:ios:393bb380c9e23bbf62771f
macos     1:696645311566:ios:393bb380c9e23bbf62771f
windows   1:696645311566:web:8ff7261d8c8dd63362771f
*/

/*
cd front -  flutter pub get - flutter clean
*/

// flutter pub add cloud_functions (novo pacote que baixamos para falar com os robôs/backend)

// IMPORTAÇÕES / DEPENDÊNCIAS DO ARQUIVO
// Aqui ficam os "pacotes" e arquivos que este main.dart precisa para funcionar.
// Analogia informal: é tipo separar os materiais antes de cozinhar.
// Antes de fazer a receita, eu preciso pegar panela, ingrediente, colher etc.

// Importa o pacote principal do Flutter para construir telas, botões, cores,
// textos, layouts e componentes visuais.
// Sem esse import, o Flutter não saberia o que é MaterialApp, ThemeData,
// Colors, StatelessWidget, BuildContext etc.
import 'package:flutter/material.dart';

// Importa o núcleo do Firebase.
// Esse pacote é obrigatório para ligar o app Flutter ao projeto Firebase.
// Ele não faz login sozinho, não salva dados sozinho, não chama function sozinho.
// Ele apenas "abre a conexão inicial" com o Firebase.
import 'package:firebase_core/firebase_core.dart';

// Importa o arquivo firebase_options.dart.
// Esse arquivo foi gerado pelo FlutterFire CLI.
// Ele guarda as configurações do projeto Firebase para cada plataforma:
// web, android, ios, windows etc.
// Analogia informal: é como se fosse a "chave de endereço" do Firebase,
// dizendo para qual projeto do Google o app deve apontar.
import 'firebase_options.dart';

// Importa a tela de login.
// Este main.dart depende da LoginPage porque a rota inicial '/' aponta para ela.
// Se esse import for removido, o Dart não vai reconhecer LoginPage().
import 'views/login_page.dart';

// FUNÇÃO PRINCIPAL DO APP
// A função main() é a porta de entrada de qualquer app Dart/Flutter.
// É a PRIMEIRA função executada quando o aplicativo inicia.
//
// async = depende de operação externa, tipo internet/Firebase
//
// Por que tem async?
// Porque inicializar o Firebase é uma operação assíncrona.
// Ou seja: pode demorar alguns milissegundos/segundos, pois depende de carregar
// configuração, ambiente, plataforma e conexão com serviços externos.
//
// O que essa função retorna?
// Ela retorna Future<void> de forma implícita por causa do async.
// "void" significa: não devolve nenhum valor útil.
// "Future" significa: termina no futuro, depois que os awaits acabarem.
//
// Analogia informal:
// É como ligar uma loja:
// 1. abrir a porta,
// 2. acender a luz,
// 3. conectar a maquininha,
// 4. só depois atender o cliente.
void main() async {
  // garante que o Flutter carregou antes de falar com o Firebase
  //
  // WidgetsFlutterBinding.ensureInitialized()
  // garante que a "base interna" do Flutter já está pronta.
  //
  // Por que isso é necessário?
  // Porque antes de chamar Firebase.initializeApp(), o Flutter precisa estar
  // preparado para usar recursos nativos da plataforma.
  //
  // Sem isso, pode dar erro porque o Firebase tenta acessar informações
  // da plataforma antes do Flutter estar completamente inicializado.
  //
  // Analogia informal:
  // Não adianta tentar ligar o Wi-Fi da loja se a energia nem foi ligada ainda.
  WidgetsFlutterBinding.ensureInitialized();

  // inicializa conexão com o projeto Firebase
  //
  // await Firebase.initializeApp(...)
  //
  // await = "espera terminar antes de continuar".
  //
  // Aqui o app está dizendo:
  // "Flutter, antes de abrir a interface, conecta no Firebase certo".
  //
  // DefaultFirebaseOptions.currentPlatform:
  // chama um método do arquivo firebase_options.dart.
  // Esse método descobre se o app está rodando na Web, Android, iOS etc.,
  // e devolve as configurações corretas daquele ambiente.
  //
  // Dependência:
  // Esta linha depende de:
  // - firebase_core
  // - firebase_options.dart
  // - projeto Firebase configurado corretamente
  //
  // O que retorna?
  // Firebase.initializeApp retorna um Future<FirebaseApp>.
  // Mas aqui não guardamos o retorno em variável porque só precisamos garantir
  // que o Firebase foi inicializado.
  //
  // Analogia informal:
  // É tipo conectar o app na "central do Google" antes de usar login,
  // banco de dados ou funções.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // runApp() entrega o widget principal para o Flutter desenhar na tela.
  //
  // const MeuAppMescla()
  // cria uma instância do widget principal do aplicativo.
  //
  // "const" significa que esse objeto pode ser criado de forma otimizada,
  // porque ele não muda internamente.
  //
  // O que runApp retorna?
  // Ele retorna void, ou seja, não devolve dado.
  // A função apenas inicia a árvore visual do Flutter.
  //
  // Analogia informal:
  // Depois de ligar a loja e conectar o sistema, agora abrimos a vitrine
  // para o usuário ver a primeira tela.
  runApp(const MeuAppMescla());
}

// CLASSE PRINCIPAL DO APLICATIVO
// StatelessWidget = estrutura fixa/base do app
//
// Classe:
// Uma classe é um molde.
// Aqui, MeuAppMescla é o molde do app inteiro.
//
// Objeto:
// Quando fazemos const MeuAppMescla(), estamos criando um objeto real
// baseado nesse molde.
//
// Por que essa classe herda de StatelessWidget?
// Porque esta estrutura principal não precisa guardar estado interno.
// Ela só define configurações gerais:
// - título do app
// - tema
// - rotas
// - tela inicial
//
// "Stateless" significa "sem estado mutável".
// Ou seja: essa classe não tem variável que muda durante o uso da tela.
//
// Analogia informal:
// Essa classe é tipo a recepção de um prédio.
// Ela não faz todo o trabalho do prédio, mas indica onde ficam as salas,
// qual é a entrada principal e qual visual geral o prédio usa.
class MeuAppMescla extends StatelessWidget {
  // CONSTRUTOR DA CLASSE
  //
  // const MeuAppMescla({super.key});
  //
  // Construtor é o método especial que cria o objeto.
  //
  // super.key:
  // envia a chave para a classe pai StatelessWidget.
  // O Flutter usa "key" para identificar widgets na árvore de interface.
  //
  // Na prática, para iniciante:
  // essa linha permite criar MeuAppMescla de forma correta e otimizada.
  const MeuAppMescla({super.key});

  // @override significa que estamos sobrescrevendo um método da classe pai.
  //
  // Todo StatelessWidget é obrigado a implementar o método build().
  // O build() é o método que descreve o que aparece na tela.
  //
  // Analogia informal:
  // O build é o "desenhar a tela".
  // Ele responde: "quando esse widget aparecer, o que eu mostro?"
  @override
  Widget build(BuildContext context) {
    // build retorna um Widget.
    //
    // Widget é qualquer peça visual ou estrutural do Flutter:
    // tela, botão, texto, coluna, rota, tema etc.
    //
    // BuildContext context:
    // é uma referência da posição desse widget dentro da árvore do Flutter.
    //
    // Analogia informal:
    // O context é tipo o endereço dessa peça dentro do app.
    // Com ele, o Flutter sabe onde esse widget está e consegue acessar tema,
    // navegação, tamanho de tela e outras informações.
    return MaterialApp(
      // MaterialApp é o "container principal" de um app Flutter com Material Design.
      //
      // Ele configura:
      // - nome do app
      // - tema visual
      // - rotas
      // - navegação
      // - tela inicial
      //
      // Analogia informal:
      // É como o "prédio inteiro" do aplicativo.
      // Dentro dele ficam as salas/telas.

      // title é o nome interno do aplicativo.
      // Em algumas plataformas, pode aparecer no gerenciador de tarefas,
      // navegador ou sistema.
      title: 'MesclaInvest',

      // Remove aquela faixa de debug no canto da tela.
      //
      // debugShowCheckedModeBanner: false
      //
      // Isso não muda a lógica do app.
      // Só deixa a interface mais limpa para apresentação.
      debugShowCheckedModeBanner: false,

      // Define o tema visual geral do app.
      //
      // ThemeData é um objeto que guarda configurações visuais.
      // Aqui definimos cor principal e ativamos Material 3.
      theme: ThemeData(
        // primarySwatch define uma paleta principal baseada em azul.
        // Essa cor pode influenciar botões, AppBar e elementos padrão.
        primarySwatch: Colors.blue,

        // useMaterial3 ativa o Material Design 3,
        // que é uma versão mais recente do padrão visual do Google.
        useMaterial3: true,
      ),

      // initialRoute define qual rota abre primeiro.
      //
      // Aqui a rota inicial é '/'.
      // No mapa de routes abaixo, '/' está ligada à LoginPage().
      //
      // Ou seja:
      // quando o app abre, ele procura a rota '/'
      // e encontra a tela LoginPage.
      //
      // Analogia informal:
      // É tipo falar:
      // "quando a pessoa entrar no prédio, manda primeiro para a recepção".
      initialRoute: '/', // define qual é a tela inicial pelo nome
      // routes é um Map.
      //
      // Map é uma estrutura chave:valor.
      //
      // Neste caso:
      // chave = nome da rota
      // valor = função que constrói a tela
      //
      // Exemplo:
      // '/' aponta para LoginPage()
      //
      // Isso permite navegar pelo app usando nomes de rotas,
      // como Navigator.pushNamed(context, '/').
      //
      // Por que usar rota nomeada?
      // Porque facilita navegação, principalmente logout, login e redirecionamentos.
      routes: {
        // '/' é a rota principal/inicial.
        //
        // (context) => const LoginPage()
        //
        // Isso é uma função anônima.
        // Ela recebe o context e retorna um widget LoginPage.
        //
        // Essa função só é executada quando o Flutter precisa abrir essa rota.
        //
        // Dependência:
        // Essa linha depende da classe LoginPage existir no arquivo:
        // views/login_page.dart
        //
        // rota usada pelo logout para voltar ao login
        '/': (context) => const LoginPage(),
      },
    );
  }
}
