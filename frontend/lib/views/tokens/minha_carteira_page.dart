//isa
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MinhaCarteiraPage extends StatelessWidget {
  const MinhaCarteiraPage({super.key});

  String _formatarMoeda(dynamic valor) {
    final numero = double.tryParse((valor ?? 0).toString()) ?? 0;
    return 'R\$ ${numero.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Minha Carteira'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Você precisa estar logado.')),
      );
    }

    final carteiraQuery = FirebaseFirestore.instance
        .collection('carteiras')
        .where('usuarioId', isEqualTo: user.uid);

    final usuarioRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Carteira'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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
      body: Column(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: usuarioRef.snapshots(),
            builder: (context, snapshot) {
              double saldo = 0;

              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                saldo = double.tryParse((data['saldo'] ?? 0).toString()) ?? 0;
              }

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo disponível',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatarMoeda(saldo),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: carteiraQuery.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar carteira: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text('Você ainda não possui tokens na carteira.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    final nomeStartup = (data['nomeStartup'] ?? 'Startup')
                        .toString();

                    final quantidade = data['quantidade'] ?? 0;
                    final precoMedio = data['precoMedio'] ?? 0;
                    final totalInvestido = data['totalInvestido'] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(Icons.token, color: Colors.blue),
                        ),
                        title: Text(
                          nomeStartup,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Quantidade: $quantidade token(s)\n'
                          'Preço médio: ${_formatarMoeda(precoMedio)}\n'
                          'Total investido: ${_formatarMoeda(totalInvestido)}',
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
