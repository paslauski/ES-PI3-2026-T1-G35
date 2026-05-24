// ============================================================================
// Projeto: MesclaInvest
// Desenvolvedores: Isabela + Mateus
// Arquivo principal responsável por inicializar o Firebase e carregar o app.
// ============================================================================

/*
===============================================================================
COMANDOS ÚTEIS PARA EXECUTAR O PROJETO
===============================================================================

Atualizar e limpar dependências:
flutter clean
flutter pub get

Rodar no navegador:
flutter run -d chrome

===============================================================================
FIREBASE
===============================================================================

Login no Firebase:
firebase login

Instalar Firebase CLI:
npm install -g firebase-tools

Configurar FlutterFire:
dart pub global run flutterfire_cli:flutterfire configure

Selecionar o projeto do PI e confirmar com Enter.

===============================================================================
FIREBASE APP IDS
===============================================================================

Platform  Firebase App Id
web       1:696645311566:web:262642b6ec4224f562771f
android   1:696645311566:android:990b5a04d47eacf262771f
ios       1:696645311566:ios:393bb380c9e23bbf62771f
macos     1:696645311566:ios:393bb380c9e23bbf62771f
windows   1:696645311566:web:8ff7261d8c8dd63362771f

===============================================================================
DEPENDÊNCIAS IMPORTANTES
===============================================================================

Atualizar dependências:
flutter pub get

Limpar cache do projeto:
flutter clean

Pacote utilizado para integração com Cloud Functions:
flutter pub add cloud_functions

===============================================================================
*/

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'views/login_page.dart';
import 'views/home_page.dart';


// Função principal da aplicação.
//
// Responsável por:
// 1. Inicializar o Flutter.
// 2. Conectar o aplicativo ao Firebase.
// 3. Executar a aplicação principal.

void main() async {
  // Garante que o Flutter foi carregado corretamente antes de
  // executar operações assíncronas como Firebase.initializeApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a conexão com o Firebase utilizando as configurações
  // específicas da plataforma atual (Web, Android, Windows, etc.)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicia a aplicação principal
  runApp(const MeuAppMescla());
}


// Classe principal do aplicativo.
// Define:
// - Tema global
// - Rotas do sistema
// - Tela inicial
// - Configurações gerais da interface

class MeuAppMescla extends StatelessWidget {
  const MeuAppMescla({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Nome da aplicação
      title: 'MesclaInvest',

      // Remove a faixa de DEBUG no canto superior direito
      debugShowCheckedModeBanner: false,

      
      // Tema visual principal da aplicação
      //
      // useMaterial3:
      // Ativa o Material Design 3 para componentes mais modernos.
      
      theme: ThemeData(
        useMaterial3: true,

        // Paleta principal de cores do sistema
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFF00C897),
        ),

        // Cor padrão de fundo das telas
        scaffoldBackgroundColor: const Color(0xFFF5F5FA),

        
        // Configuração global da AppBar
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2E),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        
        // Estilo padrão dos botões elevados
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        
        // Configuração padrão dos campos de texto
        
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFE0E0E0),
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFE0E0E0),
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF6C63FF),
              width: 2,
            ),
          ),

          hintStyle: const TextStyle(
            color: Color(0xFFAAAAAA),
          ),
        ),

        
        // Estilo padrão dos cards utilizados na interface
        
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: Color(0xFFEEEEEE),
            ),
          ),
        ),
      ),

      
      // Define a rota inicial da aplicação.
      // "/" representa a tela de login.
      
      initialRoute: '/',

      
      // Rotas nomeadas do sistema.
      // Facilitam a navegação utilizando:
      // Navigator.pushNamed()
      
      
      routes: {
        // Tela inicial de login
        '/': (context) => const LoginPage(),

        // Tela principal após autenticação
        '/home': (context) => const HomePage(),
      },
    );
  }
}