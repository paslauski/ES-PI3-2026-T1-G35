// isabela

// service = classe responsável por falar com o firebase
// versão simplificada, com fluxo direto e mais fácil de entender.
//
// esse arquivo não é uma tela.
// ele não mostra botão, campo, appbar nem nada visual.
//
// a função dele é cuidar da autenticação e do acesso ao firebase.
//
// responsabilidade desse service:
// - cadastrar usuário no firebase auth;
// - salvar os dados extras do usuário no firestore;
// - fazer login;
// - fazer logout;
// - pegar o usuário atual;
// - enviar e-mail de recuperação de senha.
//
// por que criar um service?
// para não colocar código de firebase direto dentro das telas.
//
// exemplo:
// a tela de cadastro só chama:
// _authService.cadastrarNovoUsuario(usuario)
//
// a tela de login só chama:
// _authService.login(email, senha)
//
// assim fica mais organizado.
//
// analogia:
// as telas são o balcão de atendimento.
// o authservice é o funcionário que entra no sistema de verdade.
// o usuário conversa com a tela,
// e a tela pede para o service resolver no firebase.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario_model.dart';

// cloud_firestore:
// pacote usado para acessar o firestore,
// que é o banco de dados do firebase.
//
// firebase_auth:
// pacote usado para autenticação,
// ou seja, criar conta, login, logout e recuperação de senha.
//
// usuario_model.dart:
// arquivo que tem a classe usuario,
// ou seja, o molde dos dados do usuário.
//
// separando bem:
//
// firebase auth:
// guarda a conta de login.
// normalmente: e-mail, senha criptografada, uid.
//
// firestore:
// guarda os dados extras do perfil.
// exemplo: nome, cpf, telefone, tipo, data de cadastro.
//
// usuario model:
// representa os dados do usuário dentro do app.

class AuthService {
  // conexões com firebase
  //
  // firebaseauth.instance:
  // pega a instância principal do firebase auth.
  //
  // é por meio desse objeto que fazemos:
  // - criar conta;
  // - login;
  // - logout;
  // - recuperar senha;
  // - pegar usuário atual.
  //
  // underline no começo:
  // _auth
  //
  // em dart, underline deixa privado dentro do arquivo.
  //
  // ou seja:
  // outras classes não acessam _auth diretamente.
  // elas usam os métodos públicos do authservice.
  //
  // analogia:
  // _auth é o acesso interno ao cofre de login do firebase.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // firestore.instance:
  // pega a instância principal do cloud firestore.
  //
  // firestore é o banco de dados onde salvamos os dados extras do usuário.
  //
  // exemplo:
  // nome, cpf, telefone, tipo.
  //
  // por que não salvar tudo no firebase auth?
  // porque o auth é focado em autenticação.
  // ele não é feito para guardar todos os dados de perfil do usuário.
  //
  // então usamos:
  // firebase auth para login/senha;
  // firestore para perfil/dados extras.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // cadastro
  //
  // esse método cadastra um novo usuário.
  //
  // parâmetro:
  // usuario
  //
  // usuario é um objeto da classe Usuario.
  // ele vem preenchido pela tela de cadastro.
  //
  // exemplo de dados dentro dele:
  // - nome;
  // - email;
  // - senha;
  // - cpf;
  // - telefone;
  // - tipo.
  //
  // future<void>:
  // quer dizer que é uma função assíncrona.
  // ela pode demorar porque depende de internet/firebase.
  //
  // void:
  // quer dizer que ela não retorna um valor final.
  //
  // se der certo:
  // termina sem retornar nada.
  //
  // se der erro:
  // lança uma exception.
  //
  // quem chama esse método?
  // cadastro_page.dart chama quando o usuário aperta "cadastrar".
  Future<void> cadastrarNovoUsuario(Usuario usuario) async {
    try {
      // print:
      // escreve uma mensagem no console/debug.
      //
      // isso ajuda enquanto estamos programando,
      // porque dá para ver em que etapa o código chegou.
      //
      // em app profissional, normalmente troca por logs melhores
      // ou remove prints antes da entrega final.
      print("Criando usuário no Firebase Auth...");

      // 1. cria usuário com e-mail e senha.
      //
      // createuserwithemailandpassword:
      // método do firebase auth que cria uma conta de login.
      //
      // ele precisa de:
      // - email;
      // - password.
      //
      // usuario.email:
      // vem do objeto usuario criado na tela de cadastro.
      //
      // usuario.senha:
      // também vem da tela de cadastro.
      //
      // importante:
      // a senha vai para o firebase auth.
      // ela não deve ser salva no firestore pelo app.
      //
      // o firebase auth cuida da senha de forma segura.
      //
      // await:
      // espera o firebase terminar de criar o usuário.
      //
      // retorno:
      // retorna um usercredential.
      //
      // usercredential:
      // é um objeto com informações da autenticação criada.
      // dentro dele existe o user, e dentro do user existe o uid.
      //
      // analogia:
      // é como criar o crachá do usuário no sistema.
      UserCredential credencial = await _auth.createUserWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha,
      );

      print("Salvando dados no Firestore...");

      // 2. pega o id único do usuário.
      //
      // credencial.user:
      // é o usuário criado pelo firebase auth.
      //
      // uid:
      // é o identificador único desse usuário.
      //
      // cada usuário tem um uid diferente.
      //
      // credencial.user!.uid:
      // o ponto de exclamação diz:
      // "confia, user não está nulo".
      //
      // cuidado:
      // se user fosse nulo, o app quebraria.
      // nesse fluxo, normalmente ele vem preenchido quando o cadastro dá certo.
      //
      // por que usar uid como id do documento?
      // porque assim o documento do firestore fica ligado exatamente
      // ao usuário autenticado.
      //
      // exemplo:
      // auth uid = abc123
      // firestore usuarios/abc123
      //
      // isso facilita buscar o perfil do usuário depois.
      String uid = credencial.user!.uid;

      // 3. salva perfil no banco.
      //
      // _db.collection('usuarios'):
      // acessa a coleção usuarios no firestore.
      //
      // coleção:
      // é como uma pasta/tabela de documentos.
      //
      // doc(uid):
      // escolhe o documento com o id do usuário.
      //
      // set(...):
      // grava os dados dentro desse documento.
      //
      // usuario.paraMapa():
      // transforma o objeto usuario em map.
      //
      // por que precisa virar map?
      // porque o firestore salva dados no formato chave:valor.
      //
      // exemplo:
      // {
      //   "nome": "isabela",
      //   "email": "isa@email.com",
      //   "cpf": "...",
      //   "telefone": "...",
      //   "tipo": "investidor"
      // }
      //
      // detalhe importante:
      // o ideal é que paraMapa() não salve a senha no firestore.
      // a senha fica somente no firebase auth.
      await _db.collection('usuarios').doc(uid).set(usuario.paraMapa());

      print("Cadastro finalizado!");
    } catch (e) {
      // versão simples: mostra erro direto.
      //
      // catch:
      // pega qualquer erro que aconteceu dentro do try.
      //
      // e:
      // é o erro capturado.
      //
      // throw exception:
      // joga o erro para quem chamou esse método.
      //
      // quem chamou?
      // normalmente a cadastro_page.
      //
      // aí a tela recebe esse erro e mostra uma snackbar.
      //
      // observação:
      // essa é uma versão simples.
      // em uma versão mais bonita, daria para tratar firebaseauthexception
      // e traduzir erros como:
      // - email-already-in-use;
      // - weak-password;
      // - invalid-email.
      throw Exception("Erro no cadastro: $e");
    }
  }

  // login
  //
  // esse método faz login de um usuário existente.
  //
  // parâmetros:
  //
  // email:
  // e-mail digitado na tela de login.
  //
  // senha:
  // senha digitada na tela de login.
  //
  // future<void>:
  // é assíncrono e não retorna valor final.
  //
  // se der certo:
  // o firebase deixa o usuário autenticado.
  //
  // se der erro:
  // lança exception.
  //
  // quem chama?
  // login_page.dart chama quando o usuário clica em "entrar".
  Future<void> login(String email, String senha) async {
    try {
      print("Fazendo login...");

      // signInWithEmailAndPassword:
      // método do firebase auth que tenta autenticar um usuário.
      //
      // ele confere:
      // - se o e-mail existe;
      // - se a senha bate com aquele e-mail.
      //
      // se estiver certo:
      // o usuário fica logado no firebase auth.
      //
      // se estiver errado:
      // o firebase lança erro.
      //
      // await:
      // espera a resposta do firebase.
      await _auth.signInWithEmailAndPassword(email: email, password: senha);

      print("Login realizado!");
    } catch (e) {
      // se der erro no login, joga o erro para a tela.
      //
      // a login_page pode pegar esse erro no catch
      // e traduzir para uma mensagem melhor.
      throw Exception("Erro no login: $e");
    }
  }

  // logout
  //
  // esse método sai da conta atual.
  //
  // future<void>:
  // é assíncrono, porque o firebase precisa limpar a sessão.
  //
  // signout:
  // remove o usuário atual da sessão do app.
  //
  // depois disso:
  // _auth.currentUser normalmente vira null.
  //
  // quem chama?
  // alguma tela com botão de sair/logout.
  Future<void> logout() async {
    await _auth.signOut();
  }

  // pega usuário atual, se estiver logado.
  //
  // isso aqui é um getter.
  //
  // getter:
  // parece uma variável, mas por trás retorna uma informação.
  //
  // user?:
  // significa que pode retornar um user ou null.
  //
  // retorna user:
  // se tiver alguém logado.
  //
  // retorna null:
  // se ninguém estiver logado.
  //
  // exemplo de uso:
  //
  // final usuario = _authService.usuarioAtual;
  //
  // if (usuario != null) {
  //   print(usuario.uid);
  // }
  //
  // para que serve?
  // para saber quem está logado agora.
  User? get usuarioAtual => _auth.currentUser;

  // recuperar senha
  //
  // esse método envia um e-mail de recuperação de senha.
  //
  // parâmetro:
  // email:
  // e-mail digitado na tela "esqueci minha senha".
  //
  // quem chama?
  // esqueci_senha_page.dart chama esse método.
  //
  // importante:
  // esse método não troca a senha dentro do app.
  // ele só pede para o firebase enviar um link para o e-mail.
  //
  // o usuário clica no link e define uma nova senha.
  Future<void> recuperarSenha(String email) async {
    try {
      print("Enviando email de recuperação...");

      // sendpasswordresetemail:
      // método do firebase auth que envia o e-mail de redefinição de senha.
      //
      // se o e-mail estiver cadastrado e a configuração do firebase estiver ok,
      // o firebase envia o link de recuperação.
      //
      // await:
      // espera o pedido terminar.
      await _auth.sendPasswordResetEmail(email: email);

      print("Email enviado!");
    } catch (e) {
      // se der erro ao enviar, lança exception para a tela tratar.
      //
      // possíveis erros:
      // - e-mail inválido;
      // - problema de internet;
      // - configuração do auth incompleta;
      // - domínio/configuração de template no firebase.
      throw Exception("Erro ao enviar email: $e");
    }
  }
}
