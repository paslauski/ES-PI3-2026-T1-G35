// Mateus - Menu principal com navegação por abas
import 'package:flutter/material.dart';
import 'startups/startup_list_page.dart';
import 'tokens/minha_carteira_page.dart';
import 'tokens/dashboard_page.dart';
import 'tokens/balcao_tokens_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _abaSelecionada = 0;

  // Lista de telas — a ordem bate com os ícones do menu
  final List<Widget> _telas = const [
  StartupListPage(),
  MinhaCarteiraPage(),
  BalcaoTokensPage(),
  DashboardPage(),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mostra a tela correspondente à aba selecionada
      body: IndexedStack(
        index: _abaSelecionada,
        children: _telas,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _abaSelecionada,
        onTap: (index) => setState(() => _abaSelecionada = index),
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.rocket_launch_outlined),
            activeIcon: Icon(Icons.rocket_launch),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Carteira',
          ),
          BottomNavigationBarItem(        
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Balcão',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Dashboard',
          ),
        ],
      ),
    );
  }
}
