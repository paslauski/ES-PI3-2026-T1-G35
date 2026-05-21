// Mateus

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

  // campos necessários para a tela detalhada
  final String sumarioExecutivo;
  final String totalTokens;
  final double precoToken;
  final List<Socio> socios;
  final List<String> perguntasRespostas;

  // 🎬 URL do vídeo de apresentação (Firebase Storage)
  final String videoUrl;

  Startup({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.estagio,
    required this.setor,
    required this.status,
    required this.capital,
    this.sumarioExecutivo = '',
    this.totalTokens = '',
    this.precoToken = 0.0,
    this.socios = const [],
    this.perguntasRespostas = const [],
    this.videoUrl = '',
  });

  factory Startup.fromFirestore(Map<String, dynamic> data, String id) {
    // Converte lista de sócios vinda do Firestore — trata tanto array quanto map
    List<Socio> socios = [];
    if (data['socios'] != null) {
      try {
        socios = (data['socios'] as List)
            .map((s) => Socio.fromMap(Map<String, dynamic>.from(s)))
            .toList();
      } catch (_) {
        final map = Map<String, dynamic>.from(data['socios']);
        socios = map.values
            .map((s) => Socio.fromMap(Map<String, dynamic>.from(s)))
            .toList();
      }
    }

    // Lê array de maps com campos 'pergunta' e 'resposta'
    List<String> prs = [];
    if (data['perguntas_respostas'] != null) {
      for (final item in data['perguntas_respostas']) {
        final map = Map<String, dynamic>.from(item);
        if (map['pergunta'] != null) prs.add(map['pergunta'].toString());
        if (map['resposta'] != null) prs.add(map['resposta'].toString());
      }
    }

    return Startup(
      id: id,
      nome: data['nome'] ?? '',
      descricao: data['descricao'] ?? '',
      estagio: data['estagio'] ?? '',
      setor: data['setor'] ?? '',
      status: data['status'] ?? '',
      capital: data['capital'] ?? '',
      sumarioExecutivo: data['sumario_executivo'] ?? '',
      totalTokens: data['total_tokens']?.toString() ?? '',
      precoToken: (data['preco_token'] as num?)?.toDouble() ?? 0.0,
      socios: socios,
      perguntasRespostas: prs,
      // 🎬 lê a URL do vídeo — campo 'videoUrl' no Firestore
      videoUrl: data['videoUrl'] ?? '',
    );
  }
}

// Classe separada para representar cada sócio
class Socio {
  final String nome;
  final String cargo;
  final String percentual;

  Socio({required this.nome, required this.cargo, required this.percentual});

  factory Socio.fromMap(Map<String, dynamic> data) {
    return Socio(
      nome: data['nome'] ?? '',
      cargo: data['cargo'] ?? '',
      percentual: data['percentual'] ?? '',
    );
  }
}