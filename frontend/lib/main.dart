//isabela
////firebase login->naos enter->//
//npm install -g firebase-tools->firebase login(ai quando der sucess)->cd frontend
//dart pub global run flutterfire_cli:flutterfire configure_>seleciona o do PI->enter_>
/*Platform  Firebase App Id
web       1:696645311566:web:262642b6ec4224f562771f
android   1:696645311566:android:990b5a04d47eacf262771f
ios       1:696645311566:ios:393bb380c9e23bbf62771f
macos     1:696645311566:ios:393bb380c9e23bbf62771f
windows   1:696645311566:web:8ff7261d8c8dd63362771f
*/

/* cd front -  flutter pub get - flutter clean*/
// flutter pub add cloud_functions (novo pacote que baixamos para falar com os robôs/backend)

import 'package:flutter/material.dart'; // ferramentas visuais do google (tela, botão, cores)
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/cadastro_page.dart';

//'async'=depende da net p/ firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //'await':espera terminar a tela e conecta no projeto do Google
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MeuAppMescla());
}

//'Stateless' pq essa estrutura base do app não muda de cor ou forma,
//ela é apenas um contêiner que gerencia e carrega as outras telas já prontas
class MeuAppMescla extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // usa o roteamento, temas e a infraestrutura visual
    return MaterialApp(
      title: 'MesclaInvest',
      //tira aquela faixa vermelha de "DEBUG"
      debugShowCheckedModeBanner: false,

      //tema
      theme: ThemeData(
        primarySwatch: Colors.blue, // Cor principal
        useMaterial3: true, // ativa o design system mais recente do Google
      ),
      home: CadastroPage(),
    );
  }
}
