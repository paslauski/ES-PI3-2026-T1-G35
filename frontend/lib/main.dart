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
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MeuAppMescla());
}

class MeuAppMescla extends StatelessWidget {
  const MeuAppMescla({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MesclaInvest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFF00C897),
          surface: const Color(0xFFF5F5FA),
          background: const Color(0xFFF5F5FA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5FA),

        // AppBar limpa e escura
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2E),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        // Botões elevados com cantos arredondados
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
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Campos de texto
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
          ),
          hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
        ),

        // Cards
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
        ),

        // Chips
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFF6C63FF),
          labelStyle: const TextStyle(fontSize: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
      },
    );
  }
}