// Mateus - Tela de catálogo de startups
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/startup_model.dart';
import 'startup_detail_page.dart';

class StartupListPage extends StatefulWidget {
  const StartupListPage({super.key});

  @override
  State<StartupListPage> createState() => _StartupListPageState();
}

class _StartupListPageState extends State<StartupListPage> {
  String _filtroEstagio = 'Todos';
  String _busca = '';
  final List<String> _estagios = ['Todos', 'nova', 'em operação', 'em expansão'];

  // ── ABRE PAINEL DO USUÁRIO ───────────────────────────────────
  // Busca os dados do usuário no Firestore e exibe num painel deslizante
  Future<void> _abrirPainelUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Busca dados extras do Firestore (nome, data de cadastro)
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    final dados = doc.data();
    final nome = dados?['nome'] ?? 'Não informado';
    final dataCadastro = dados?['dataCriacao'] ?? '';

    if (!mounted) return;

    // Exibe painel deslizante de baixo para cima
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min, // painel só do tamanho do conteúdo
            children: [
              // Linha de arraste visual
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              // Ícone grande do usuário
              const CircleAvatar(
                radius: 36,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Nome
              Text(
                nome,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),

              // E-mail
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.email_outlined,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    user.email ?? 'Não informado',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Data de cadastro
              if (dataCadastro.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Cadastrado em: $dataCadastro',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),

              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 12),

              // Botão SAIR DA CONTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx); // fecha o painel
                    await _fazerLogout();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair da conta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ── LOGOUT ──────────────────────────────────────────────────
  Future<void> _fazerLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      // Volta para o login e apaga todas as telas da memória
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao sair: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Startups'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          // NOVO: ícone de usuário no canto direito
          // Antes tinha só o ícone de logout direto
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            tooltip: 'Meu perfil',
            onPressed: _abrirPainelUsuario, // abre o painel com dados + logout
          ),
        ],
      ),

      body: Column(
        children: [
          // Campo de busca
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nome, setor...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => setState(() => _busca = v.toLowerCase()),
            ),
          ),

          // Filtro por estágio
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _estagios.map((estagio) {
                final selecionado = _filtroEstagio == estagio;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(estagio),
                    selected: selecionado,
                    selectedColor: Colors.blue,
                    labelStyle: TextStyle(
                      color: selecionado ? Colors.white : Colors.black87,
                      fontWeight: selecionado
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (_) =>
                        setState(() => _filtroEstagio = estagio),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 6),

          // Lista do Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('startups')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar startups.\nTente novamente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade400),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('Nenhuma startup cadastrada ainda.'));
                }

                final startups = snapshot.data!.docs
                    .map((doc) => Startup.fromFirestore(
                        doc.data() as Map<String, dynamic>, doc.id))
                    .where((s) {
                  final passaEstagio = _filtroEstagio == 'Todos' ||
                      s.estagio == _filtroEstagio;
                  final passaBusca = _busca.isEmpty ||
                      s.nome.toLowerCase().contains(_busca) ||
                      s.descricao.toLowerCase().contains(_busca) ||
                      s.setor.toLowerCase().contains(_busca);
                  return passaEstagio && passaBusca;
                }).toList();

                if (startups.isEmpty) {
                  return const Center(
                      child:
                          Text('Nenhuma startup encontrada com esse filtro.'));
                }

                return ListView.builder(
                  itemCount: startups.length,
                  itemBuilder: (context, index) {
                    final s = startups[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Clique no card abre a tela detalhada
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StartupDetailPage(startup: s),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                radius: 24,
                                child: Text(
                                  s.nome.isNotEmpty ? s.nome[0] : '?',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.nome,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text(s.descricao,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade100,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(s.estagio,
                                              style: const TextStyle(
                                                  fontSize: 11)),
                                        ),
                                        const SizedBox(width: 6),
                                        Text('📍 ${s.setor}',
                                            style:
                                                const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('💰 ${s.capital}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: Colors.grey),
                            ],
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