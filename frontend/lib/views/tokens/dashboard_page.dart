// Mateus - Dashboard financeiro com gráficos
// ATUALIZADO: filtros de período (Diário, Semanal, Mensal, 6 meses, YTD)
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _periodoSelecionado = 'mensal';

  String _fmt(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  double _toDouble(dynamic v) =>
      double.tryParse((v ?? 0).toString()) ?? 0;

  DateTime _inicioPeriodo() {
    final agora = DateTime.now();
    switch (_periodoSelecionado) {
      case 'diario':
        return DateTime(agora.year, agora.month, agora.day);
      case 'semanal':
        return agora.subtract(const Duration(days: 7));
      case 'mensal':
        return DateTime(agora.year, agora.month, 1);
      case '6m':
        return DateTime(agora.year, agora.month - 5, 1);
      case 'ytd':
        return DateTime(agora.year, 1, 1);
      default:
        return DateTime(agora.year, agora.month, 1);
    }
  }

  Future<Map<String, dynamic>> _carregarDados(String uid) async {
    final inicio = _inicioPeriodo();

    final carteiraSnap = await FirebaseFirestore.instance
        .collection('carteiras')
        .where('usuarioId', isEqualTo: uid)
        .get();

    // Busca transações do período (compras diretas + balcão como comprador)
    final transacoesSnap = await FirebaseFirestore.instance
        .collection('transacoes')
        .where('usuarioId', isEqualTo: uid)
        .get();

    final balcaoCompraSnap = await FirebaseFirestore.instance
        .collection('transacoes')
        .where('compradorId', isEqualTo: uid)
        .get();

    final balcaoVendaSnap = await FirebaseFirestore.instance
        .collection('transacoes')
        .where('vendedorId', isEqualTo: uid)
        .get();

    // Junta sem duplicatas
    final Map<String, Map<String, dynamic>> todasTransacoes = {};
    for (final snap in [transacoesSnap, balcaoCompraSnap, balcaoVendaSnap]) {
      for (final doc in snap.docs) {
        todasTransacoes[doc.id] = doc.data();
      }
    }

    // Calcula totais da carteira
    double totalInvestido = 0;
    double valorAtual = 0;
    final Map<String, double> porStartup = {};

    for (final doc in carteiraSnap.docs) {
      final d = doc.data();
      final nome = (d['nomeStartup'] ?? 'Startup').toString();
      final valor = _toDouble(d['totalInvestido']);
      totalInvestido += valor;
      valorAtual += _toDouble(d['quantidade']) * _toDouble(d['precoMedio']);
      porStartup[nome] = (porStartup[nome] ?? 0) + valor;
    }

    // Filtra transações pelo período selecionado
    final transacoesPeriodo = todasTransacoes.values.where((data) {
      final ts = data['criadoEm'] ?? data['createdAt'];
      if (ts is! Timestamp) return false;
      return ts.toDate().isAfter(inicio);
    }).toList();

    transacoesPeriodo.sort((a, b) {
      final tsA = (a['criadoEm'] ?? a['createdAt']) as Timestamp;
      final tsB = (b['criadoEm'] ?? b['createdAt']) as Timestamp;
      return tsA.toDate().compareTo(tsB.toDate());
    });

    // Gera pontos para o gráfico com base nas transações reais do período
    final pontos = <double>[];
    final mesesLabels = <String>[];
    double acumulado = 0;

    for (final t in transacoesPeriodo) {
      final tipo = (t['tipo'] ?? '').toString();
      final valor = _toDouble(t['valorTotal']);
      final ts = (t['criadoEm'] ?? t['createdAt']) as Timestamp;
      final data = ts.toDate();

      if (tipo == 'compra') acumulado += valor;
      if (tipo == 'venda') acumulado -= valor;
      if (tipo == 'balcao') {
        if (t['compradorId'] == uid) acumulado += valor;
        if (t['vendedorId'] == uid) acumulado -= valor;
      }

      pontos.add(acumulado);
      mesesLabels.add('${data.day}/${data.month}');
    }

    if (pontos.isEmpty) {
      pontos.add(totalInvestido);
      mesesLabels.add('Hoje');
    }

    final resultado = valorAtual - totalInvestido;
    final percentual = totalInvestido == 0 ? 0.0 : (resultado / totalInvestido) * 100;

    // Busca categorias
    final categorias = await _buscarPorCategoria(carteiraSnap.docs);

    return {
      'totalInvestido': totalInvestido,
      'valorAtual': valorAtual,
      'resultado': resultado,
      'percentual': percentual,
      'pontos': pontos,
      'meses': mesesLabels,
      'porStartup': porStartup,
      'categorias': categorias,
    };
  }

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
          final setor = (data['setor'] ?? data['categoria'] ?? 'Outros').toString();
          resultado[setor] = (resultado[setor] ?? 0) + valor;
        }
      } catch (_) {}
    }
    return resultado;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard'), automaticallyImplyLeading: false),
        body: const Center(child: Text('Você precisa estar logado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFF5F5FA),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _carregarDados(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final dados = snapshot.data!;
          final totalInvestido = dados['totalInvestido'] as double;
          final valorAtual = dados['valorAtual'] as double;
          final resultado = dados['resultado'] as double;
          final percentual = dados['percentual'] as double;
          final pontos = dados['pontos'] as List<double>;
          final meses = dados['meses'] as List<String>;
          final porStartup = dados['porStartup'] as Map<String, double>;
          final categorias = dados['categorias'] as Map<String, double>;
          final dadosGrafico = categorias.isNotEmpty ? categorias : porStartup;
          final positivo = resultado >= 0;

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
                        variacao: '${positivo ? '+' : ''}${percentual.toStringAsFixed(1)}%',
                        positivo: positivo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _cardResumo(
                        titulo: 'Valor Atual',
                        valor: _fmt(valorAtual),
                        variacao: '${positivo ? '+' : ''}${_fmt(resultado)}',
                        positivo: positivo,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── FILTROS DE PERÍODO ───────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _chipPeriodo('diario', 'Diário'),
                      const SizedBox(width: 8),
                      _chipPeriodo('semanal', 'Semanal'),
                      const SizedBox(width: 8),
                      _chipPeriodo('mensal', 'Mensal'),
                      const SizedBox(width: 8),
                      _chipPeriodo('6m', 'Últimos 6 meses'),
                      const SizedBox(width: 8),
                      _chipPeriodo('ytd', 'YTD'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── GRÁFICO DE LINHA ─────────────────────────────
                _cardGrafico(
                  titulo: 'Performance do Portfólio',
                  child: totalInvestido == 0
                      ? const _SemDados()
                      : _GraficoLinha(meses: meses, valores: pontos),
                ),

                const SizedBox(height: 20),

                // ── GRÁFICO DE BARRAS ────────────────────────────
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
                      const Text('Resumo dos Investimentos',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 16),
                      if (porStartup.isEmpty)
                        const Text('Nenhum investimento ainda.',
                            style: TextStyle(color: Color(0xFF888888)))
                      else
                        ...porStartup.entries.toList().asMap().entries.map((e) {
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
                                        color: cor, shape: BoxShape.circle)),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(e.value.key,
                                        style: const TextStyle(
                                            color: Color(0xFF444444)))),
                                Text(_fmt(e.value.value),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A2E))),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Center(
                  child: Text('Dados baseados nas transações registradas.',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _chipPeriodo(String valor, String texto) {
    final selecionado = _periodoSelecionado == valor;
    return ChoiceChip(
      label: Text(texto),
      selected: selecionado,
      selectedColor: const Color(0xFF6C63FF).withOpacity(0.2),
      onSelected: (_) => setState(() => _periodoSelecionado = valor),
    );
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
          Text(titulo,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E))),
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
              style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
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
                color: positivo ? const Color(0xFF00C897) : Colors.red,
              ),
              const SizedBox(width: 2),
              Text(variacao,
                  style: TextStyle(
                      fontSize: 12,
                      color: positivo ? const Color(0xFF00C897) : Colors.red,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── GRÁFICO DE LINHA ──────────────────────────────────────────────────────────

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

    final points = <Offset>[];
    for (int i = 0; i < valores.length; i++) {
      final x = valores.length == 1
          ? paddingLeft + drawW / 2
          : paddingLeft + (i / (valores.length - 1)) * drawW;
      final y = paddingTop + drawH - ((valores[i] - minVal) / range) * drawH;
      points.add(Offset(x, y));
    }

    final fillPath = Path()
      ..moveTo(points.first.dx, size.height - paddingBottom);
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

    final linePaint = Paint()
      ..color = const Color(0xFF6C63FF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cx, prev.dy, cx, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(linePath, linePaint);

    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i <= 4; i++) {
      final val = minVal + (range / 4) * i;
      final y = paddingTop + drawH - (i / 4) * drawH;
      tp.text = TextSpan(
        text: 'R\$${(val / 1000).toStringAsFixed(1)}k',
        style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 9),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    final labelsToShow = meses.length <= 6
        ? meses
        : List.generate(6, (i) => meses[(i * (meses.length - 1) / 5).round()]);
    final idxToShow = meses.length <= 6
        ? List.generate(meses.length, (i) => i)
        : List.generate(6, (i) => (i * (meses.length - 1) / 5).round());

    for (int j = 0; j < idxToShow.length; j++) {
      final i = idxToShow[j];
      final x = meses.length == 1
          ? paddingLeft + drawW / 2
          : paddingLeft + (i / (meses.length - 1)) * drawW;
      tp.text = TextSpan(
        text: labelsToShow[j],
        style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 9),
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - paddingBottom + 6));
    }

    canvas.drawCircle(points.last, 4, Paint()..color = const Color(0xFF6C63FF));
    canvas.drawCircle(
        points.last,
        6,
        Paint()
          ..color = const Color(0xFF6C63FF).withOpacity(0.25)
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// ── GRÁFICO DE BARRAS ─────────────────────────────────────────────────────────

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
      const Color(0xFFFF9500),
      const Color(0xFFFF4D4D),
      const Color(0xFF1A1A2E),
    ];
    final barW = (drawW / entries.length) * 0.5;
    final gap = drawW / entries.length;
    final tp = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 4; i++) {
      final val = (maxVal / 4) * i;
      final y = paddingTop + drawH - (i / 4) * drawH;
      tp.text = TextSpan(
        text: 'R\$${(val / 1000).toStringAsFixed(0)}k',
        style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 9),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
      canvas.drawLine(Offset(paddingLeft - 4, y),
          Offset(size.width - paddingRight, y),
          Paint()..color = const Color(0xFFEEEEEE)..strokeWidth = 1);
    }

    for (int i = 0; i < entries.length; i++) {
      final val = entries[i].value;
      final nome = entries[i].key;
      final cor = cores[i % cores.length];
      final barH = maxVal > 0 ? (val / maxVal) * drawH : 0.0;
      final x = paddingLeft + gap * i + (gap - barW) / 2;
      final y = paddingTop + drawH - barH;
      canvas.drawRRect(
        RRect.fromRectAndCorners(Rect.fromLTWH(x, y, barW, barH),
            topLeft: const Radius.circular(6),
            topRight: const Radius.circular(6)),
        Paint()..color = cor,
      );
      tp.text = TextSpan(
        text: nome.length > 8 ? nome.substring(0, 8) : nome,
        style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 9),
      );
      tp.layout();
      tp.paint(canvas,
          Offset(x + barW / 2 - tp.width / 2, size.height - paddingBottom + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

class _SemDados extends StatelessWidget {
  const _SemDados();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text('Nenhum investimento ainda.',
            style: TextStyle(color: Color(0xFF888888))),
      ),
    );
  }
}