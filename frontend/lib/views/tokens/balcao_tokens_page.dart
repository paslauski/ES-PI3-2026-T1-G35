//isa
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/token_service.dart';

class BalcaoTokensPage extends StatefulWidget {
  const BalcaoTokensPage({super.key});

  @override
  State<BalcaoTokensPage> createState() => _BalcaoTokensPageState();
}

class _BalcaoTokensPageState extends State<BalcaoTokensPage> {
  final TextEditingController _quantidadeController = TextEditingController(
    text: '1',
  );

  String? _startupId;
  String _nomeStartup = '';
  double _precoToken = 10.0;
  String _tipoOperacao = 'compra';
  bool _carregando = false;

  @override
  void dispose() {
    _quantidadeController.dispose();
    super.dispose();
  }

  double _converterNumero(dynamic valor, double padrao) {
    if (valor == null) return padrao;

    final texto = valor
        .toString()
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.');

    return double.tryParse(texto) ?? padrao;
  }

  Future<void> _executarOperacao() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _mostrarMensagem('Usuário não está logado.', erro: true);
      return;
    }

    if (_startupId == null) {
      _mostrarMensagem('Selecione uma startup.', erro: true);
      return;
    }

    final quantidade = int.tryParse(_quantidadeController.text.trim()) ?? 0;

    if (quantidade <= 0) {
      _mostrarMensagem('Informe uma quantidade válida.', erro: true);
      return;
    }

    setState(() => _carregando = true);

    try {
      final service = TokenService();

      if (_tipoOperacao == 'compra') {
        await service.comprarTokens(
          usuarioId: user.uid,
          startupId: _startupId!,
          quantidade: quantidade,
          precoToken: _precoToken,
          nomeStartup: _nomeStartup,
        );
      } else {
        await service.venderTokens(
          usuarioId: user.uid,
          startupId: _startupId!,
          quantidade: quantidade,
          precoToken: _precoToken,
          nomeStartup: _nomeStartup,
        );
      }

      _mostrarMensagem(
        _tipoOperacao == 'compra'
            ? 'Compra realizada com sucesso!'
            : 'Venda realizada com sucesso!',
      );
    } catch (e) {
      _mostrarMensagem('Erro: $e', erro: true);
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  void _mostrarMensagem(String texto, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: erro ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startupsRef = FirebaseFirestore.instance.collection('startups');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Balcão de Tokens'),
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
        stream: startupsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final startups = snapshot.data?.docs ?? [];

          if (startups.isEmpty) {
            return const Center(child: Text('Nenhuma startup cadastrada.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Negociação simulada',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _startupId,
                  decoration: const InputDecoration(
                    labelText: 'Startup',
                    border: OutlineInputBorder(),
                  ),
                  items: startups.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final nome = (data['nome'] ?? 'Sem nome').toString();

                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(nome),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final doc = startups.firstWhere((item) => item.id == value);
                    final data = doc.data() as Map<String, dynamic>;

                    setState(() {
                      _startupId = doc.id;
                      _nomeStartup = (data['nome'] ?? '').toString();
                      _precoToken = _converterNumero(data['preco_token'], 10.0);
                    });
                  },
                ),

                const SizedBox(height: 16),

                Text(
                  'Preço do token: R\$ ${_precoToken.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _quantidadeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade de tokens',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Tipo de operação',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                RadioListTile<String>(
                  title: const Text('Comprar'),
                  value: 'compra',
                  groupValue: _tipoOperacao,
                  onChanged: (value) {
                    setState(() => _tipoOperacao = value!);
                  },
                ),

                RadioListTile<String>(
                  title: const Text('Vender'),
                  value: 'venda',
                  groupValue: _tipoOperacao,
                  onChanged: (value) {
                    setState(() => _tipoOperacao = value!);
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _carregando ? null : _executarOperacao,
                    icon: Icon(
                      _tipoOperacao == 'compra'
                          ? Icons.shopping_cart
                          : Icons.sell,
                    ),
                    label: Text(
                      _carregando
                          ? 'Processando...'
                          : _tipoOperacao == 'compra'
                          ? 'Comprar tokens'
                          : 'Vender tokens',
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Operações simuladas para fins acadêmicos.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
