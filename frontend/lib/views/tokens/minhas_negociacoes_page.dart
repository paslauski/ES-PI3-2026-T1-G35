// isa
// Tela de histórico das negociações do usuário
// Mostra compras e vendas de tokens feitas no app
// CORRIGIDO: busca também por compradorId e vendedorId (transações do balcão)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MinhasNegociacoesPage extends StatefulWidget {
  const MinhasNegociacoesPage({super.key});

  @override
  State<MinhasNegociacoesPage> createState() => _MinhasNegociacoesPageState();
}

class _MinhasNegociacoesPageState extends State<MinhasNegociacoesPage> {
  String _filtroSelecionado = 'todos';

  String _formatarMoeda(dynamic valor) {
    final numero = double.tryParse((valor ?? 0).toString()) ?? 0;
    return 'R\$ ${numero.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarData(dynamic valor) {
    if (valor == null) return 'Data não informada';
    if (valor is Timestamp) {
      final data = valor.toDate();
      return '${data.day.toString().padLeft(2, '0')}/'
          '${data.month.toString().padLeft(2, '0')}/'
          '${data.year} '
          '${data.hour.toString().padLeft(2, '0')}:'
          '${data.minute.toString().padLeft(2, '0')}';
    }
    return valor.toString();
  }

  DateTime _pegarData(dynamic valor) {
    if (valor is Timestamp) return valor.toDate();
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  double _paraDouble(dynamic valor) =>
      double.tryParse((valor ?? 0).toString()) ?? 0;

  // Determina o tipo da negociação do ponto de vista do usuário logado
  String _tipoParaUsuario(Map<String, dynamic> data, String uid) {
    final tipo = (data['tipo'] ?? '').toString();
    // Transações do balcão têm compradorId/vendedorId
    if (data.containsKey('compradorId')) {
      return data['compradorId'] == uid ? 'compra' : 'venda';
    }
    return tipo;
  }

  List<QueryDocumentSnapshot> _filtrarDocs(
      List<QueryDocumentSnapshot> docs, String uid) {
    if (_filtroSelecionado == 'todos') return docs;
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return _tipoParaUsuario(data, uid) == _filtroSelecionado;
    }).toList();
  }

  Map<String, double> _calcularResumo(
      List<QueryDocumentSnapshot> docs, String uid) {
    double totalCompras = 0;
    double totalVendas = 0;
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final tipo = _tipoParaUsuario(data, uid);
      final valorTotal = _paraDouble(data['valorTotal']);
      if (tipo == 'compra') {
        totalCompras += valorTotal;
      } else if (tipo == 'venda') {
        totalVendas += valorTotal;
      }
    }
    return {
      'compras': totalCompras,
      'vendas': totalVendas,
      'liquido': totalVendas - totalCompras,
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Minhas Negociações')),
        body: const Center(child: Text('Você precisa estar logado.')),
      );
    }

    final uid = user.uid;

    // Busca transações onde o usuário é comprador OU vendedor OU usuarioId
    final queryComprador = FirebaseFirestore.instance
        .collection('transacoes')
        .where('compradorId', isEqualTo: uid);

    final queryVendedor = FirebaseFirestore.instance
        .collection('transacoes')
        .where('vendedorId', isEqualTo: uid);

    final queryUsuario = FirebaseFirestore.instance
        .collection('transacoes')
        .where('usuarioId', isEqualTo: uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Negociações'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<QuerySnapshot>>(
        future: Future.wait([
          queryComprador.get(),
          queryVendedor.get(),
          queryUsuario.get(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          // Junta os 3 resultados sem duplicatas
          final Map<String, QueryDocumentSnapshot> vistos = {};
          for (final qs in snapshot.data ?? []) {
            for (final doc in qs.docs) {
              vistos[doc.id] = doc;
            }
          }

          final todosDocs = vistos.values.toList();

          // Ordena do mais recente para o mais antigo
          todosDocs.sort((a, b) {
            final dA = (a.data() as Map<String, dynamic>);
            final dB = (b.data() as Map<String, dynamic>);
            final dateA = _pegarData(dA['criadoEm'] ?? dA['createdAt']);
            final dateB = _pegarData(dB['criadoEm'] ?? dB['createdAt']);
            return dateB.compareTo(dateA);
          });

          final docsFiltrados = _filtrarDocs(todosDocs, uid);
          final resumo = _calcularResumo(docsFiltrados, uid);

          return Column(
            children: [
              // Resumo
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EEFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD0CAFF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Resumo das negociações',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: _resumoItem('Compras',
                                _formatarMoeda(resumo['compras']), Colors.green)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _resumoItem('Vendas',
                                _formatarMoeda(resumo['vendas']), Colors.red)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _resumoItem(
                                'Lucro',
                                _formatarMoeda(resumo['liquido']),
                                (resumo['liquido'] ?? 0) >= 0
                                    ? Colors.green
                                    : Colors.red)),
                      ],
                    ),
                  ],
                ),
              ),

              // Filtros
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    _botaoFiltro('todos', 'Todos'),
                    const SizedBox(width: 8),
                    _botaoFiltro('compra', 'Compras'),
                    const SizedBox(width: 8),
                    _botaoFiltro('venda', 'Vendas'),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: docsFiltrados.isEmpty
                    ? const Center(
                        child: Text('Nenhuma negociação encontrada.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: docsFiltrados.length,
                        itemBuilder: (context, index) {
                          final data = docsFiltrados[index].data()
                              as Map<String, dynamic>;

                          final tipoUsuario = _tipoParaUsuario(data, uid);
                          final isCompra = tipoUsuario == 'compra';
                          final cor = isCompra ? Colors.green : Colors.red;

                          final nomeStartup =
                              (data['nomeStartup'] ?? data['startupId'] ?? 'Startup')
                                  .toString();
                          final quantidade = data['quantidade'] ?? 0;
                          final precoToken = data['precoToken'] ?? 0;
                          final valorTotal = data['valorTotal'] ?? 0;
                          final criadoEm =
                              data['criadoEm'] ?? data['createdAt'];
                          final isBalcao = data['tipo'] == 'balcao';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: cor.withOpacity(0.15),
                                child: Icon(
                                  isCompra
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: cor,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(nomeStartup,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  if (isBalcao)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6C63FF)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('P2P',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF6C63FF),
                                              fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                              subtitle: Text(
                                '${isCompra ? 'Compra' : 'Venda'} de $quantidade token(s)\n'
                                'Preço: ${_formatarMoeda(precoToken)} | Total: ${_formatarMoeda(valorTotal)}\n'
                                '${_formatarData(criadoEm)}',
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: cor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isCompra ? 'COMPRA' : 'VENDA',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: cor),
                                ),
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _resumoItem(String titulo, String valor, Color cor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: TextStyle(
                  fontSize: 12, color: cor, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(valor,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _botaoFiltro(String valor, String texto) {
    final selecionado = _filtroSelecionado == valor;
    return ChoiceChip(
      label: Text(texto),
      selected: selecionado,
      selectedColor: const Color(0xFF6C63FF).withOpacity(0.2),
      onSelected: (_) => setState(() => _filtroSelecionado = valor),
    );
  }
}