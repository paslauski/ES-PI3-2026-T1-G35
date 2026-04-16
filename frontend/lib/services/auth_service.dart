//Isabela
//fazer a comunicação (a ponte) entre o nosso aplicativo e o banco de dados

// cd frontend
// flutter pub add firebase_core
// flutter pub add cloud_firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario_model.dart';

class AuthService {
  // INSTÂNCIAS (Duas conexões agora)
  // _auth = O Cofre de Senhas do Google (Authentication)
  // _db = O Banco de Dados de Perfil (Firestore)
  // o '_' (underline) significa que são PRIVADAS (só este arquivo pode mexer nela)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // MÉTODO ASSÍNCRONO (ação de cadastrar com segurança dupla)
  Future<void> cadastrarNovoUsuario(Usuario usuario) async {
    // BLOCO TRY/CATCH - rede de segurança
    try {
      print("criando a chave de segurança para ${usuario.nome}...");

      // PASSO 1: CRIA A CONTA NO COFRE DO GOOGLE (Authentication)
      // O Google vai pegar o email e a senha, criptografar e criar a conta real.
      // Ele nos devolve uma "Credencial" que tem um ID único e seguro (UID).
      UserCredential credencial = await _auth.createUserWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha,
      );

      // PASSO 2: SALVA O PERFIL NO BANCO DE DADOS (Firestore)
      // Se a credencial deu certo (não é nula)...
      if (credencial.user != null) {
        // Pegamos o ID seguro que o Google gerou para essa pessoa:
        String uidSeguro = credencial.user!.uid;

        // Ao invés de '.add()' (que cria um ID aleatório), usamos '.doc(uidSeguro).set()'
        // Isso amarra a pasta do banco de dados exatamente à conta de login da pessoa!
        await _db.collection('usuarios').doc(uidSeguro).set(usuario.paraMapa());

        print("✅ Usuário Autenticado e Perfil salvo com sucesso!");
      }
    } on FirebaseAuthException catch (e) {
      // TRATAMENTO DE ERROS ESPECÍFICOS DO GOOGLE AUTH
      // O 'on FirebaseAuthException' pega os erros de segurança que o Google joga.
      if (e.code == 'weak-password') {
        throw Exception(
          'A senha fornecida é muito fraca (mínimo 6 caracteres).',
        );
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Este e-mail já está cadastrado no sistema.');
      } else {
        throw Exception('Erro de autenticação: ${e.message}');
      }
    } catch (e) {
      // Erros gerais (ex: falta de internet)
      throw Exception('Erro geral ao cadastrar: $e');
    }
  }
}
