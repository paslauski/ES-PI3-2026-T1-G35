// Isabela + Mateus

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'cadastro_page.dart';
import 'esqueci_senha_page.dart';
import 'home_page.dart';

/*
Tela de Login do sistema MesclaInvest.

Responsável por:
- autenticar usuários no Firebase;
- validar campos do formulário;
- tratar mensagens de erro;
- redirecionar o usuário após login;
- permitir acesso às telas de cadastro e recuperação de senha.
*/

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/*
State da tela de login.

Controla:
- estados visuais da interface;
- carregamento durante autenticação;
- validações do formulário;
- comunicação com o AuthService.
*/

class _LoginPageState extends State<LoginPage> {
  // Chave utilizada para validar o formulário
  final _formKey = GlobalKey<FormState>();

  // Controllers responsáveis por capturar os dados digitados
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  // Serviço responsável pela autenticação no Firebase
  final AuthService _authService = AuthService();

  // Controla estado de loading durante login
  bool _carregando = false;

  /*
  Libera os controllers da memória ao destruir a tela.
  Evita vazamentos de memória no aplicativo.
  */
  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  /*
  Traduz mensagens de erro do Firebase Authentication
  para mensagens amigáveis em português.
  */
  String _traduzirErro(String erro) {
    if (erro.contains('user-not-found') ||
        erro.contains('invalid-credential')) {
      return 'E-mail ou senha incorretos.';
    }

    if (erro.contains('wrong-password')) {
      return 'Senha incorreta.';
    }

    if (erro.contains('invalid-email')) {
      return 'E-mail inválido.';
    }

    if (erro.contains('user-disabled')) {
      return 'Conta desativada.';
    }

    if (erro.contains('too-many-requests')) {
      return 'Muitas tentativas. Aguarde.';
    }

    if (erro.contains('network-request-failed')) {
      return 'Sem conexão com a internet.';
    }

    return 'Erro inesperado. Tente novamente.';
  }

  /*
  Realiza autenticação do usuário.

  Fluxo:
  1. Valida formulário;
  2. Ativa loading;
  3. Executa login via Firebase;
  4. Exibe feedback visual;
  5. Redireciona para HomePage.
  */
  Future<void> _fazerLogin() async {
    // Impede login caso formulário seja inválido
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      // Executa login no Firebase Authentication
      await _authService.login(
        _emailController.text.trim(),
        _senhaController.text.trim(),
      );

      if (!mounted) return;

      // Feedback visual de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login realizado com sucesso!'),
          backgroundColor: Color(0xFF00C897),
        ),
      );

      // Aguarda pequeno intervalo antes da navegação
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomePage(),
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;

      // Exibe mensagem de erro personalizada
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  _traduzirErro(e.toString()),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      // Remove loading ao finalizar processo
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  /*
  Validação genérica para campos obrigatórios.
  */
  String? _validarObrigatorio(String? v, String campo) {
    if (v == null || v.trim().isEmpty) {
      return 'Informe $campo';
    }

    return null;
  }

  /*
  Validação específica da senha.
  */
  String? _validarSenha(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Informe a senha';
    }

    if (v.length < 6) {
      return 'Mínimo 6 caracteres';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),

            child: Form(
              key: _formKey,

              child: Column(
                children: [
                  /*
                  Logo principal da aplicação.
                  */
                  Container(
                    width: 80,
                    height: 80,

                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: const Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /*
                  Nome da plataforma.
                  */
                  const Text(
                    'MesclaInvest',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),

                  const SizedBox(height: 6),

                  /*
                  Texto auxiliar da tela.
                  */
                  const Text(
                    'Entre com seu e-mail e senha',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 36),

                  /*
                  Campo de e-mail.
                  */
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,

                    decoration: const InputDecoration(
                      hintText: 'E-mail',

                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),

                    validator: (v) =>
                        _validarObrigatorio(v, 'o e-mail'),
                  ),

                  const SizedBox(height: 14),

                  /*
                  Campo de senha.
                  */
                  TextFormField(
                    controller: _senhaController,
                    obscureText: true,

                    decoration: const InputDecoration(
                      hintText: 'Senha',

                      prefixIcon: Icon(
                        Icons.lock_outlined,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),

                    validator: _validarSenha,
                  ),

                  const SizedBox(height: 24),

                  /*
                  Botão de login.

                  Durante carregamento, substitui o botão
                  por indicador visual de progresso.
                  */
                  _carregando
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,

                          child: ElevatedButton(
                            onPressed: _fazerLogin,

                            child: const Text('ENTRAR'),
                          ),
                        ),

                  const SizedBox(height: 12),

                  /*
                  Navegação para recuperação de senha.
                  */
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const EsqueciSenhaPage(),
                        ),
                      );
                    },

                    child: const Text(
                      'Esqueci minha senha',
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                  ),

                  /*
                  Navegação para tela de cadastro.
                  */
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const CadastroPage(),
                        ),
                      );
                    },

                    child: const Text(
                      'Não tem conta? Criar cadastro',
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                      ),
                    ),
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