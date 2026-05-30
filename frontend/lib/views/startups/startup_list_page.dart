// Mateus - Catálogo de startups

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/startup_model.dart';
import 'startup_detail_page.dart';

/*
Tela responsável pelo catálogo principal de startups.

Funcionalidades:
- listar startups cadastradas no Firestore;
- buscar startups por nome, descrição ou setor;
- filtrar startups por estágio;
- abrir detalhes completos da startup;
- exibir painel do usuário autenticado;
- realizar logout da aplicação.
*/

class StartupListPage extends StatefulWidget {
  const StartupListPage({super.key});

  @override
  State<StartupListPage> createState() => _StartupListPageState();
}

/*
State responsável pelo gerenciamento:
- filtros da listagem;
- busca textual;
- dados do usuário;
- integração com Firestore;
- renderização dinâmica da interface.
*/

class _StartupListPageState extends State<StartupListPage> {
  // Filtro atualmente selecionado
  String _filtroEstagio = 'Todos';

  // Texto digitado no campo de busca
  String _busca = '';

  // Lista de estágios disponíveis para filtragem
  final List<String> _estagios = [
    'Todos',
    'nova',
    'em operação',
    'em expansão',
  ];

  /*
  Abre o painel inferior do usuário autenticado.

  Exibe:
  - nome;
  - e-mail;
  - data de cadastro;
  - saldo disponível;
  - botão de logout.
  */
  Future<void> _abrirPainelUsuario() async {
    // Obtém usuário autenticado
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    // Busca dados do usuário no Firestore
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    final dados = doc.data();

    // Recupera informações do usuário
    final nome = dados?['nome'] ?? 'Não informado';
    final dataCadastro = dados?['dataCadastro'] ?? '';

    // Recupera saldo financeiro
    final saldo = (dados?['saldo'] ?? 0).toDouble();

    // Formata saldo em moeda brasileira
    final saldoFormatado =
        'R\$ ${saldo.toStringAsFixed(2).replaceAll('.', ',')}';

    if (!mounted) return;

    /*
    Exibe painel inferior modal com dados da conta.
    */
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (ctx) => SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),

          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              /*
              Indicador visual superior do modal.
              */
              Container(
                width: 40,
                height: 4,

                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 24),

              /*
              Avatar padrão do usuário.
              */
              Container(
                width: 72,
                height: 72,

                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A2E),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 36,
                ),
              ),

              const SizedBox(height: 14),

              /*
              Nome do usuário.
              */
              Text(
                nome,

                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),

              const SizedBox(height: 4),

              /*
              E-mail da conta autenticada.
              */
              Text(
                user.email ?? '',

                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 13,
                ),
              ),

              /*
              Data de cadastro da conta.
              */
              if (dataCadastro.isNotEmpty) ...[
                const SizedBox(height: 4),

                Text(
                  'Cadastrado em: $dataCadastro',

                  style: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 12,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              /*
              Card financeiro da carteira do usuário.
              */
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00C897),
                      Color(0xFF00A67E),
                    ],

                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(16),
                ),

                child: Column(
                  children: [
                    const Text(
                      '💰 Carteira MesclaInvest',

                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /*
                    Saldo disponível do usuário.
                    */
                    Text(
                      saldoFormatado,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Text(
                      'saldo disponível',

                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              /*
              Botão Responsavél por depositar saldo
              */
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _abrirDepositarSaldo();
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Depositar Saldo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              /*
              Botão responsável pelo logout da conta.
              */
              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);

                    await _fazerLogout();
                  },

                  icon: const Icon(Icons.logout),

                  label: const Text('Sair da conta'),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D4D),
                    foregroundColor: Colors.white,

                    padding: const EdgeInsets.symmetric(vertical: 14),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
  
  /*
Abre diálogo para o usuário depositar saldo fictício na carteira.
*/
Future<void> _abrirDepositarSaldo() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final controller = TextEditingController();

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        '💰 Depositar Saldo',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Informe o valor a depositar na sua carteira simulada:',
            style: TextStyle(color: Color(0xFF666666), fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: 'R\$ ',
              hintText: '0,00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            final texto = controller.text
                .replaceAll('R\$', '')
                .replaceAll(' ', '')
                .replaceAll(',', '.');

            final valor = double.tryParse(texto) ?? 0;

            if (valor <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Informe um valor válido.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // Busca saldo atual e soma o valor depositado
            final doc = await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(user.uid)
                .get();

            final saldoAtual =
                (doc.data()?['saldo'] ?? 0).toDouble();

            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(user.uid)
                .update({'saldo': saldoAtual + valor});

            if (ctx.mounted) Navigator.pop(ctx);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '✅ R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')} depositado com sucesso!',
                  ),
                  backgroundColor: const Color(0xFF00C897),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );
}
  /*
  Realiza logout do Firebase Authentication
  e retorna usuário para a tela inicial.
  */
  Future<void> _fazerLogout() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      // Exibe erro caso logout falhe
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao sair: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /*
  Define cor visual baseada no estágio da startup.
  */
  Color _corEstagio(String estagio) {
    switch (estagio) {
      case 'nova':
        return const Color(0xFF6C63FF);

      case 'em operação':
        return const Color(0xFF00C897);

      case 'em expansão':
        return const Color(0xFFFF9500);

      default:
        return const Color(0xFF888888);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      Barra superior principal da tela.
      */
      appBar: AppBar(
        title: const Text('MesclaInvest'),

        automaticallyImplyLeading: false,

        actions: [
          /*
          Botão para retornar à HomePage.
          */
          IconButton(
            icon: const Icon(
              Icons.home_outlined,
              size: 26,
            ),

            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (r) => false,
              );
            },
          ),

          /*
          Botão responsável por abrir painel do usuário.
          */
          IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              size: 26,
            ),

            onPressed: _abrirPainelUsuario,
          ),

          const SizedBox(width: 4),
        ],
      ),

      body: Column(
        children: [
          /*
          Campo de busca de startups.
          */
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),

            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar startups...',

                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xFFAAAAAA),
                ),
              ),

              onChanged: (v) {
                setState(() => _busca = v.toLowerCase());
              },
            ),
          ),

          /*
          Filtros horizontais por estágio.
          */
          SizedBox(
            height: 48,

            child: ListView(
              scrollDirection: Axis.horizontal,

              padding: const EdgeInsets.symmetric(horizontal: 16),

              children: _estagios.map((e) {
                final sel = _filtroEstagio == e;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),

                  child: ChoiceChip(
                    label: Text(
                      e,

                      style: TextStyle(
                        color: sel
                            ? Colors.white
                            : const Color(0xFF555555),

                        fontWeight: sel
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),

                    selected: sel,

                    selectedColor: const Color(0xFF6C63FF),

                    onSelected: (_) {
                      setState(() => _filtroEstagio = e);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          /*
          StreamBuilder responsável por atualizar lista em tempo real
          com dados vindos do Firestore.
          */
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('startups')
                  .snapshots(),

              builder: (context, snapshot) {
                /*
                Exibe loading enquanto dados carregam.
                */
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                /*
                Exibe mensagem caso não existam startups.
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
                Converte documentos do Firestore em objetos Startup.
                */
                final startups = snapshot.data!.docs
                    .map(
                      (doc) => Startup.fromFirestore(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      ),
                    )
                    .where((s) {
                  /*
                  Aplica filtros de estágio e busca textual.
                  */
                  final passaEstagio =
                      _filtroEstagio == 'Todos' ||
                          s.estagio == _filtroEstagio;

                  final passaBusca =
                      _busca.isEmpty ||
                          s.nome.toLowerCase().contains(_busca) ||
                          s.descricao.toLowerCase().contains(_busca) ||
                          s.setor.toLowerCase().contains(_busca);

                  return passaEstagio && passaBusca;
                }).toList();

                /*
                Exibe mensagem caso filtro não encontre resultados.
                */
                if (startups.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma startup com esse filtro.',
                    ),
                  );
                }

                /*
                Lista principal de startups.
                */
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    16,
                  ),

                  itemCount: startups.length,

                  itemBuilder: (context, index) {
                    final s = startups[index];

                    final cor = _corEstagio(s.estagio);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),

                      child: Material(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(16),

                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),

                          /*
                          Abre tela de detalhes da startup.
                          */
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    StartupDetailPage(
                                  startup: s,
                                ),
                              ),
                            );
                          },

                          child: Padding(
                            padding: const EdgeInsets.all(16),

                            child: Row(
                              children: [
                                /*
                                Ícone visual da startup.
                                */
                                Container(
                                  width: 48,
                                  height: 48,

                                  decoration: BoxDecoration(
                                    color:
                                        cor.withOpacity(0.12),

                                    borderRadius:
                                        BorderRadius.circular(
                                      14,
                                    ),
                                  ),

                                  child: Center(
                                    child: Text(
                                      s.nome.isNotEmpty
                                          ? s.nome[0]
                                          : '?',

                                      style: TextStyle(
                                        color: cor,
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 14),

                                /*
                                Informações da startup.
                                */
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        s.nome,

                                        style: const TextStyle(
                                          fontWeight:
                                              FontWeight.w700,
                                          fontSize: 15,
                                          color:
                                              Color(0xFF1A1A2E),
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        s.descricao,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,

                                        style: const TextStyle(
                                          color:
                                              Color(0xFF888888),
                                          fontSize: 13,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      /*
                                      Informações complementares.
                                      */
                                      Row(
                                        children: [
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 3,
                                            ),

                                            decoration:
                                                BoxDecoration(
                                              color: cor.withOpacity(
                                                  0.1),

                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                20,
                                              ),
                                            ),

                                            child: Text(
                                              s.estagio,

                                              style: TextStyle(
                                                color: cor,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          Text(
                                            s.setor,

                                            style: const TextStyle(
                                              color:
                                                  Color(0xFFAAAAAA),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 4),

                                      /*
                                      Capital captado pela startup.
                                      */
                                      Text(
                                        s.capital,

                                        style: const TextStyle(
                                          color:
                                              Color(0xFF00C897),
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFFCCCCCC),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}