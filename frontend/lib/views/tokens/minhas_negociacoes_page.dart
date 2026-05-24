// isa
// Tela de histórico das negociações do usuário
// Mostra compras e vendas de tokens feitas no app

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MinhasNegociacoesPage extends StatefulWidget {
  const MinhasNegociacoesPage({super.key});

  @override
  State<MinhasNegociacoesPage> createState() => _MinhasNegociacoesPageState();
}

class _MinhasNegociacoesPageState extends State<MinhasNegociacoesPage> {
  // filtro atual da tela: todos, compra ou venda
  String _filtroSelecionado = 'todos';

  // Converte número para formato de moeda brasileira
  String _formatarMoeda(dynamic valor) {
    final numero = double.tryParse((valor ?? 0).toString()) ?? 0;
    return 'R\$ ${numero.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Converte Timestamp do Firebase para texto legível
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

  // Usado para ordenar as transações por data sem precisar de índice no Firestore
  DateTime _pegarData(dynamic valor) {
    if (valor is Timestamp) {
      return valor.toDate();
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  // Converte valores vindos do Firestore para double com segurança
  double _paraDouble(dynamic valor) {
    return double.tryParse((valor ?? 0).toString()) ?? 0;
  }

  // Aplica filtro local na lista de documentos
  List<QueryDocumentSnapshot> _filtrarDocs(List<QueryDocumentSnapshot> docs) {
    if (_filtroSelecionado == 'todos') {
      return docs;
    }

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final tipo = (data['tipo'] ?? '').toString();

      return tipo == _filtroSelecionado;
    }).toList();
  }

  // Calcula resumo financeiro com base nas transações filtradas
  Map<String, double> _calcularResumo(List<QueryDocumentSnapshot> docs) {
    double totalCompras = 0;
    double totalVendas = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      final tipo = (data['tipo'] ?? '').toString();
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
      'liquido': totalCompras - totalVendas,
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Se não tiver usuário logado, bloqueia a tela
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Minhas negociações'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Você precisa estar logado.')),
      );
    }

    // Query sem orderBy para não exigir índice composto no Firestore
    final query = FirebaseFirestore.instance
        .collection('transacoes')
        .where('usuarioId', isEqualTo: user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas negociações'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,

        // Botão fixo para voltar para a Home
        actions: [
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar negociações: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final todosDocs = snapshot.data?.docs ?? [];

          // Ordena por data no Dart, do mais recente para o mais antigo
          todosDocs.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;

            final dateA = _pegarData(dataA['createdAt']);
            final dateB = _pegarData(dataB['createdAt']);

            return dateB.compareTo(dateA);
          });

          final docsFiltrados = _filtrarDocs(todosDocs);
          final resumo = _calcularResumo(docsFiltrados);

          return Column(
            children: [
              // Área de resumo
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumo das negociações',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _resumoItem(
                            titulo: 'Compras',
                            valor: _formatarMoeda(resumo['compras']),
                            cor: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _resumoItem(
                            titulo: 'Vendas',
                            valor: _formatarMoeda(resumo['vendas']),
                            cor: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _resumoItem(
                            titulo: 'Líquido',
                            valor: _formatarMoeda(resumo['liquido']),
                            cor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Filtros
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
                        child: Text('Nenhuma negociação encontrada.'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: docsFiltrados.length,
                        itemBuilder: (context, index) {
                          final data =
                              docsFiltrados[index].data()
                                  as Map<String, dynamic>;

                          final tipo = (data['tipo'] ?? '').toString();
                          final isCompra = tipo == 'compra';

                          final nomeStartup =
                              (data['nomeStartup'] ??
                                      data['startupId'] ??
                                      'Startup')
                                  .toString();

                          final quantidade = data['quantidade'] ?? 0;
                          final precoToken = data['precoToken'] ?? 0;
                          final valorTotal = data['valorTotal'] ?? 0;
                          final createdAt = data['createdAt'];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isCompra
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                child: Icon(
                                  isCompra
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: isCompra ? Colors.green : Colors.red,
                                ),
                              ),

                              title: Text(
                                nomeStartup,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              subtitle: Text(
                                '${isCompra ? 'Compra' : 'Venda'} de $quantidade token(s)\n'
                                'Preço: ${_formatarMoeda(precoToken)} | Total: ${_formatarMoeda(valorTotal)}\n'
                                '${_formatarData(createdAt)}',
                              ),

                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isCompra
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isCompra ? 'COMPRA' : 'VENDA',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isCompra ? Colors.green : Colors.red,
                                  ),
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

  // Card pequeno do resumo
  Widget _resumoItem({
    required String titulo,
    required String valor,
    required Color cor,
  }) {
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
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              color: cor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Botão usado nos filtros Todos/Compras/Vendas
  Widget _botaoFiltro(String valor, String texto) {
    final selecionado = _filtroSelecionado == valor;

    return ChoiceChip(
      label: Text(texto),
      selected: selecionado,
      onSelected: (_) {
        setState(() {
          _filtroSelecionado = valor;
        });
      },
    );
  }
}
