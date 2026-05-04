// Isabela

// 📌 IMPORTANTE
// VIEW = tela visual do app (o que o usuário vê)

import 'package:flutter/material.dart';

// 🔹 importa o service (responsável por falar com Firebase)
import '../services/auth_service.dart';

// 🔹 telas que vamos navegar
import 'cadastro_page.dart';
import 'esqueci_senha_page.dart';
import 'startups/startup_list_page.dart';

// 🔹 StatefulWidget = tela que pode mudar (estado dinâmico)
// Ex: loading, erro, texto digitado
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// 🔹 STATE = onde fica a lógica da tela
class _LoginPageState extends State<LoginPage> {
  // 📌 FORMKEY = controla e valida o formulário
  final _formKey = GlobalKey<FormState>();

  // 📌 CONTROLLERS = capturam o que o usuário digita
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  // 📌 SERVICE = classe que conversa com Firebase
  final AuthService _authService = AuthService();

  // 📌 variável de controle (loading)
  bool _carregando = false;

  // 🔹 LIBERA MEMÓRIA quando sair da tela
  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  //Mateus
  //Criando função PRIVATE
  //Para traduzir os erros!

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

  // 🔹 FUNÇÃO PRINCIPAL DO LOGIN
  // Essa função roda quando o usuário clica no botão "ENTRAR"
  Future<void> _fazerLogin() async {
    // 1. valida se os campos estão preenchidos corretamente
    if (!_formKey.currentState!.validate()) return;

    // 2. ativa o loading (mostra a bolinha)
    setState(() => _carregando = true);

    try {
      // 3. chama o Firebase (via AuthService)
      await _authService.login(
        _emailController.text.trim(),
        _senhaController.text.trim(),
      );

      // evita erro se a tela já tiver sido destruída
      if (!mounted) return;

      // 4. mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // 🔹 REDIRECIONAMENTO para o catálogo de startups
      // Mateus - navegação para StartupListPage após login
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;

        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StartupListPage()),
  );

});

  //Mateus Substitui o antigo catch
  //Agora chama a função e traduz os erros
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
      if (!mounted) return;

      // 6. desativa loading
      setState(() => _carregando = false);
    }
  }

  // 🔹 VALIDAÇÃO DE CAMPO OBRIGATÓRIO
  String? _validarObrigatorio(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe $campo';
    }
    return null;
  }

  // 🔹 VALIDAÇÃO DE SENHA
  String? _validarSenha(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe a senha';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  // 🔹 PADRÃO VISUAL DOS INPUTS (pra não repetir código)
  InputDecoration _decoracao(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // 🔹 BUILD = monta a tela (UI)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar - MesclaInvest')),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),

            child: Form(
              key: _formKey,

              child: Column(
                children: [
                  // 🔹 Ícone (visual)
                  const Icon(Icons.account_balance, size: 70),

                  const SizedBox(height: 16),

                  // 🔹 Título
                  const Text(
                    'Bem-vinda ao MesclaInvest',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Entre com seu e-mail e senha',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  // 🔹 CAMPO EMAIL
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _decoracao('E-mail'),
                    validator: (v) => _validarObrigatorio(v, 'o e-mail'),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 CAMPO SENHA
                  TextFormField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: _decoracao('Senha'),
                    validator: _validarSenha,
                  ),

                  const SizedBox(height: 24),

                  // 🔹 BOTÃO LOGIN
                  _carregando
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _fazerLogin,
                            child: const Text('ENTRAR'),
                          ),
                        ),

                  const SizedBox(height: 12),

                  // 🔹 BOTÃO "ESQUECI MINHA SENHA"
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EsqueciSenhaPage(),
                        ),
                      );
                    },
                    child: const Text('Esqueci minha senha'),
                  ),

                  // 🔹 BOTÃO IR PARA CADASTRO
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CadastroPage(),
                        ),
                      );
                    },
                    child: const Text('Não tem conta? Criar cadastro'),
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
