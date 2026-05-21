// Mateus - Tela detalhada + compra de tokens via backend
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../models/startup_model.dart';

class StartupDetailPage extends StatefulWidget {
  final Startup startup;
  const StartupDetailPage({super.key, required this.startup});

  @override
  State<StartupDetailPage> createState() => _StartupDetailPageState();
}

class _StartupDetailPageState extends State<StartupDetailPage> {
  bool _comprando = false;

  // ── CHAMA O BACKEND PARA COMPRAR ────────────────────────────
  Future<void> _comprarTokens(int quantidade) async {
    setState(() => _comprando = true);

    try {
      // Chama a Firebase Function 'comprarTokens' no backend
      final callable = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('comprarTokens');

      final result = await callable.call({
        'startupId': widget.startup.id,
        'quantidade': quantidade,
      });

      final novoSaldo = result.data['novoSaldo'];
      final saldoFormatado =
          'R\$ ${novoSaldo.toStringAsFixed(2).replaceAll('.', ',')}';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '✅ $quantidade tokens comprados! Novo saldo: $saldoFormatado'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      // Erro vindo do backend — traduz para português
      if (!mounted) return;
      String mensagem;
      switch (e.code) {
        case 'unauthenticated':
          mensagem = 'Você precisa estar logado.';
          break;
        case 'failed-precondition':
          mensagem = e.message ?? 'Saldo insuficiente.';
          break;
        case 'not-found':
          mensagem = 'Startup ou usuário não encontrado.';
          break;
        case 'invalid-argument':
          mensagem = 'Dados inválidos. Tente novamente.';
          break;
        default:
          mensagem = 'Erro inesperado. Tente novamente.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(mensagem)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _comprando = false);
    }
  }

  // ── DIÁLOGO DE COMPRA ────────────────────────────────────────
  void _abrirDialogoCompra() {
    int quantidade = 1;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final total = quantidade * widget.startup.precoToken;
          return AlertDialog(
            title: Text('Comprar — ${widget.startup.nome}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Preço por token: R\$ ${widget.startup.precoToken.toStringAsFixed(2).replaceAll('.', ',')}',
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantidade > 1) {
                          setDialogState(() => quantidade--);
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      '$quantidade',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => setDialogState(() => quantidade++),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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
                onPressed: () {
                  Navigator.pop(ctx);
                  _comprarTokens(quantidade);
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Confirmar',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.startup;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.nome),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      // Botão de compra fixo na parte de baixo
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: _comprando
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton.icon(
                onPressed: s.precoToken > 0 ? _abrirDialogoCompra : null,
                icon: const Icon(Icons.shopping_cart),
                label: Text(s.precoToken > 0
                    ? 'Comprar Tokens'
                    : 'Tokens não disponíveis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 32,
                  child: Text(
                    s.nome.isNotEmpty ? s.nome[0] : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.nome,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _badge(s.estagio, Colors.blue),
                          const SizedBox(width: 6),
                          _badge(s.status, Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Descrição
            _titulo('📋 Descrição do Projeto'),
            const SizedBox(height: 8),
            _caixa(s.descricao.isNotEmpty ? s.descricao : 'Sem descrição.'),

            const SizedBox(height: 16),

            if (s.sumarioExecutivo.isNotEmpty) ...[
              _titulo('📊 Sumário Executivo'),
              const SizedBox(height: 8),
              _caixa(s.sumarioExecutivo),
              const SizedBox(height: 16),
            ],

            // Dados financeiros
            _titulo('💰 Dados Financeiros'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  _linha('Capital já aportado', s.capital),
                  _linha('Total de tokens', s.totalTokens),
                  _linha(
                      'Preço por token',
                      'R\$ ${s.precoToken.toStringAsFixed(2).replaceAll('.', ',')}'),
                  _linha('Estágio', s.estagio),
                  _linha('Status', s.status),
                  _linha('Setor', s.setor),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Estrutura societária
            _titulo('🤝 Estrutura Societária'),
            const SizedBox(height: 8),
            s.socios.isEmpty
                ? _caixa('Estrutura societária não informada.')
                : Column(
                    children: s.socios.map((socio) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              socio.nome.isNotEmpty ? socio.nome[0] : '?',
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(socio.nome,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(socio.cargo),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(socio.percentual,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

            if (s.perguntasRespostas.isNotEmpty) ...[
              const SizedBox(height: 20),
              _titulo('❓ Perguntas e Respostas'),
              const SizedBox(height: 8),
              ...s.perguntasRespostas.asMap().entries.map((entry) {
                final isPergunta = entry.key % 2 == 0;
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPergunta
                        ? Colors.blue.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isPergunta
                          ? Colors.blue.shade200
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isPergunta ? '❓ ' : '💬 ',
                          style: const TextStyle(fontSize: 16)),
                      Expanded(child: Text(entry.value)),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _titulo(String t) => Text(t,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));

  Widget _caixa(String texto) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10)),
        child: Text(texto, style: const TextStyle(fontSize: 14)),
      );

  Widget _linha(String label, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.black54, fontSize: 13)),
            Flexible(
              child: Text(valor.isNotEmpty ? valor : '—',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  textAlign: TextAlign.right),
            ),
          ],
        ),
      );

  Widget _badge(String texto, Color cor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cor.withOpacity(0.5)),
        ),
        child: Text(texto,
            style: TextStyle(
                fontSize: 11, color: cor, fontWeight: FontWeight.w600)),
      );
}