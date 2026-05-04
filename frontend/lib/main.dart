// Isabela
/**
flutter clean
flutter pub get
flutter run -d chrome
*/
// firebase login->naos enter->//
// npm install -g firebase-tools->firebase login(ai quando der sucess)->cd frontend
// dart pub global run flutterfire_cli:flutterfire configure_>seleciona o do PI->enter_>

/*Platform  Firebase App Id
web       1:696645311566:web:262642b6ec4224f562771f
android   1:696645311566:android:990b5a04d47eacf262771f
ios       1:696645311566:ios:393bb380c9e23bbf62771f
macos     1:696645311566:ios:393bb380c9e23bbf62771f
windows   1:696645311566:web:8ff7261d8c8dd63362771f
*/

/* cd front -  flutter pub get - flutter clean*/
// flutter pub add cloud_functions (novo pacote que baixamos para falar com os robôs/backend)

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/login_page.dart';

// async = depende de operação externa, tipo internet/Firebase
void main() async {
  // garante que o Flutter carregou antes de falar com o Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // inicializa conexão com o projeto Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MeuAppMescla());
}

// StatelessWidget = estrutura fixa/base do app
class MeuAppMescla extends StatelessWidget {
  const MeuAppMescla({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MesclaInvest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: '/',           // define qual é a tela inicial pelo nome
      routes: {
        '/': (context) => const LoginPage(), // rota usada pelo logout para voltar ao login
  },
);
}
}
