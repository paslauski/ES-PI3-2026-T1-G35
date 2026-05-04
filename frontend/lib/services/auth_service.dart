// Isabela

// 📌 SERVICE = classe responsável por falar com o Firebase
// Versão SIMPLIFICADA (fluxo direto, mais fácil de entender)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario_model.dart';

class AuthService {
  // 🔹 Conexões com Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔹 CADASTRO
  Future<void> cadastrarNovoUsuario(Usuario usuario) async {
    try {
      print("Criando usuário no Firebase Auth...");

      // 1. cria usuário (email + senha)
      UserCredential credencial = await _auth.createUserWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha,
      );

      print("Salvando dados no Firestore...");

      // 2. pega o ID único do usuário
      String uid = credencial.user!.uid;

      // 3. salva perfil no banco
      await _db.collection('usuarios').doc(uid).set(usuario.paraMapa());

      print("Cadastro finalizado!");
    } catch (e) {
      // 🔴 versão simples: mostra erro direto
      throw Exception("Erro no cadastro: $e");
    }
  }

  // 🔹 LOGIN
  Future<void> login(String email, String senha) async {
    try {
      print("Fazendo login...");

      await _auth.signInWithEmailAndPassword(email: email, password: senha);

      print("Login realizado!");
    } catch (e) {
      throw Exception("Erro no login: $e");
    }
  }

  // 🔹 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 🔹 pega usuário atual (se estiver logado)
  User? get usuarioAtual => _auth.currentUser;
  // 🔹 RECUPERAR SENHA
  Future<void> recuperarSenha(String email) async {
    try {
      print("Enviando email de recuperação...");

      await _auth.sendPasswordResetEmail(email: email);

      print("Email enviado!");
    } catch (e) {
      throw Exception("Erro ao enviar email: $e");
    }
  }
}
