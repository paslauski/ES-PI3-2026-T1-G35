// Mateus - Tela da Carteira
import 'package:flutter/material.dart';

class CarteiraPage extends StatelessWidget {
  const CarteiraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Carteira'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Carteira — em breve'),
      ),
    );
  }
}
