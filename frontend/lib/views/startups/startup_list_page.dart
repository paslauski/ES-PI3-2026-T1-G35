// Mateus - Catálogo de startups
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
  final List<String> _estagios = [
    'Todos',
    'nova',
    'em operação',
    'em expansão'
  ];

  Future<void> _abrirPainelUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    final dados = doc.data();
    final nome = dados?['nome'] ?? 'Não informado';
    final dataCadastro = dados?['dataCadastro'] ?? '';
    final saldo = (dados?['saldo'] ?? 0).toDouble();
    final saldoFormatado =
        'R\$ ${saldo.toStringAsFixed(2).replaceAll('.', ',')}';

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),

            // Avatar
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A2E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 14),

            Text(nome,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 4),

            Text(user.email ?? '',
                style:
                    const TextStyle(color: Color(0xFF888888), fontSize: 13)),

            if (dataCadastro.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Cadastrado em: $dataCadastro',
                  style: const TextStyle(
                      color: Color(0xFFAAAAAA), fontSize: 12)),
            ],

            const SizedBox(height: 20),

            // Card saldo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C897), Color(0xFF00A67E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('💰 Carteira MesclaInvest',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(saldoFormatado,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  const Text('saldo disponível',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Botão sair
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
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _fazerLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao sair: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MesclaInvest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            onPressed: _abrirPainelUsuario,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Busca
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar startups...',
                prefixIcon:
                    Icon(Icons.search, color: Color(0xFFAAAAAA)),
              ),
              onChanged: (v) => setState(() => _busca = v.toLowerCase()),
            ),
          ),

          // Filtros
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _estagios.map((estagio) {
                final sel = _filtroEstagio == estagio;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(estagio,
                        style: TextStyle(
                          color: sel
                              ? Colors.white
                              : const Color(0xFF555555),
                          fontWeight: sel
                              ? FontWeight.w600
                              : FontWeight.normal,
                        )),
                    selected: sel,
                    selectedColor: const Color(0xFF6C63FF),
                    onSelected: (_) =>
                        setState(() => _filtroEstagio = estagio),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Lista
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('startups')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('Nenhuma startup cadastrada.'));
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
                      child: Text('Nenhuma startup com esse filtro.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: startups.length,
                  itemBuilder: (context, index) {
                    final s = startups[index];
                    return _StartupCard(
                      startup: s,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                StartupDetailPage(startup: s)),
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

// ── CARD DA STARTUP ───────────────────────────────────────────
class _StartupCard extends StatelessWidget {
  final Startup startup;
  final VoidCallback onTap;

  const _StartupCard({required this.startup, required this.onTap});

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
    final cor = _corEstagio(startup.estagio);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      startup.nome.isNotEmpty ? startup.nome[0] : '?',
                      style: TextStyle(
                          color: cor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Conteúdo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(startup.nome,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 4),
                      Text(startup.descricao,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFF888888), fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: cor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(startup.estagio,
                                style: TextStyle(
                                    color: cor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                          Text(startup.setor,
                              style: const TextStyle(
                                  color: Color(0xFFAAAAAA),
                                  fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Ícone de vídeo se tiver videoUrl
                      Row(
                        children: [
                          Text(startup.capital,
                              style: const TextStyle(
                                  color: Color(0xFF00C897),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          if (startup.videoUrl.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.play_circle_outline,
                                color: Color(0xFF6C63FF), size: 15),
                            const SizedBox(width: 2),
                            const Text('vídeo',
                                style: TextStyle(
                                    color: Color(0xFF6C63FF),
                                    fontSize: 11)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}