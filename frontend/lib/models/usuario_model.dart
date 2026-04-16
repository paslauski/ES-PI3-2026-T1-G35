// Isabela
/*flutter pub add firebase_auth */
// ISSO É UMA CLASSE: é o "molde" que define o que todo usuário tem que ter
// no Flutter/Dart, uma classe é um molde que dita quais informações um objeto deve ter o firebase não sabe o que é um "Usuário", então nós ensinamos isso para ele aqui
// Isabela
// ISSO É UMA CLASSE: é o "molde" que define o que todo usuário tem que ter
// no Flutter/Dart, uma classe é um molde que dita quais informações um objeto deve ter.
class Usuario {
  // ATRIBUTOS - caracteristicas
  String nome;
  String email;

  // 🚨 ATENÇÃO AQUI: A senha ainda existe no molde para pegarmos da tela,
  // mas ELA NÃO VAI PARA O BANCO DE DADOS (Firestore).
  String senha;
  String tipo; // Pode ser 'investidor' ou 'empreendedor'-seleção?

  // CONSTRUTOR - cria o objeto real na memoria
  Usuario({
    required this.nome, //required é obrigatorio
    required this.email,
    required this.senha,
    required this.tipo,
  });

  // MÉTODO - (DE CONVERSÃO p/ Firebase Firestore)
  // pega os atributos e transforma em um pacote "chave: valor"
  // é uma função que transforma os dados acima em um "Mapa"
  Map<String, dynamic> paraMapa() {
    return {
      // nome da var no bd - nome pego pelo required
      'nome': nome,
      'email': email,
      'tipo': tipo,

      // 🚨 MUDANÇA EXTREMAMENTE IMPORTANTE PARA O PROFESSOR:
      // Removemos a linha "'senha': senha," daqui!
      // O banco de dados (Firestore) só guarda o PERFIL do usuário.
      // Quem guarda a senha agora é o cofre do Google (Firebase Auth).

      // Pega a hora exata de agora e convertemos para texto (.toString)-registro botão
      'dataCadastro': DateTime.now().toString(),
    };
  }
}
