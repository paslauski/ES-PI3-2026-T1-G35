// Mateus - Dashboard financeiro com gráficos
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/*
Tela responsável pelo dashboard financeiro do usuário.

Funcionalidades:
- exibir total investido e valor atual;
- gráfico de linha: performance do portfólio (simulado por mês);
- gráfico de barras verticais: distribuição por categoria/setor;
- resumo dos investimentos por startup;
- integrar Firebase Auth e Cloud Firestore.
*/

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  String _fmt(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  double _toDouble(dynamic v) =>
      double.tryParse((v ?? 0).toString()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
            title: const Text('Dashboard'), automaticallyImplyLeading: false),
        body: const Center(child: Text('Você precisa estar logado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/home', (r) => false),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('carteiras')
            .where('usuarioId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          double totalInvestido = 0;
          final Map<String, double> porStartup = {};
          // Agrupa por setor/categoria usando o nome da startup como fallback
          final Map<String, double> porCategoria = {};

          for (final doc in docs) {
            final d = doc.data() as Map<String, dynamic>;
            final nome = (d['nomeStartup'] ?? 'Startup').toString();
            final valor = _toDouble(d['totalInvestido']);
            totalInvestido += valor;
            porStartup[nome] = (porStartup[nome] ?? 0) + valor;
          }

          // Busca setor de cada startup para o gráfico por categoria
          return FutureBuilder<Map<String, double>>(
            future: _buscarPorCategoria(docs),
            builder: (context, snapCat) {
              final categorias = snapCat.data ?? {};
              // Se ainda não carregou, usa nomes das startups como categoria
              final dadosGrafico =
                  categorias.isNotEmpty ? categorias : porStartup;

              // Valor atual: usa totalInvestido como base (sem variação real
              // disponível sem preço atual — mantém consistência com a Carteira)
              final valorAtual = totalInvestido;
              final retorno = 0.0; // sem flutuação real neste momento

              // Dados simulados de performance mensal (baseados no total atual)
              final meses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai'];
              final performance = totalInvestido > 0
                  ? _gerarPerformanceSimulada(totalInvestido)
                  : [0.0, 0.0, 0.0, 0.0, 0.0];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── CARDS RESUMO ─────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _cardResumo(
                            titulo: 'Total Investido',
                            valor: _fmt(totalInvestido),
                            variacao: '+0%',
                            positivo: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _cardResumo(
                            titulo: 'Valor Atual',
                            valor: _fmt(valorAtual),
                            variacao:
                                '${retorno >= 0 ? '+' : ''}${retorno.toStringAsFixed(1)}%',
                            positivo: retorno >= 0,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── GRÁFICO DE LINHA: PERFORMANCE ────────────────
                    _cardGrafico(
                      titulo: 'Performance do Portfólio',
                      child: totalInvestido == 0
                          ? const _SemDados()
                          : _GraficoLinha(
                              meses: meses,
                              valores: performance,
                            ),
                    ),

                    const SizedBox(height: 20),

                    // ── GRÁFICO DE BARRAS: DISTRIBUIÇÃO ──────────────
                    _cardGrafico(
                      titulo: 'Distribuição por Categoria',
                      child: dadosGrafico.isEmpty
                          ? const _SemDados()
                          : _GraficoBarrasVerticais(dados: dadosGrafico),
                    ),

                    const SizedBox(height: 20),

                    // ── RESUMO DOS INVESTIMENTOS ─────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resumo dos Investimentos',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (porStartup.isEmpty)
                            const Text(
                              'Nenhum investimento ainda.',
                              style: TextStyle(color: Color(0xFF888888)),
                            )
                          else
                            ...porStartup.entries
                                .toList()
                                .asMap()
                                .entries
                                .map((e) {
                              final cores = [
                                const Color(0xFFFF9500),
                                const Color(0xFF00C897),
                                const Color(0xFF6C63FF),
                                const Color(0xFFFF4D4D),
                                const Color(0xFF1A1A2E),
                              ];
                              final cor = cores[e.key % cores.length];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: cor,
                                          shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        e.value.key,
                                        style: const TextStyle(
                                            color: Color(0xFF444444)),
                                      ),
                                    ),
                                    Text(
                                      _fmt(e.value.value),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A2E),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Dados simulados para fins acadêmicos.',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade400),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Gera 5 pontos de performance simulada crescente com base no total atual
  List<double> _gerarPerformanceSimulada(double total) {
    // Simula crescimento gradual ao longo de 5 meses
    final base = total * 0.55;
    return [
      base,
      base * 1.08,
      base * 1.14,
      base * 1.10,
      total,
    ];
  }

  // Busca o setor de cada startup na carteira para agrupar por categoria
  Future<Map<String, double>> _buscarPorCategoria(
      List<QueryDocumentSnapshot> docs) async {
    final Map<String, double> resultado = {};

    for (final doc in docs) {
      final d = doc.data() as Map<String, dynamic>;
      final startupId = (d['startupId'] ?? '').toString();
      final valor = _toDouble(d['totalInvestido']);
      if (startupId.isEmpty) continue;

      try {
        final snap = await FirebaseFirestore.instance
            .collection('startups')
            .doc(startupId)
            .get();
        if (snap.exists) {
          final data = snap.data() as Map<String, dynamic>;
          final setor =
              (data['setor'] ?? data['categoria'] ?? 'Outros').toString();
          resultado[setor] = (resultado[setor] ?? 0) + valor;
        }
      } catch (_) {}
    }

    return resultado;
  }

  Widget _cardGrafico({required String titulo, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _cardResumo({
    required String titulo,
    required String valor,
    required String variacao,
    required bool positivo,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style:
                  const TextStyle(color: Color(0xFF888888), fontSize: 12)),
          const SizedBox(height: 6),
          Text(valor,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                positivo ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color:
                    positivo ? const Color(0xFF00C897) : Colors.red,
              ),
              const SizedBox(width: 2),
              Text(
                variacao,
                style: TextStyle(
                  fontSize: 12,
                  color: positivo
                      ? const Color(0xFF00C897)
                      : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: Gráfico de Linha — Performance do Portfólio
// ─────────────────────────────────────────────────────────────────────────────

class _GraficoLinha extends StatelessWidget {
  final List<String> meses;
  final List<double> valores;

  const _GraficoLinha({required this.meses, required this.valores});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        size: const Size(double.infinity, 180),
        painter: _LinhaPainter(meses: meses, valores: valores),
      ),
    );
  }
}

class _LinhaPainter extends CustomPainter {
  final List<String> meses;
  final List<double> valores;

  _LinhaPainter({required this.meses, required this.valores});

  @override
  void paint(Canvas canvas, Size size) {
    if (valores.isEmpty) return;

    const paddingLeft = 50.0;
    const paddingBottom = 28.0;
    const paddingTop = 12.0;
    const paddingRight = 12.0;

    final drawW = size.width - paddingLeft - paddingRight;
    final drawH = size.height - paddingBottom - paddingTop;

    final maxVal = valores.reduce(max);
    final minVal = valores.reduce(min);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    // Normaliza pontos
    final points = <Offset>[];
    for (int i = 0; i < valores.length; i++) {
      final x = paddingLeft + (i / (valores.length - 1)) * drawW;
      final y = paddingTop +
          drawH -
          ((valores[i] - minVal) / range) * drawH;
      points.add(Offset(x, y));
    }

    // Área preenchida abaixo da linha
    final fillPath = Path()..moveTo(points.first.dx, size.height - paddingBottom);
    for (final p in points) fillPath.lineTo(p.dx, p.dy);
    fillPath.lineTo(points.last.dx, size.height - paddingBottom);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.25),
            const Color(0xFF6C63FF).withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Linha principal
    final linePaint = Paint()
      ..color = const Color(0xFF6C63FF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cx, prev.dy, cx, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Eixo Y — labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final labelCount = 4;
    for (int i = 0; i <= labelCount; i++) {
      final val = minVal + (range / labelCount) * i;
      final y = paddingTop + drawH - (i / labelCount) * drawH;
      tp.text = TextSpan(
        text: 'R\$${(val / 1000).toStringAsFixed(0)}k',
        style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 9),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Eixo X — labels dos meses
    for (int i = 0; i < meses.length; i++) {
      final x = paddingLeft + (i / (meses.length - 1)) * drawW;
      tp.text = TextSpan(
        text: meses[i],
        style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 10),
      );
      tp.layout();
      tp.paint(
          canvas,
          Offset(
              x - tp.width / 2, size.height - paddingBottom + 6));
    }

    // Ponto no último valor
    canvas.drawCircle(
      points.last,
      4,
      Paint()..color = const Color(0xFF6C63FF),
    );
    canvas.drawCircle(
      points.last,
      6,
      Paint()
        ..color = const Color(0xFF6C63FF).withOpacity(0.25)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget: Gráfico de Barras Verticais — Distribuição por Categoria
// ─────────────────────────────────────────────────────────────────────────────

class _GraficoBarrasVerticais extends StatelessWidget {
  final Map<String, double> dados;

  const _GraficoBarrasVerticais({required this.dados});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        size: const Size(double.infinity, 180),
        painter: _BarrasPainter(dados: dados),
      ),
    );
  }
}

class _BarrasPainter extends CustomPainter {
  final Map<String, double> dados;

  _BarrasPainter({required this.dados});

  @override
  void paint(Canvas canvas, Size size) {
    final entries = dados.entries.toList();
    if (entries.isEmpty) return;

    const paddingLeft = 48.0;
    const paddingBottom = 32.0;
    const paddingTop = 12.0;
    const paddingRight = 8.0;

    final drawW = size.width - paddingLeft - paddingRight;
    final drawH = size.height - paddingBottom - paddingTop;

    final maxVal = entries.map((e) => e.value).reduce(max);

    final cores = [
      const Color(0xFF6C63FF),
      const Color(0xFF00C897),
      const Color(0xFF6C63FF),
      const Color(0xFFFF9500),
      const Color(0xFFFF4D4D),
    ];

    final barW = (drawW / entries.length) * 0.5;
    final gap = drawW / entries.length;

    // Eixo Y
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final labelCount = 4;
    for (int i = 0; i <= labelCount; i++) {
      final val = (maxVal / labelCount) * i;
      final y = paddingTop + drawH - (i / labelCount) * drawH;
      tp.text = TextSpan(
        text: 'R\$${(val / 1000).toStringAsFixed(0)}k',
        style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 9),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));

      // Linha horizontal guia
      canvas.drawLine(
        Offset(paddingLeft - 4, y),
        Offset(size.width - paddingRight, y),
        Paint()
          ..color = const Color(0xFFEEEEEE)
          ..strokeWidth = 1,
      );
    }

    // Barras
    for (int i = 0; i < entries.length; i++) {
      final val = entries[i].value;
      final nome = entries[i].key;
      final cor = cores[i % cores.length];

      final barH = maxVal > 0 ? (val / maxVal) * drawH : 0.0;
      final x = paddingLeft + gap * i + (gap - barW) / 2;
      final y = paddingTop + drawH - barH;

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barW, barH),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );
      canvas.drawRRect(rrect, Paint()..color = cor);

      // Label do eixo X
      tp.text = TextSpan(
        text: nome.length > 8 ? nome.substring(0, 8) : nome,
        style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 9),
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(x + barW / 2 - tp.width / 2,
            size.height - paddingBottom + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget auxiliar: sem dados
// ─────────────────────────────────────────────────────────────────────────────

class _SemDados extends StatelessWidget {
  const _SemDados();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Nenhum investimento ainda.',
          style: TextStyle(color: Color(0xFF888888)),
        ),
      ),
    );
  }
}