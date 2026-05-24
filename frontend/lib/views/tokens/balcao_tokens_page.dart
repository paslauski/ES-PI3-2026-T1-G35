// Isabela + Mateus - Tela Balcão de Tokens baseada no Figma

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/token_service.dart';

/*
Tela responsável pelo mercado de tokens.

Funcionalidades:
- selecionar startups;
- visualizar preço do token;
- exibir carteira do usuário;
- realizar compra de tokens;
- realizar venda de tokens;
- mostrar histórico de transações;
- exibir ofertas simuladas;
- integrar Firebase Auth;
- integrar Cloud Firestore.
*/

class BalcaoTokensPage extends StatefulWidget {
  const BalcaoTokensPage({super.key});

  @override
  State<BalcaoTokensPage> createState() =>
      _BalcaoTokensPageState();
}

/*
State responsável pelo gerenciamento:
- startup selecionada;
- operações financeiras;
- carregamento;
- histórico;
- integração com Firestore;
- exibição dinâmica dos dados.
*/

class _BalcaoTokensPageState
    extends State<BalcaoTokensPage> {
  /*
  ID da startup selecionada.
  */
  String? _startupId;

  /*
  Nome da startup selecionada.
  */
  String _nomeStartup = '';

  /*
  Símbolo da startup.
  */
  String _simbolo = '';

  /*
  Preço atual do token.
  */
  double _precoToken = 0;

  /*
  Controla carregamento das operações.
  */
  bool _carregando = false;

  /*
  Lista de startups carregadas.
  */
  List<QueryDocumentSnapshot>
      _todasStartups = [];

  /*
  Formata valores monetários para BRL.
  */
  String _fmt(dynamic v) {
    final n =
        double.tryParse((v ?? 0).toString()) ??
            0;

    return 'R\$ ${n.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /*
  Converte valores dinâmicos para double.

  Trata:
  - números;
  - strings;
  - valores monetários.
  */
  double _converterNumero(
    dynamic valor,
    double padrao,
  ) {
    if (valor == null) return padrao;

    final texto = valor
        .toString()
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.');

    return double.tryParse(texto) ??
        padrao;
  }

  /*
  Gera símbolo automático da startup.

  Exemplo:
  Tech Vision -> TV
  Nubank -> NUB
  */
  String _gerarSimbolo(String nome) {
    final palavras =
        nome.trim().split(' ');

    if (palavras.length >= 2) {
      return (palavras[0][0] +
              palavras[1][0])
          .toUpperCase();
    }

    return nome.length >= 3
        ? nome
            .substring(0, 3)
            .toUpperCase()
        : nome.toUpperCase();
  }

  /*
  Executa compra ou venda de tokens.

  Responsável por:
  - validar usuário;
  - validar startup;
  - chamar TokenService;
  - exibir feedback visual;
  - tratar erros.
  */
  Future<void> _executarOperacao(
    String tipo,
    int quantidade,
  ) async {
    /*
    Obtém usuário autenticado.
    */
    final user =
        FirebaseAuth.instance.currentUser;

    /*
    Validação de login.
    */
    if (user == null) {
      _msg(
        'Usuário não está logado.',
        erro: true,
      );

      return;
    }

    /*
    Validação de startup.
    */
    if (_startupId == null) {
      _msg(
        'Selecione uma startup.',
        erro: true,
      );

      return;
    }

    setState(() => _carregando = true);

    try {
      /*
      Operação de compra.
      */
      if (tipo == 'compra') {
        await TokenService()
            .comprarTokens(
          usuarioId: user.uid,
          startupId: _startupId!,
          quantidade: quantidade,
          precoToken: _precoToken,
          nomeStartup: _nomeStartup,
        );
      }

      /*
      Operação de venda.
      */
      else {
        await TokenService()
            .venderTokens(
          usuarioId: user.uid,
          startupId: _startupId!,
          quantidade: quantidade,
          precoToken: _precoToken,
          nomeStartup: _nomeStartup,
        );
      }

      /*
      Mensagem de sucesso.
      */
      _msg(
        tipo == 'compra'
            ? '✅ Compra realizada!'
            : '✅ Venda realizada!',
      );
    }

    /*
    Tratamento de erro.
    */
    catch (e) {
      _msg(
        'Erro: ${e.toString().replaceAll('Exception: ', '')}',
        erro: true,
      );
    }

    finally {
      if (mounted) {
        setState(
          () => _carregando = false,
        );
      }
    }
  }

  /*
  Exibe SnackBar de feedback.

  Pode ser:
  - sucesso;
  - erro.
  */
  void _msg(
    String texto, {
    bool erro = false,
  }) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(texto),

        backgroundColor: erro
            ? Colors.red
            : const Color(0xFF00C897),
      ),
    );
  }

  /*
  Abre diálogo de compra ou venda.

  Permite:
  - selecionar quantidade;
  - visualizar total;
  - confirmar operação.
  */
  void _abrirDialogo(String tipo) {
    /*
    Quantidade inicial.
    */
    int quantidade = 1;

    showDialog(
      context: context,

      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          /*
          Calcula valor total.
          */
          final total =
              quantidade * _precoToken;

          /*
          Define se operação é compra.
          */
          final isCompra =
              tipo == 'compra';

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(20),
            ),

            /*
            Título do diálogo.
            */
            title: Text(
              isCompra
                  ? '🛒 Comprar Tokens'
                  : '📤 Vender Tokens',

              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            /*
            Conteúdo principal do diálogo.
            */
            content: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                /*
                Nome e símbolo da startup.
                */
                Text(
                  '$_nomeStartup ($_simbolo)',

                  style: const TextStyle(
                    color:
                        Color(0xFF888888),
                  ),
                ),

                const SizedBox(height: 4),

                /*
                Preço do token.
                */
                Text(
                  'Preço: ${_fmt(_precoToken)} por token',

                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 16),

                /*
                Controle de quantidade.
                */
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [
                    /*
                    Botão diminuir.
                    */
                    IconButton(
                      onPressed:
                          quantidade > 1
                              ? () => setD(
                                    () =>
                                        quantidade--,
                                  )
                              : null,

                      icon: const Icon(
                        Icons
                            .remove_circle_outline,

                        size: 28,
                      ),

                      color:
                          const Color(
                        0xFF6C63FF,
                      ),
                    ),

                    /*
                    Quantidade selecionada.
                    */
                    Text(
                      '$quantidade',

                      style:
                          const TextStyle(
                        fontSize: 26,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    /*
                    Botão aumentar.
                    */
                    IconButton(
                      onPressed: () {
                        setD(
                          () => quantidade++,
                        );
                      },

                      icon: const Icon(
                        Icons
                            .add_circle_outline,

                        size: 28,
                      ),

                      color:
                          const Color(
                        0xFF6C63FF,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /*
                Exibição do valor total.
                */
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),

                  decoration: BoxDecoration(
                    color: (isCompra
                            ? const Color(
                                0xFF00C897,
                              )
                            : Colors.red)
                        .withOpacity(0.1),

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),

                  child: Text(
                    'Total: ${_fmt(total)}',

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,

                      color: isCompra
                          ? const Color(
                              0xFF00C897,
                            )
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),

            /*
            Botões de ação.
            */
            actions: [
              /*
              Botão cancelar.
              */
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },

                child: const Text(
                  'Cancelar',

                  style: TextStyle(
                    color:
                        Color(0xFF888888),
                  ),
                ),
              ),

              /*
              Botão confirmar operação.
              */
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);

                  _executarOperacao(
                    tipo,
                    quantidade,
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompra
                      ? const Color(
                          0xFF00C897,
                        )
                      : Colors.red,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),

                child: Text(
                  isCompra
                      ? 'Confirmar Compra'
                      : 'Confirmar Venda',

                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /*
    Usuário autenticado.
    */
    final user =
        FirebaseAuth.instance.currentUser;

    return Scaffold(
      /*
      Barra superior da tela.
      */
      appBar: AppBar(
        title: const Text(
          'Balcão de Tokens',
        ),

        automaticallyImplyLeading: false,

        actions: [
          /*
          Botão para retornar à Home.
          */
          IconButton(
            icon: const Icon(
              Icons.home_outlined,
            ),

            onPressed: () {
              Navigator
                  .pushNamedAndRemoveUntil(
                context,
                '/home',
                (r) => false,
              );
            },
          ),
        ],
      ),

      /*
      Cor de fundo da tela.
      */
      backgroundColor:
          const Color(0xFFF5F5FA),

      /*
      Conteúdo principal.
      */
      body: StreamBuilder<QuerySnapshot>(
        /*
        Stream de startups.
        */
        stream: FirebaseFirestore.instance
            .collection('startups')
            .snapshots(),

        builder: (
          context,
          snapshot,
        ) {
          /*
          Estado de carregamento.
          */
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          /*
          Caso não existam startups.
          */
          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma startup cadastrada.',
              ),
            );
          }

          /*
          Lista de startups carregadas.
          */
          _todasStartups =
              snapshot.data!.docs;

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                /*
                Título do seletor.
                */
                const Text(
                  'Selecione a Startup',

                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,

                    color:
                        Color(0xFF1A1A2E),
                  ),
                ),

                const SizedBox(height: 8),

                /*
                Dropdown de startups.
                */
                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),

                    border: Border.all(
                      color: const Color(
                        0xFFE0E0E0,
                      ),
                    ),
                  ),

                  child:
                      DropdownButtonHideUnderline(
                    child:
                        DropdownButton<String>(
                      value: _startupId,

                      hint: const Text(
                        'Selecione...',
                      ),

                      isExpanded: true,

                      /*
                      Lista dinâmica de startups.
                      */
                      items: _todasStartups.map(
                        (doc) {
                          final d = doc.data()
                              as Map<
                                  String,
                                  dynamic>;

                          final nome =
                              (d['nome'] ??
                                      'Sem nome')
                                  .toString();

                          final sim =
                              _gerarSimbolo(
                            nome,
                          );

                          return DropdownMenuItem<
                              String>(
                            value: doc.id,

                            child: Text(
                              '$nome ($sim)',
                            ),
                          );
                        },
                      ).toList(),

                      /*
                      Atualiza startup selecionada.
                      */
                      onChanged: (value) {
                        final doc =
                            _todasStartups
                                .firstWhere(
                          (e) =>
                              e.id == value,
                        );

                        final d =
                            doc.data()
                                as Map<String,
                                    dynamic>;

                        final nome =
                            (d['nome'] ?? '')
                                .toString();

                        setState(() {
                          _startupId = doc.id;

                          _nomeStartup = nome;

                          _simbolo =
                              _gerarSimbolo(
                            nome,
                          );

                          _precoToken =
                              _converterNumero(
                            d['preco_token'],
                            10.0,
                          );
                        });
                      },
                    ),
                  ),
                ),

                /*
                Exibe informações apenas
                após seleção da startup.
                */
                if (_startupId != null) ...[
                  const SizedBox(height: 16),

                  /*
                  Card principal do token.
                  */
                  Container(
                    width: double.infinity,

                    padding:
                        const EdgeInsets.all(
                      20,
                    ),

                    decoration: BoxDecoration(
                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(0xFF6C63FF),
                          Color(0xFF5A52CC),
                        ],

                        begin:
                            Alignment.topLeft,

                        end:
                            Alignment
                                .bottomRight,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        /*
                        Nome da startup.
                        */
                        Text(
                          '$_nomeStartup ($_simbolo)',

                          style:
                              const TextStyle(
                            color:
                                Colors.white70,

                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        /*
                        Preço atual do token.
                        */
                        Text(
                          _precoToken
                              .toStringAsFixed(
                                2,
                              )
                              .replaceAll(
                                '.',
                                ',',
                              ),

                          style:
                              const TextStyle(
                            color:
                                Colors.white,

                            fontSize: 36,

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        /*
                        Gráfico simulado.
                        */
                        SizedBox(
                          height: 40,

                          child: CustomPaint(
                            size: const Size(
                              double.infinity,
                              40,
                            ),

                            painter:
                                _GraficoLinhaPainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /*
  Cabeçalho padrão das tabelas.
  */
  Widget _cabecalhoTabela() => Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        decoration: const BoxDecoration(
          color: Color(0xFFF5F5FA),

          borderRadius:
              BorderRadius.vertical(
            top: Radius.circular(14),
          ),
        ),

        child: const Row(
          children: [
            Text('Tipo'),
          ],
        ),
      );

  /*
  Linha padrão de oferta.
  */
  Widget _linhaOferta(
    String tipo,
    String quantidade,
    String valor,
    bool isCompra,
  ) =>
      Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),

        child: Row(
          children: [
            Expanded(
              child: Text(
                tipo,

                style: TextStyle(
                  color: isCompra
                      ? const Color(
                          0xFF00C897,
                        )
                      : Colors.red,

                  fontWeight:
                      FontWeight.w600,

                  fontSize: 13,
                ),
              ),
            ),

            Expanded(
              child: Text(
                quantidade,

                style: const TextStyle(
                  color:
                      Color(0xFF444444),

                  fontSize: 13,
                ),
              ),
            ),

            Expanded(
              child: Text(
                valor,

                textAlign: TextAlign.right,

                style: const TextStyle(
                  color:
                      Color(0xFF1A1A2E),

                  fontWeight:
                      FontWeight.w600,

                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
}

/*
Painter responsável pelo gráfico
simulado de valorização.
*/

class _GraficoLinhaPainter
    extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    /*
    Configuração visual da linha.
    */
    final paint = Paint()
      ..color =
          Colors.white.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    /*
    Pontos simulados do gráfico.
    */
    final pontos = [
      0.6,
      0.5,
      0.55,
      0.45,
      0.5,
      0.4,
      0.45,
      0.35,
      0.3,
      0.2,
    ];

    final path = Path();

    /*
    Montagem da linha do gráfico.
    */
    for (int i = 0;
        i < pontos.length;
        i++) {
      final x =
          size.width *
              i /
              (pontos.length - 1);

      final y =
          size.height * pontos[i];

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    /*
    Desenha gráfico na tela.
    */
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) =>
      false;
}