// Isabela

import 'package:flutter/material.dart';

import 'startups/startup_list_page.dart';
import 'tokens/minha_carteira_page.dart';
import 'tokens/balcao_tokens_page.dart';
import 'tokens/dashboard_page.dart';

/*
Tela principal do sistema MesclaInvest.

Responsável por:
- controlar a navegação principal da aplicação;
- gerenciar as abas inferiores;
- alternar entre as telas principais do sistema;
- manter o estado das páginas utilizando IndexedStack.

Abas disponíveis:
1. Catálogo de startups;
2. Carteira do usuário;
3. Balcão de compra e venda;
4. Dashboard financeiro.
*/

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/*
State responsável pelo controle das abas e navegação principal.

Gerencia:
- aba atualmente selecionada;
- lista de telas exibidas;
- atualização visual do BottomNavigationBar.
*/

class _HomePageState extends State<HomePage> {
  // Índice da aba atualmente selecionada
  int _abaSelecionada = 0;

  /*
  Lista de telas principais da aplicação.

  IndexedStack mantém o estado das telas mesmo ao trocar de aba,
  evitando recarregamentos desnecessários.
  */
  final List<Widget> _telas = const [
    StartupListPage(),
    MinhaCarteiraPage(),
    BalcaoTokensPage(),
    DashboardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      IndexedStack exibe apenas a tela selecionada,
      mas preserva o estado das demais páginas.
      */
      body: IndexedStack(
        index: _abaSelecionada,
        children: _telas,
      ),

      /*
      Barra de navegação inferior principal do aplicativo.

      Responsável pela navegação entre:
      - catálogo;
      - carteira;
      - balcão;
      - dashboard.
      */
      bottomNavigationBar: BottomNavigationBar(
        // Índice atualmente selecionado
        currentIndex: _abaSelecionada,

        /*
        Atualiza a aba selecionada ao clicar em um item.
        */
        onTap: (i) => setState(() => _abaSelecionada = i),

        // Cor do item ativo
        selectedItemColor: const Color(0xFF6C63FF),

        // Cor dos itens não selecionados
        unselectedItemColor: const Color(0xFF999999),

        // Cor de fundo da barra
        backgroundColor: Colors.white,

        // Sombra da barra inferior
        elevation: 8,

        // Mantém todos os itens visíveis simultaneamente
        type: BottomNavigationBarType.fixed,

        // Estilo do texto do item selecionado
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),

        /*
        Itens de navegação do aplicativo.
        Cada item representa uma área principal do sistema.
        */
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