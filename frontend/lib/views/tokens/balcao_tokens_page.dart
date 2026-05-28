// Mateus - Balcão P2P completo com filas de ordens reais
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class BalcaoTokensPage extends StatefulWidget {
  const BalcaoTokensPage({super.key});

  @override
  State<BalcaoTokensPage> createState() => _BalcaoTokensPageState();
}

class _BalcaoTokensPageState extends State<BalcaoTokensPage> {
  String? _startupId;
  String _nomeStartup = '';
  double _precoToken = 0;
  bool _carregando = false;
  List<QueryDocumentSnapshot> _todasStartups = [];

  String _fmt(dynamic v) {
    final n = double.tryParse((v ?? 0).toString()) ?? 0;
    return 'R\$ ${n.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  double _toDouble(dynamic v, [double def = 0]) =>
      double.tryParse(v.toString().replaceAll('R\$', '').replaceAll(' ', '').replaceAll(',', '.')) ?? def;

  String _gerarSimbolo(String nome) {
    final p = nome.trim().split(' ');
    if (p.length >= 2) return (p[0][0] + p[1][0]).toUpperCase();
    return nome.length >= 3 ? nome.substring(0, 3).toUpperCase() : nome.toUpperCase();
  }

  // ── CRIAR ORDEM VIA BACKEND ──────────────────────────────────
  Future<void> _criarOrdem(String tipo, int quantidade, double preco) async {
    setState(() => _carregando = true);
    try {
      final fn = FirebaseFunctions.instance.httpsCallable('criarOrdem');
      final result = await fn.call({
        'startupId': _startupId,
        'nomeStartup': _nomeStartup,
        'tipo': tipo,
        'quantidade': quantidade,
        'precoToken': preco,
      });
      if (!mounted) return;
      final match = result.data['match'] == true;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.data['mensagem'] ?? 'OK'),
        backgroundColor: match ? const Color(0xFF6C63FF) : const Color(0xFF00C897),
      ));
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'Erro ao criar ordem.'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  // ── CANCELAR ORDEM ───────────────────────────────────────────
  Future<void> _cancelarOrdem(String ordemId) async {
    try {
      final fn = FirebaseFunctions.instance.httpsCallable('cancelarOrdem');
      await fn.call({'ordemId': ordemId});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ordem cancelada.'),
        backgroundColor: Colors.orange,
      ));
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'Erro ao cancelar.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // ── DIÁLOGO DE ORDEM ─────────────────────────────────────────
  void _abrirDialogo(String tipo) {
    int quantidade = 1;
    double preco = _precoToken;
    final isCompra = tipo == 'compra';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          final total = quantidade * preco;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(isCompra ? '🛒 Ordem de Compra' : '📤 Ordem de Venda',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_nomeStartup, style: const TextStyle(color: Color(0xFF888888))),
                const SizedBox(height: 16),
                const Text('Preço por token (R\$):',
                    style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
                const SizedBox(height: 6),
                TextField(
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: preco.toStringAsFixed(2),
                    prefixText: 'R\$ ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (v) => setD(() => preco = _toDouble(v, _precoToken)),
                ),
                const SizedBox(height: 16),
                const Text('Quantidade:', style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: quantidade > 1 ? () => setD(() => quantidade--) : null,
                      icon: const Icon(Icons.remove_circle_outline, size: 28),
                      color: const Color(0xFF6C63FF),
                    ),
                    Text('$quantidade',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => setD(() => quantidade++),
                      icon: const Icon(Icons.add_circle_outline, size: 28),
                      color: const Color(0xFF6C63FF),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: (isCompra ? const Color(0xFF00C897) : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Total: ${_fmt(total)}',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCompra ? const Color(0xFF00C897) : Colors.red)),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: Color(0xFF888888)))),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _criarOrdem(tipo, quantidade, preco);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompra ? const Color(0xFF00C897) : Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isCompra ? 'Criar Ordem de Compra' : 'Criar Ordem de Venda',
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Balcão de Tokens'),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFF5F5FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('startups').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhuma startup cadastrada.'));
          }

          _todasStartups = snapshot.data!.docs;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── SELETOR DE STARTUP ───────────────────────
                const Text('Selecione a Startup',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _startupId,
                      hint: const Text('Selecione...'),
                      isExpanded: true,
                      items: _todasStartups.map((doc) {
                        final d = doc.data() as Map<String, dynamic>;
                        final nome = (d['nome'] ?? 'Sem nome').toString();
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text('$nome (${_gerarSimbolo(nome)})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        final doc = _todasStartups.firstWhere((e) => e.id == value);
                        final d = doc.data() as Map<String, dynamic>;
                        final nome = (d['nome'] ?? '').toString();
                        setState(() {
                          _startupId = doc.id;
                          _nomeStartup = nome;
                          _precoToken = _toDouble(d['preco_token'], 1.0);
                        });
                      },
                    ),
                  ),
                ),

                if (_startupId != null) ...[
                  const SizedBox(height: 16),

                  // ── CARD DE COTAÇÃO ──────────────────────────
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('cotacoes')
                        .doc(_startupId)
                        .snapshots(),
                    builder: (context, cotSnap) {
                      final cotacao = cotSnap.data?.data() as Map<String, dynamic>?;
                      final ultimoPreco = cotacao != null
                          ? _toDouble(cotacao['ultimoPreco'], _precoToken)
                          : _precoToken;
                      final maior = cotacao != null ? _toDouble(cotacao['maiorPrecoHoje']) : 0.0;
                      final menor = cotacao != null ? _toDouble(cotacao['menorPrecoHoje']) : 0.0;
                      final volume = cotacao != null ? (cotacao['volumeHoje'] ?? 0) : 0;

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF5A52CC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$_nomeStartup (${_gerarSimbolo(_nomeStartup)})',
                                style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(_fmt(ultimoPreco),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                            const Text('último preço negociado',
                                style: TextStyle(color: Colors.white54, fontSize: 11)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _statCard('📈 Max', _fmt(maior)),
                                const SizedBox(width: 8),
                                _statCard('📉 Min', _fmt(menor)),
                                const SizedBox(width: 8),
                                _statCard('📊 Vol', '$volume tokens'),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── BOTÕES DE AÇÃO ───────────────────────────
                  _carregando
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _abrirDialogo('compra'),
                                icon: const Icon(Icons.shopping_cart_outlined),
                                label: const Text('Comprar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C897),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _abrirDialogo('venda'),
                                icon: const Icon(Icons.sell_outlined),
                                label: const Text('Vender'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),

                  const SizedBox(height: 24),

                  // ── FILAS DE ORDENS ──────────────────────────
                  Row(
                    children: [
                      Expanded(child: _filaOrdens('venda', 'Ordens de Venda', Colors.red)),
                      const SizedBox(width: 12),
                      Expanded(child: _filaOrdens('compra', 'Ordens de Compra', const Color(0xFF00C897))),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── MINHAS ORDENS ABERTAS ────────────────────
                  if (uid != null) _minhasOrdens(uid),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ── WIDGET: FILA DE ORDENS ────────────────────────────────────
  Widget _filaOrdens(String tipo, String titulo, Color cor) {
    final isVenda = tipo == 'venda';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo,
            style: TextStyle(fontWeight: FontWeight.w700, color: cor, fontSize: 13)),
        const SizedBox(height: 6),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('ordens')
              .where('startupId', isEqualTo: _startupId)
              .where('tipo', isEqualTo: tipo)
              .where('status', whereIn: ['aberta', 'parcial'])
              .orderBy('precoToken', descending: !isVenda)
              .orderBy('criadoEm', descending: false)
              .limit(5)
              .snapshots(),
          builder: (context, snap) {
            if (!snap.hasData || snap.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEEEEE))),
                child: const Center(
                    child: Text('Sem ordens', style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 12))),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                children: [
                  // Cabeçalho
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text('Qtd', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600))),
                        Expanded(child: Text('Preço', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ...snap.data!.docs.map((doc) {
                    final d = doc.data() as Map<String, dynamic>;
                    final qtd = d['quantRestante'] ?? d['quantidade'] ?? 0;
                    final preco = _toDouble(d['precoToken']);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      child: Row(
                        children: [
                          Expanded(child: Text('$qtd', style: const TextStyle(fontSize: 12))),
                          Expanded(
                              child: Text(_fmt(preco),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: 12, color: cor, fontWeight: FontWeight.w600))),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── WIDGET: MINHAS ORDENS ─────────────────────────────────────
  Widget _minhasOrdens(String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Minhas Ordens Abertas',
            style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('ordens')
              .where('usuarioId', isEqualTo: uid)
              .where('startupId', isEqualTo: _startupId)
              .where('status', whereIn: ['aberta', 'parcial'])
              .orderBy('criadoEm', descending: true)
              .snapshots(),
          builder: (context, snap) {
            if (!snap.hasData || snap.data!.docs.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEEEEE))),
                child: const Text('Nenhuma ordem aberta.',
                    style: TextStyle(color: Color(0xFFAAAAAA)), textAlign: TextAlign.center),
              );
            }

            return Column(
              children: snap.data!.docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                final isCompra = d['tipo'] == 'compra';
                final cor = isCompra ? const Color(0xFF00C897) : Colors.red;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(isCompra ? 'COMPRA' : 'VENDA',
                            style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${d['quantRestante'] ?? d['quantidade']} tokens',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(_fmt(d['precoToken']),
                                style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _cancelarOrdem(doc.id),
                        child: const Text('Cancelar',
                            style: TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _statCard(String label, String valor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            const SizedBox(height: 2),
            Text(valor,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}