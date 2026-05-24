// Mateus - Tela detalhada da Startup com Comprar e Vender

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/startup_model.dart';
import '../../services/token_service.dart';

/*
Tela responsável pela visualização detalhada da startup.

Funcionalidades:
- exibir informações completas da startup;
- mostrar dados financeiros;
- listar sócios e estrutura societária;
- exibir perguntas e respostas;
- permitir compra de tokens;
- permitir venda de tokens;
- integrar operações com Firebase.
*/

class StartupDetailPage extends StatefulWidget {
  // Dados da startup recebidos da tela anterior
  final Startup startup;

  const StartupDetailPage({
    super.key,
    required this.startup,
  });

  @override
  State<StartupDetailPage> createState() =>
      _StartupDetailPageState();
}

/*
State responsável pelo gerenciamento:
- compra e venda de tokens;
- controle de carregamento;
- exibição dos dados detalhados;
- diálogos financeiros;
- integração com TokenService.
*/

class _StartupDetailPageState
    extends State<StartupDetailPage> {
  // Controla estado de processamento das operações
  bool _processando = false;

  /*
  Abre diálogo de compra ou venda de tokens.

  Permite:
  - selecionar quantidade;
  - visualizar preço unitário;
  - calcular valor total;
  - confirmar operação.
  */
  Future<void> _abrirDialogo(String tipo) async {
    // Quantidade inicial de tokens
    int quantidade = 1;

    // Define preço do token
    final preco = double.tryParse(
      widget.startup.precoToken.toString()
          .replaceAll('R\$', '')
          .replaceAll(',', '.'),
      ) ??
      0.0;

    await showDialog(
      context: context,

      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) {
          // Calcula valor total da operação
          final total = quantidade * preco;

          // Define se operação é compra
          final isCompra = tipo == 'compra';

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            title: Text(
              isCompra
                  ? '🛒 Comprar Tokens'
                  : '📤 Vender Tokens',

              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            content: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                /*
                Nome da startup.
                */
                Text(
                  widget.startup.nome,

                  style: const TextStyle(
                    color: Color(0xFF888888),
                  ),
                ),

                const SizedBox(height: 4),

                /*
                Preço unitário do token.
                */
                Text(
                  'Preço por token: '
                  'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}',

                  style: const TextStyle(fontSize: 13),
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
                    Botão diminuir quantidade.
                    */
                    IconButton(
                      onPressed: quantidade > 1
                          ? () => setDialog(
                                () => quantidade--,
                              )
                          : null,

                      icon: const Icon(
                        Icons.remove_circle_outline,
                        size: 28,
                      ),

                      color: const Color(0xFF6C63FF),
                    ),

                    /*
                    Quantidade selecionada.
                    */
                    Text(
                      '$quantidade',

                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    /*
                    Botão aumentar quantidade.
                    */
                    IconButton(
                      onPressed: () {
                        setDialog(() => quantidade++);
                      },

                      icon: const Icon(
                        Icons.add_circle_outline,
                        size: 28,
                      ),

                      color: const Color(0xFF6C63FF),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /*
                Exibição do valor total da operação.
                */
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),

                  decoration: BoxDecoration(
                    color: isCompra
                        ? const Color(0xFF00C897)
                            .withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),

                    borderRadius:
                        BorderRadius.circular(12),
                  ),

                  child: Text(
                    'Total: '
                    'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,

                      color: isCompra
                          ? const Color(0xFF00C897)
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),

            actions: [
              /*
              Botão cancelar operação.
              */
              TextButton(
                onPressed: () => Navigator.pop(ctx),

                child: const Text(
                  'Cancelar',

                  style: TextStyle(
                    color: Color(0xFF888888),
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
                    preco,
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompra
                      ? const Color(0xFF00C897)
                      : Colors.red,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
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

  /*
  Executa compra ou venda de tokens.

  Responsável por:
  - validar usuário autenticado;
  - chamar TokenService;
  - exibir feedback visual;
  - tratar erros.
  */
  Future<void> _executarOperacao(
    String tipo,
    int quantidade,
    double preco,
  ) async {
    setState(() => _processando = true);

    try {
      // Obtém usuário autenticado
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception(
          'Usuário não está logado.',
        );
      }

      /*
      Operação de compra.
      */
      if (tipo == 'compra') {
        await TokenService().comprarTokens(
          usuarioId: user.uid,
          startupId: widget.startup.id,
          quantidade: quantidade,
          precoToken: preco,
          nomeStartup: widget.startup.nome,
        );
      }

      /*
      Operação de venda.
      */
      else {
        await TokenService().venderTokens(
          usuarioId: user.uid,
          startupId: widget.startup.id,
          quantidade: quantidade,
          precoToken: preco,
          nomeStartup: widget.startup.nome,
        );
      }

      if (!mounted) return;

      /*
      Exibe mensagem de sucesso.
      */
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            tipo == 'compra'
                ? '✅ $quantidade token(s) comprado(s)!'
                : '✅ $quantidade token(s) vendido(s)!',
          ),

          backgroundColor:
              const Color(0xFF00C897),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      /*
      Exibe mensagem de erro.
      */
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Erro: '
            '${e.toString().replaceAll('Exception: ', '')}',
          ),

          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Referência local da startup
    final s = widget.startup;

    return Scaffold(
      /*
      Barra superior da tela.
      */
      appBar: AppBar(
        title: Text(s.nome),

        actions: [
          /*
          Botão para retornar à HomePage.
          */
          IconButton(
            icon: const Icon(
              Icons.home_outlined,
            ),

            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (r) => false,
              );
            },
          ),
        ],
      ),

      /*
      Área inferior contendo botões de compra e venda.
      */
      bottomNavigationBar: _processando
          ? const LinearProgressIndicator()

          : Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                24,
              ),

              child: Row(
                children: [
                  /*
                  Botão comprar tokens.
                  */
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _abrirDialogo('compra');
                      },

                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                      ),

                      label: const Text(
                        'Comprar Tokens',
                      ),

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF00C897),

                        foregroundColor:
                            Colors.white,

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /*
                  Botão vender tokens.
                  */
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _abrirDialogo('venda');
                      },

                      icon: const Icon(
                        Icons.sell_outlined,
                      ),

                      label: const Text(
                        'Vender Tokens',
                      ),

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,

                        foregroundColor:
                            Colors.white,

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

      /*
      Conteúdo principal da tela.
      */
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            /*
            Cabeçalho principal da startup.
            */
            Row(
              children: [
                /*
                Ícone visual da startup.
                */
                Container(
                  width: 64,
                  height: 64,

                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF)
                        .withOpacity(0.12),

                    borderRadius:
                        BorderRadius.circular(18),
                  ),

                  child: Center(
                    child: Text(
                      s.nome.isNotEmpty
                          ? s.nome[0]
                          : '?',

                      style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontSize: 28,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                /*
                Informações principais da startup.
                */
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        s.nome,

                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,

                          color:
                              Color(0xFF1A1A2E),
                        ),
                      ),

                      const SizedBox(height: 6),

                      /*
                      Badges de estágio e status.
                      */
                      Row(
                        children: [
                          _badge(
                            s.estagio,
                            const Color(0xFF6C63FF),
                          ),

                          const SizedBox(width: 6),

                          _badge(
                            s.status,
                            const Color(0xFF00C897),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /*
            Seção de descrição do projeto.
            */
            _secao('📋 Descrição do Projeto'),

            const SizedBox(height: 8),

            _caixa(
              s.descricao.isNotEmpty
                  ? s.descricao
                  : 'Sem descrição.',
            ),

            /*
            Seção de sumário executivo.
            */
            if (s.sumarioExecutivo.isNotEmpty) ...[
              const SizedBox(height: 16),

              _secao('📊 Sumário Executivo'),

              const SizedBox(height: 8),

              _caixa(s.sumarioExecutivo),
            ],

            const SizedBox(height: 16),

            /*
            Seção financeira da startup.
            */
            _secao('💰 Dados Financeiros'),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(16),

                border: Border.all(
                  color: const Color(0xFFEEEEEE),
                ),
              ),

              child: Column(
                children: [
                  _linha(
                    'Capital já aportado',
                    s.capital,
                  ),

                  _linha(
                    'Total de tokens',
                    s.totalTokens,
                  ),

                  _linha(
                    'Preço por token',
                    'R\$ '
                    '${(double.tryParse(s.precoToken.toString()) ?? 0.0).toStringAsFixed(2).replaceAll('.', ',')}',
                  ),

                  _linha('Estágio', s.estagio),

                  _linha('Status', s.status),

                  _linha('Setor', s.setor),
                ],
              ),
            ),

            /*
            Estrutura societária da startup.
            */
            if (s.socios.isNotEmpty) ...[
              const SizedBox(height: 20),

              _secao('🤝 Estrutura Societária'),

              const SizedBox(height: 8),

              ...s.socios.map(
                (socio) => Card(
                  margin:
                      const EdgeInsets.only(
                    bottom: 8,
                  ),

                  child: ListTile(
                    /*
                    Avatar do sócio.
                    */
                    leading: CircleAvatar(
                      backgroundColor:
                          const Color(0xFF6C63FF)
                              .withOpacity(0.1),

                      child: Text(
                        socio.nome.isNotEmpty
                            ? socio.nome[0]
                            : '?',

                        style: const TextStyle(
                          color:
                              Color(0xFF6C63FF),

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    /*
                    Nome do sócio.
                    */
                    title: Text(
                      socio.nome,

                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    /*
                    Cargo do sócio.
                    */
                    subtitle: Text(socio.cargo),

                    /*
                    Participação societária.
                    */
                    trailing: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF6C63FF),

                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),

                      child: Text(
                        socio.percentual,

                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            /*
            Perguntas e respostas da startup.
            */
            if (s.perguntasRespostas
                .isNotEmpty) ...[
              const SizedBox(height: 20),

              _secao('❓ Perguntas e Respostas'),

              const SizedBox(height: 8),

              ...s.perguntasRespostas
                  .asMap()
                  .entries
                  .map((entry) {
                final isPergunta =
                    entry.key % 2 == 0;

                return Container(
                  width: double.infinity,

                  margin:
                      const EdgeInsets.only(
                    bottom: 8,
                  ),

                  padding:
                      const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: isPergunta
                        ? const Color(0xFF6C63FF)
                            .withOpacity(0.05)
                        : const Color(0xFFF5F5FA),

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),

                    border: Border.all(
                      color: isPergunta
                          ? const Color(0xFF6C63FF)
                              .withOpacity(0.2)
                          : const Color(0xFFEEEEEE),
                    ),
                  ),

                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        isPergunta
                            ? '❓ '
                            : '💬 ',

                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      Expanded(
                        child:
                            Text(entry.value),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /*
  Widget padrão para títulos de seção.
  */
  Widget _secao(String t) => Text(
        t,

        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A2E),
        ),
      );

  /*
  Widget padrão para caixas de texto.
  */
  Widget _caixa(String texto) => Container(
        width: double.infinity,

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(12),

          border: Border.all(
            color: const Color(0xFFEEEEEE),
          ),
        ),

        child: Text(
          texto,

          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF444444),
          ),
        ),
      );

  /*
  Widget padrão para linhas de informação.
  */
  Widget _linha(
    String label,
    String valor,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
        ),

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

          children: [
            Text(
              label,

              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 13,
              ),
            ),

            Flexible(
              child: Text(
                valor.isNotEmpty
                    ? valor
                    : '—',

                style: const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                  fontSize: 13,
                ),

                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );

  /*
  Widget visual de badge/status.
  */
  Widget _badge(
    String texto,
    Color cor,
  ) =>
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        ),

        decoration: BoxDecoration(
          color: cor.withOpacity(0.1),

          borderRadius:
              BorderRadius.circular(20),

          border: Border.all(
            color: cor.withOpacity(0.3),
          ),
        ),

        child: Text(
          texto,

          style: TextStyle(
            fontSize: 11,
            color: cor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}