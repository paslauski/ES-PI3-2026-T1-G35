//Isabela
//fazer a comunicação (a ponte) entre o nosso aplicativo e o banco de dados

// cd frontend
// flutter pub add firebase_core
// flutter pub add cloud_firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart';

class AuthService {
  // INSTÂNCIA BD
  //var chamada _db q guarda a connexao direta com o Firebase
  // o '_' (underline) antes do nome significa que ela é PRIVADA (só este arquivo pode mexer nela)
  // final= não apaga e não substitui
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // MÉTODO ASSÍNCRONO ( ação de cadastrar)
  // 'Future<void>' significa q vai rolar mas não retorna
  // 'async' avisa ao flutter q usa net
  Future<void> cadastrarNovoUsuario(Usuario usuario) async {
    // BLOCO TRY/CATCH -rede segurança
    // o 'try' tenta executar o cod e se a net cair, o app não pifa, vai fechar(catch)
    try {
      print("🚀 Começando o cadastro do ${usuario.nome}...");

      //'await': manda o app pausar nesta linha e ESPERAR o Google responder antes de continuar
      //'_db.collection('usuarios')': procura a coleção 'usuarios'
      //'.add()': cria um doc novo com um ID aleatorio gerado pelo Google
      // 'usuario.paraMapa()': transforma a classe Dart num pacote que o Google entende
      await _db.collection('usuarios').add(usuario.paraMapa());

      // await funciona
      print("✅ Usuário salvo com sucesso no Google!");
    } catch (e) {
      // se a net falhar ou o Firebase bloquear o acesso, o erro é capturado na var 'e'.
      print("❌ Erro ao salvar: $e");
    }
  }
}
