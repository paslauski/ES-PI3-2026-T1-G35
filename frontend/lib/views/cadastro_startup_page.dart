// Isabela

// 📌 VIEW = tela visual do app

import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../services/auth_service.dart';

// 🔹 StatefulWidget = tela que muda de estado
// Ex: loading, erro, texto digitado
class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

// 🔹 State = parte que guarda a lógica e os dados da tela
class _CadastroPageState extends State<CadastroPage> {
  // controla e valida o formulário
  final _formKey = GlobalKey<FormState>();

  // controllers = pegam o texto digitado nos campos
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();

  // service = conversa com Firebase
  final AuthService _authService = AuthService();

  bool _carregando = false;
  String _tipoSelecionado = 'investidor';

  @override
  void dispose() {
    // libera memória quando sair da tela
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // 🔹 MÉTODO PRINCIPAL DO CADASTRO
  Future<void> _fazerCadastro() async {
    // valida os campos antes de continuar
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      // cria um objeto Usuario com os dados da tela
      final usuario = Usuario(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text.trim(),
        cpf: _cpfController.text.trim(),
        telefone: _telefoneController.text.trim(),
        tipo: _tipoSelecionado,
      );

      // chama o service que cadastra no Firebase
      await _authService.cadastrarNovoUsuario(usuario);

      if (!mounted) return;

      // mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário cadastrado com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // 🔹 redireciona para a tela anterior (login)
      // como o cadastro foi aberto a partir do login com Navigator.push,
      // o pop() volta para o login
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.pop(context);
      });
    } catch (e) {
      if (!mounted) return;

      // mostra erro caso algo dê errado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (!mounted) return;
      setState(() => _carregando = false);
    }
  }

  // 🔹 valida campo obrigatório
  String? _validarObrigatorio(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe $campo';
    }
    return null;
  }

  // 🔹 valida senha
  String? _validarSenha(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe a senha';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  // 🔹 padrão visual dos campos
  InputDecoration _decoracao(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta - MesclaInvest')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: _decoracao('Nome'),
                validator: (v) => _validarObrigatorio(v, 'o nome'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: _decoracao('E-mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => _validarObrigatorio(v, 'o e-mail'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _cpfController,
                decoration: _decoracao('CPF'),
                keyboardType: TextInputType.number,
                validator: (v) => _validarObrigatorio(v, 'o CPF'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _telefoneController,
                decoration: _decoracao('Telefone'),
                keyboardType: TextInputType.phone,
                validator: (v) => _validarObrigatorio(v, 'o telefone'),
              ),
              const SizedBox(height: 16),

              // dropdown = campo de seleção
              DropdownButtonFormField<String>(
                value: _tipoSelecionado,
                decoration: _decoracao('Tipo'),
                items: const [
                  DropdownMenuItem(
                    value: 'investidor',
                    child: Text('Investidor'),
                  ),
                  DropdownMenuItem(
                    value: 'empreendedor',
                    child: Text('Empreendedor'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _tipoSelecionado = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _senhaController,
                decoration: _decoracao('Senha'),
                obscureText: true,
                validator: _validarSenha,
              ),
              const SizedBox(height: 30),

              _carregando
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _fazerCadastro,
                        child: const Text('CADASTRAR'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
