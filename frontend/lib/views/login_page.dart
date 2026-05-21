// Isabela

// 📌 IMPORTANTE
// VIEW = tela visual do app (o que o usuário vê)

import 'package:flutter/material.dart';

// 🔹 importa o service (responsável por falar com Firebase)
import '../services/auth_service.dart';

// 🔹 telas que vamos navegar
import 'cadastro_page.dart';
import 'esqueci_senha_page.dart';
import 'main_page.dart';

// 🔹 StatefulWidget = tela que pode mudar (estado dinâmico)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // Mateus - Traduz erros do Firebase para português
  String _traduzirErro(String erro) {
    if (erro.contains('user-not-found') || erro.contains('invalid-credential')) {
      return 'E-mail ou senha incorretos. Verifique seus dados.';
    } else if (erro.contains('wrong-password')) {
      return 'Senha incorreta. Tente novamente.';
    } else if (erro.contains('invalid-email')) {
      return 'O e-mail informado não é válido.';
    } else if (erro.contains('user-disabled')) {
      return 'Esta conta foi desativada. Entre em contato com o suporte.';
    } else if (erro.contains('too-many-requests')) {
      return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
    } else if (erro.contains('network-request-failed')) {
      return 'Sem conexão com a internet. Verifique sua rede.';
    }
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    try {
      await _authService.login(
        _emailController.text.trim(),
        _senhaController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login realizado com sucesso!'),
          backgroundColor: Color(0xFF00C897),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      });
    } catch (e) {
      if (!mounted) return;
      final mensagem = _traduzirErro(e.toString());
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
      if (mounted) setState(() => _carregando = false);
    }
  }

  String? _validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o e-mail';
    return null;
  }

  String? _validarSenha(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe a senha';
    if (value.length < 6) return 'Senha deve ter pelo menos 6 caracteres';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.account_balance,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'MesclaInvest',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Entre com seu e-mail e senha',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 14),
                  ),
                  const SizedBox(height: 36),

                  // Campo e-mail
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'E-mail',
                      prefixIcon:
                          Icon(Icons.email_outlined, color: Color(0xFFAAAAAA)),
                    ),
                    validator: _validarEmail,
                  ),
                  const SizedBox(height: 14),

                  // Campo senha
                  TextFormField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Senha',
                      prefixIcon:
                          Icon(Icons.lock_outlined, color: Color(0xFFAAAAAA)),
                    ),
                    validator: _validarSenha,
                  ),
                  const SizedBox(height: 24),

                  // Botão entrar
                  _carregando
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _fazerLogin,
                            child: const Text('ENTRAR'),
                          ),
                        ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EsqueciSenhaPage())),
                    child: const Text('Esqueci minha senha',
                        style: TextStyle(color: Color(0xFF6C63FF))),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CadastroPage())),
                    child: const Text('Não tem conta? Criar cadastro',
                        style: TextStyle(color: Color(0xFF6C63FF))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}