// Isabela

// 📌 SERVICE = camada de lógica que conversa com o Firebase
// (separa a lógica do backend da tela)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario_model.dart';

class AuthService {
  // 🔹 INSTÂNCIAS (conexões com Firebase)
  final FirebaseAuth _auth = FirebaseAuth.instance; // Auth (login/senha)
  final FirebaseFirestore _db = FirebaseFirestore.instance; // Banco

  // 🔹 MÉTODO PRINCIPAL: cadastrar usuário completo
  Future<void> cadastrarNovoUsuario(Usuario usuario) async {
    try {
      print("🔐 Criando conta no Firebase Auth...");

      // 📌 PASSO 1: cria conta no "cofre do Google"
      UserCredential credencial = await _auth.createUserWithEmailAndPassword(
        email: usuario.email.trim(),
        password: usuario.senha.trim(),
      );

      print("📦 Salvando perfil no Firestore...");

      // 📌 PASSO 2: salva dados do perfil no banco
      if (credencial.user != null) {
        String uid = credencial.user!.uid;

        // usamos o UID como ID do documento (boa prática)
        await _db.collection('usuarios').doc(uid).set(usuario.paraMapa());
      }

      print("✅ Cadastro completo!");
    }
    // 🔴 ERROS ESPECÍFICOS DO FIREBASE AUTH
    on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Senha muito fraca (mínimo 6 caracteres).');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Este e-mail já está cadastrado.');
      } else if (e.code == 'invalid-email') {
        throw Exception('E-mail inválido.');
      } else {
        throw Exception('Erro de autenticação: ${e.message}');
      }
    }
    // 🔴 ERROS GERAIS
    catch (e) {
      throw Exception('Erro geral: $e');
    }
  }
}
