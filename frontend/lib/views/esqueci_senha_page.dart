// Isabela

// 📌 VIEW = tela visual para recuperação de senha

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

// StatefulWidget = tela que muda de estado
class EsqueciSenhaPage extends StatefulWidget {
  const EsqueciSenhaPage({super.key});

  @override
  State<EsqueciSenhaPage> createState() => _EsqueciSenhaPageState();
}

// State = lógica da tela
class _EsqueciSenhaPageState extends State<EsqueciSenhaPage> {
  // controller = pega o que o usuário digita
  final _emailController = TextEditingController();

  // service = conversa com Firebase
  final AuthService _authService = AuthService();

  bool _carregando = false;

  @override
  void dispose() {
    // libera memória quando sair da tela
    _emailController.dispose();
    super.dispose();
  }

  // 🔹 MÉTODO PRINCIPAL
  Future<void> _enviarEmail() async {
    // validação simples
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o e-mail'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      // chama o Firebase para enviar o email de recuperação
      await _authService.recuperarSenha(_emailController.text.trim());

      if (!mounted) return;

      // mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email de recuperação enviado!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // 🔹 volta para a tela anterior (login) depois de 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.pop(context);
      });
    } catch (e) {
      if (!mounted) return;

      // mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (!mounted) return;
      setState(() => _carregando = false);
    }
  }

  // 🔹 padrão visual do campo
  InputDecoration _decoracao(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Digite seu e-mail para receber o link de recuperação',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _decoracao('E-mail'),
            ),
            const SizedBox(height: 20),

            _carregando
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _enviarEmail,
                      child: const Text('ENVIAR'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
