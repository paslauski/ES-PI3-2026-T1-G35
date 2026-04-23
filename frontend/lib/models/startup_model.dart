// Modelo de dados da Startup
// Define a estrutura de uma startup vinda do Firestore

class Startup {
  final String id;
  final String nome;
  final String descricao;
  final String estagio;
  final String setor;
  final String status;
  final String capital;

  Startup({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.estagio,
    required this.setor,
    required this.status,
    required this.capital,
  });

  // Converte documento do Firestore para objeto Startup
  factory Startup.fromFirestore(Map<String, dynamic> data, String id) {
    return Startup(
      id: id,
      nome: data['nome'] ?? '',
      descricao: data['descricao'] ?? '',
      estagio: data['estagio'] ?? '',
      setor: data['setor'] ?? '',
      status: data['status'] ?? '',
      capital: data['capital'] ?? '',
    );
  }
}