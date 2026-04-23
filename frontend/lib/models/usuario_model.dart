// Isabela

// 📌 CLASSE = "molde" de um objeto
// Aqui estamos dizendo: todo usuário do sistema TEM esses dados
class Usuario {
  // 🔹 ATRIBUTOS = características do objeto
  String nome;
  String email;
  String senha; // ⚠️ usada só para criar no Auth (NÃO vai pro Firestore)
  String cpf;
  String telefone;
  String tipo; // investidor ou empreendedor

  // 🔹 CONSTRUTOR = função que cria o objeto na memória
  // "required" = obrigatório passar esse valor ao criar o usuário
  Usuario({
    required this.nome,
    required this.email,
    required this.senha,
    required this.cpf,
    required this.telefone,
    required this.tipo,
  });

  // 🔹 MÉTODO = função dentro da classe
  // Converte o objeto em um MAPA (formato que o Firebase entende)
  Map<String, dynamic> paraMapa() {
    return {
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
      'tipo': tipo,

      // salva a data do cadastro
      'dataCadastro': DateTime.now().toIso8601String(),
    };
  }
}
