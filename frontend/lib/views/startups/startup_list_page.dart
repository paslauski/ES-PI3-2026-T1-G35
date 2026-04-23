// Mateus - Tela de catálogo de startups
// Busca startups do Firestore e exibe em lista com filtro e busca

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/startup_model.dart';

class StartupListPage extends StatefulWidget {
  const StartupListPage({super.key});

  @override
  State<StartupListPage> createState() => _StartupListPageState();
}

class _StartupListPageState extends State<StartupListPage> {
  // Controla qual estágio está selecionado no filtro
  String _filtroEstagio = 'Todos';

  // Controla o texto digitado na busca
  String _busca = '';

  // Opções de filtro por estágio
  final List<String> _estagios = ['Todos', 'Pre-seed', 'Seed', 'Series A'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Startups'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // remove botão de voltar
      ),
      body: Column(
        children: [
          // ── CAMPO DE BUSCA POR TEXTO ──────────────────────────
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

          // ── FILTRO POR ESTÁGIO ────────────────────────────────
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

          // ── LISTA VINDA DO FIRESTORE ──────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('startups')
                  .snapshots(),
              builder: (context, snapshot) {
                // Carregando...
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Coleção vazia
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma startup cadastrada ainda.'),
                  );
                }

                // Converte documentos e aplica filtros
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

                // Sem resultados com filtro aplicado
                if (startups.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma startup encontrada com esse filtro.'),
                  );
                }

                // Lista de cards
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
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
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
                        title: Text(
                          s.nome,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              s.descricao,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                // Chip com estágio
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    s.estagio,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '📍 ${s.setor}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '💰 ${s.capital}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        isThreeLine: true,
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