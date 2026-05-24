// Isabela + Mateus - Tela Minha Carteira

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/*
Tela responsável pela exibição da carteira de investimentos do usuário.

Funcionalidades:
- exibir saldo disponível;
- mostrar total investido;
- calcular valor atual real;
- calcular retorno percentual;
- listar investimentos;
- integrar Firebase Auth e Firestore.
*/

class MinhaCarteiraPage extends StatelessWidget {
  const MinhaCarteiraPage({super.key});

  /*
  Formata valores monetários no padrão BRL.

  Exemplo:
  1500.5 -> R$ 1.500,50
  */
  String _fmt(dynamic valor) {
    final n =
        double.tryParse((valor ?? 0).toString()) ?? 0;

    return 'R\$ ${n.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /*
  Converte valores dinâmicos para double.

  Utilizado para:
  - valores vindos do Firestore;
  - números salvos como String;
  - evitar erros de conversão.
  */
  double _toDouble(dynamic v) =>
      double.tryParse((v ?? 0).toString()) ?? 0;

  @override
  Widget build(BuildContext context) {
    // Usuário autenticado
    final user =
        FirebaseAuth.instance.currentUser;

    /*
    Caso o usuário não esteja logado.
    */
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Minha Carteira',
          ),

          automaticallyImplyLeading: false,
        ),

        body: const Center(
          child: Text(
            'Você precisa estar logado.',
          ),
        ),
      );
    }

    /*
    Query da carteira do usuário.
    */
    final carteiraQuery = FirebaseFirestore
        .instance
        .collection('carteiras')
        .where(
          'usuarioId',
          isEqualTo: user.uid,
        );

    /*
    Referência do documento do usuário.
    */
    final usuarioRef = FirebaseFirestore
        .instance
        .collection('usuarios')
        .doc(user.uid);

    return Scaffold(
      /*
      Barra superior da tela.
      */
      appBar: AppBar(
        title: const Text(
          'Minha Carteira',
        ),

        automaticallyImplyLeading: false,

        actions: [
          /*
          Botão para retornar à HomePage.
          */
          IconButton(
            icon: const Icon(
              Icons.home_outlined,
            ),

            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (r) => false,
            ),
          ),
        ],
      ),

      backgroundColor:
          const Color(0xFFF5F5FA),

      /*
      Corpo principal da tela.
      */
      body: StreamBuilder<QuerySnapshot>(
        stream: carteiraQuery.snapshots(),

        builder: (context, snapCarteira) {
          return StreamBuilder<DocumentSnapshot>(
            stream: usuarioRef.snapshots(),

            builder: (context, snapUsuario) {
              /*
              Saldo disponível do usuário.
              */
              double saldo = 0;

              if (snapUsuario.hasData &&
                  snapUsuario.data!.exists) {
                final d = snapUsuario.data!.data()
                    as Map<String, dynamic>;

                saldo = _toDouble(d['saldo']);
              }

              /*
              Lista de investimentos da carteira.
              */
              final docs =
                  snapCarteira.data?.docs ?? [];

              /*
              Busca preços atuais das startups.
              */
              return FutureBuilder<
                  Map<String, double>>(
                future:
                    _buscarPrecosAtuais(docs),

                builder: (
                  context,
                  snapPrecos,
                ) {
                  /*
                  Mapa contendo os preços atuais.
                  */
                  final precosAtuais =
                      snapPrecos.data ?? {};

                  /*
                  Variáveis de cálculo financeiro.
                  */
                  double totalInvestido = 0;
                  double valorAtualTotal = 0;

                  /*
                  Calcula:
                  - total investido;
                  - valor atual;
                  - retorno da carteira.
                  */
                  for (final doc in docs) {
                    final d =
                        doc.data()
                            as Map<String, dynamic>;

                    final startupId =
                        (d['startupId'] ?? '')
                            .toString();

                    final quantidade =
                        _toDouble(
                            d['quantidade']);

                    final investido =
                        _toDouble(
                            d['totalInvestido']);

                    final precoAtual =
                        precosAtuais[startupId] ??
                            _toDouble(
                              d['precoMedio'],
                            );

                    totalInvestido += investido;

                    valorAtualTotal +=
                        quantidade * precoAtual;
                  }

                  /*
                  Calcula retorno percentual total.
                  */
                  final retorno =
                      totalInvestido > 0
                          ? ((valorAtualTotal -
                                      totalInvestido) /
                                  totalInvestido *
                                  100)
                          : 0.0;

                  return Column(
                    children: [
                      /*
                      Card principal da carteira.
                      */
                      Container(
                        margin:
                            const EdgeInsets.all(16),

                        padding:
                            const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(0xFF1A1A2E),
                              Color(0xFF2D2D4E),
                            ],

                            begin:
                                Alignment.topLeft,

                            end:
                                Alignment.bottomRight,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            /*
                            Texto de título.
                            */
                            const Text(
                              'Valor Total Investido',

                              style: TextStyle(
                                color:
                                    Colors.white60,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            /*
                            Valor total atualizado.
                            */
                            Text(
                              _fmt(valorAtualTotal),

                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            /*
                            Indicador de retorno.
                            */
                            Row(
                              children: [
                                Icon(
                                  retorno >= 0
                                      ? Icons
                                          .arrow_upward
                                      : Icons
                                          .arrow_downward,

                                  color:
                                      retorno >= 0
                                          ? const Color(
                                              0xFF00C897,
                                            )
                                          : Colors.red,

                                  size: 14,
                                ),

                                const SizedBox(
                                  width: 4,
                                ),

                                Text(
                                  '${retorno >= 0 ? '+' : ''}${retorno.toStringAsFixed(1)}% retorno total',

                                  style: TextStyle(
                                    color:
                                        retorno >= 0
                                            ? const Color(
                                                0xFF00C897,
                                              )
                                            : Colors.red,

                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            /*
                            Card interno com saldo
                            e total investido.
                            */
                            Container(
                              padding:
                                  const EdgeInsets
                                      .all(12),

                              decoration:
                                  BoxDecoration(
                                color: Colors.white
                                    .withOpacity(
                                  0.08,
                                ),

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                              ),

                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,

                                children: [
                                  /*
                                  Saldo disponível.
                                  */
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [
                                      const Text(
                                        'Saldo Disponível',

                                        style:
                                            TextStyle(
                                          color: Colors
                                              .white60,
                                          fontSize: 11,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 4,
                                      ),

                                      Text(
                                        _fmt(saldo),

                                        style:
                                            const TextStyle(
                                          color: Colors
                                              .white,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  /*
                                  Total investido.
                                  */
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .end,

                                    children: [
                                      const Text(
                                        'Total Investido',

                                        style:
                                            TextStyle(
                                          color: Colors
                                              .white60,
                                          fontSize: 11,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 4,
                                      ),

                                      Text(
                                        _fmt(
                                          totalInvestido,
                                        ),

                                        style:
                                            const TextStyle(
                                          color: Color(
                                            0xFF00C897,
                                          ),

                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      /*
                      Título da lista.
                      */
                      Padding(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 16,
                        ),

                        child: Row(
                          children: const [
                            Text(
                              'Meus Investimentos',

                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                                color: Color(
                                  0xFF1A1A2E,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      /*
                      Lista de investimentos.
                      */
                      Expanded(
                        child: snapCarteira
                                    .connectionState ==
                                ConnectionState
                                    .waiting
                            ? const Center(
                                child:
                                    CircularProgressIndicator(),
                              )

                            /*
                            Caso não existam tokens.
                            */
                            : docs.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Você ainda não possui tokens.',

                                      style:
                                          TextStyle(
                                        color: Color(
                                          0xFF888888,
                                        ),
                                      ),
                                    ),
                                  )

                                /*
                                Lista das posições da carteira.
                                */
                                : ListView.builder(
                                    padding:
                                        const EdgeInsets
                                            .fromLTRB(
                                      16,
                                      0,
                                      16,
                                      16,
                                    ),

                                    itemCount:
                                        docs.length,

                                    itemBuilder:
                                        (
                                      context,
                                      index,
                                    ) {
                                      final d = docs[
                                                  index]
                                              .data()
                                          as Map<
                                              String,
                                              dynamic>;

                                      /*
                                      Dados da posição.
                                      */
                                      final startupId =
                                          (d['startupId'] ??
                                                  '')
                                              .toString();

                                      final nome =
                                          (d['nomeStartup'] ??
                                                  'Startup')
                                              .toString();

                                      final quantidade =
                                          _toDouble(
                                        d['quantidade'],
                                      );

                                      final investido =
                                          _toDouble(
                                        d['totalInvestido'],
                                      );

                                      final precoAtual =
                                          precosAtuais[
                                                  startupId] ??
                                              _toDouble(
                                                d['precoMedio'],
                                              );

                                      /*
                                      Valor atual da posição.
                                      */
                                      final valorAtual =
                                          quantidade *
                                              precoAtual;

                                      /*
                                      Retorno percentual
                                      da posição.
                                      */
                                      final variacao =
                                          investido > 0
                                              ? ((valorAtual -
                                                          investido) /
                                                      investido *
                                                      100)
                                              : 0.0;

                                      /*
                                      Primeira letra
                                      da startup.
                                      */
                                      final letra =
                                          nome.isNotEmpty
                                              ? nome[0]
                                              : '?';

                                      /*
                                      Lista de cores
                                      para alternância.
                                      */
                                      final cores = [
                                        const Color(
                                          0xFFFF9500,
                                        ),
                                        const Color(
                                          0xFF00C897,
                                        ),
                                        const Color(
                                          0xFF6C63FF,
                                        ),
                                        const Color(
                                          0xFFFF4D4D,
                                        ),
                                      ];

                                      final cor =
                                          cores[index %
                                              cores.length];

                                      return Container(
                                        margin:
                                            const EdgeInsets
                                                .only(
                                          bottom: 10,
                                        ),

                                        padding:
                                            const EdgeInsets
                                                .all(16),

                                        decoration:
                                            BoxDecoration(
                                          color:
                                              Colors.white,

                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            16,
                                          ),

                                          border:
                                              Border.all(
                                            color:
                                                const Color(
                                              0xFFEEEEEE,
                                            ),
                                          ),
                                        ),

                                        child: Row(
                                          children: [
                                            /*
                                            Avatar da startup.
                                            */
                                            Container(
                                              width: 44,
                                              height: 44,

                                              decoration:
                                                  BoxDecoration(
                                                color: cor
                                                    .withOpacity(
                                                  0.15,
                                                ),

                                                borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                  12,
                                                ),
                                              ),

                                              child: Center(
                                                child:
                                                    Text(
                                                  letra,

                                                  style:
                                                      TextStyle(
                                                    color:
                                                        cor,

                                                    fontWeight:
                                                        FontWeight.bold,

                                                    fontSize:
                                                        18,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(
                                              width: 12,
                                            ),

                                            /*
                                            Informações do investimento.
                                            */
                                            Expanded(
                                              child:
                                                  Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,

                                                children: [
                                                  /*
                                                  Nome da startup.
                                                  */
                                                  Text(
                                                    nome,

                                                    style:
                                                        const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,

                                                      color: Color(
                                                        0xFF1A1A2E,
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                    height:
                                                        2,
                                                  ),

                                                  /*
                                                  Quantidade de tokens.
                                                  */
                                                  Text(
                                                    '${quantidade.toInt()} tokens',

                                                    style:
                                                        const TextStyle(
                                                      color: Color(
                                                        0xFF888888,
                                                      ),

                                                      fontSize:
                                                          12,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                    height:
                                                        8,
                                                  ),

                                                  /*
                                                  Informações financeiras.
                                                  */
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,

                                                    children: [
                                                      /*
                                                      Valor investido.
                                                      */
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,

                                                        children: [
                                                          const Text(
                                                            'Investido',

                                                            style:
                                                                TextStyle(
                                                              color:
                                                                  Color(
                                                                0xFFAAAAAA,
                                                              ),

                                                              fontSize:
                                                                  11,
                                                            ),
                                                          ),

                                                          Text(
                                                            _fmt(
                                                              investido,
                                                            ),

                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight.w600,

                                                              fontSize:
                                                                  13,
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      /*
                                                      Valor atual.
                                                      */
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.end,

                                                        children: [
                                                          const Text(
                                                            'Valor Atual',

                                                            style:
                                                                TextStyle(
                                                              color:
                                                                  Color(
                                                                0xFFAAAAAA,
                                                              ),

                                                              fontSize:
                                                                  11,
                                                            ),
                                                          ),

                                                          Text(
                                                            _fmt(
                                                              valorAtual,
                                                            ),

                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight.w600,

                                                              fontSize:
                                                                  13,
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      /*
                                                      Percentual de retorno.
                                                      */
                                                      Text(
                                                        '${variacao >= 0 ? '+' : ''}${variacao.toStringAsFixed(0)}%',

                                                        style:
                                                            TextStyle(
                                                          color:
                                                              variacao >= 0
                                                                  ? const Color(
                                                                      0xFF00C897,
                                                                    )
                                                                  : Colors.red,

                                                          fontWeight:
                                                              FontWeight.bold,

                                                          fontSize:
                                                              14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /*
  Busca os preços atuais das startups.

  Responsável por:
  - localizar startups da carteira;
  - obter preço atual do token;
  - converter valores;
  - retornar mapa de preços.
  */
  Future<Map<String, double>>
      _buscarPrecosAtuais(
    List<QueryDocumentSnapshot> docs,
  ) async {
    final Map<String, double> precos = {};

    /*
    Obtém IDs únicos das startups.
    */
    final ids = docs
        .map(
          (d) =>
              (d.data()
                          as Map<String, dynamic>)[
                      'startupId']
                  ?.toString() ??
              '',
        )
        .where((id) => id.isNotEmpty)
        .toSet();

    /*
    Busca preços atuais no Firestore.
    */
    for (final id in ids) {
      try {
        final snap =
            await FirebaseFirestore.instance
                .collection('startups')
                .doc(id)
                .get();

        if (snap.exists) {
          final data =
              snap.data()
                  as Map<String, dynamic>;

          /*
          Campo pode vir como:
          - preco_token
          - precoToken
          */
          final raw =
              data['preco_token'] ??
                  data['precoToken'] ??
                  0;

          final preco =
              double.tryParse(
                    raw
                        .toString()
                        .replaceAll('R\$', '')
                        .replaceAll(' ', '')
                        .replaceAll(',', '.'),
                  ) ??
                  0;

          /*
          Adiciona preço válido.
          */
          if (preco > 0) {
            precos[id] = preco;
          }
        }
      }

      /*
      Ignora erros individuais
      para evitar quebra total.
      */
      catch (_) {}
    }

    return precos;
  }
}