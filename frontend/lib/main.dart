// Isabela

/**
Comandos úteis para rodar o projeto:

flutter clean
flutter pub get
flutter run -d chrome
*/

// Login no Firebase:
// firebase login

// Instalar Firebase CLI:
// npm install -g firebase-tools

// Configurar FlutterFire:
// dart pub global run flutterfire_cli:flutterfire configure
// Seleciona o projeto do PI e confirma com Enter.

/*
Platform  Firebase App Id
web       1:696645311566:web:262642b6ec4224f562771f
android   1:696645311566:android:990b5a04d47eacf262771f
ios       1:696645311566:ios:393bb380c9e23bbf62771f
macos     1:696645311566:ios:393bb380c9e23bbf62771f
windows   1:696645311566:web:8ff7261d8c8dd63362771f
*/

// Para atualizar dependências do Flutter:
// cd frontend
// flutter pub get
// flutter clean

// Pacote usado para falar com Cloud Functions, se necessário:
// flutter pub add cloud_functions

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'views/login_page.dart';
import 'views/home_page.dart';

// async = depende de operação externa, tipo internet/Firebase
void main() async {
  // garante que o Flutter carregou antes de falar com o Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // inicializa conexão com o projeto Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // inicia o aplicativo
  runApp(const MeuAppMescla());
}

// StatelessWidget = estrutura fixa/base do app
class MeuAppMescla extends StatelessWidget {
  const MeuAppMescla({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // nome do app
      title: 'MesclaInvest',

      // remove a faixa vermelha de debug no canto da tela
      debugShowCheckedModeBanner: false,

      // tema visual principal do app
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),

      // define qual tela abre primeiro
      // neste caso, abre a tela de login
      initialRoute: '/',

      // rotas nomeadas do aplicativo
      // facilitam navegar entre telas usando Navigator.pushNamed
      routes: {
        // rota inicial: tela de login
        '/': (context) => const LoginPage(),

        // rota da home após login
        '/home': (context) => const HomePage(),
      },
    );
  }
}
