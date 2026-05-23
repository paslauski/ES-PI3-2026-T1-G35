// isa
// Tela inicial do app depois do login
// Aqui ficam os atalhos principais do MesclaInvest

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'startups/startup_list_page.dart';
import 'tokens/balcao_tokens_page.dart';
import 'tokens/minhas_negociacoes_page.dart';
import 'tokens/minha_carteira_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // 🔹 Faz logout do Firebase e volta para a tela de login
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MesclaInvest'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Saudação do usuário logado
            Text(
              'Olá!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              user?.email ?? 'Usuário logado',
              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 24),

            // 🔹 Acesso ao catálogo de startups
            _cardPrincipal(
              context: context,
              titulo: 'Catálogo de Startups',
              descricao: 'Visualize startups cadastradas no ecossistema.',
              icone: Icons.business,
              cor: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StartupListPage()),
                );
              },
            ),

            const SizedBox(height: 12),

            // 🔹 Acesso ao balcão de compra e venda de tokens
            _cardPrincipal(
              context: context,
              titulo: 'Balcão de Tokens',
              descricao: 'Compre e venda tokens de forma simulada.',
              icone: Icons.currency_exchange,
              cor: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BalcaoTokensPage()),
                );
              },
            ),

            const SizedBox(height: 12),

            // 🔹 Acesso ao histórico de transações
            _cardPrincipal(
              context: context,
              titulo: 'Minhas Negociações',
              descricao: 'Veja o histórico das suas compras e vendas.',
              icone: Icons.receipt_long,
              cor: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MinhasNegociacoesPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // 🔹 Acesso à carteira do investidor
            _cardPrincipal(
              context: context,
              titulo: 'Minha Carteira',
              descricao: 'Veja seus tokens comprados e saldo disponível.',
              icone: Icons.account_balance_wallet,
              cor: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MinhaCarteiraPage()),
                );
              },
            ),

            const SizedBox(height: 24),

            // 🔹 Área de resumo visual
            const Text(
              'Resumo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _miniCard(
                    titulo: 'Startups',
                    valor: 'Ver',
                    icone: Icons.rocket_launch,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _miniCard(
                    titulo: 'Tokens',
                    valor: 'Simulado',
                    icone: Icons.token,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _miniCard(
                    titulo: 'Carteira',
                    valor: 'Disponível',
                    icone: Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _miniCard(
                    titulo: 'Dashboard',
                    valor: 'Em breve',
                    icone: Icons.show_chart,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 🔹 Aviso acadêmico
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: const Text(
                'Todas as operações são simuladas para fins acadêmicos.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Card grande clicável usado nos atalhos principais
  Widget _cardPrincipal({
    required BuildContext context,
    required String titulo,
    required String descricao,
    required IconData icone,
    required Color cor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: cor.withOpacity(0.12),
                child: Icon(icone, color: cor),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      descricao,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Card pequeno usado na área de resumo
  Widget _miniCard({
    required String titulo,
    required String valor,
    required IconData icone,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: Colors.blue),

          const SizedBox(height: 10),

          Text(
            titulo,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),

          const SizedBox(height: 4),

          Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
