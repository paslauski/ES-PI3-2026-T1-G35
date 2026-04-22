// Isabela

// 📌 VIEW = tela (interface do usuário)

import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../services/auth_service.dart';

// 🔹 StatefulWidget = tela que pode mudar (estado dinâmico)
class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

// 🔹 STATE = onde ficam os dados e lógica da tela
class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();

  // 📌 CONTROLLERS = capturam o que o usuário digita
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _carregando = false;
  String _tipoSelecionado = 'investidor';

  // 🔹 LIBERA memória quando sai da tela (boa prática)
  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  // 🔹 MÉTODO PRINCIPAL DO BOTÃO
  Future<void> _fazerCadastro() async {
    // valida o formulário
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      // 📌 cria objeto Usuario com os dados da tela
      final usuario = Usuario(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text.trim(),
        cpf: _cpfController.text.trim(),
        telefone: _telefoneController.text.trim(),
        tipo: _tipoSelecionado,
      );

      // chama o service (backend)
      await _authService.cadastrarNovoUsuario(usuario);

      if (!mounted) return;

      // mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (!mounted) return;
      setState(() => _carregando = false);
    }
  }

  // 🔹 VALIDAÇÕES (regras de entrada)
  String? _validarObrigatorio(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe $campo';
    }
    return null;
  }

  String? _validarSenha(String? value) {
    if (value == null || value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  // 🔹 PADRÃO VISUAL DOS CAMPOS
  InputDecoration _decoracao(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // 🔹 BUILD = monta a tela
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
                validator: (v) => _validarObrigatorio(v, 'o e-mail'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _cpfController,
                decoration: _decoracao('CPF'),
                validator: (v) => _validarObrigatorio(v, 'o CPF'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _telefoneController,
                decoration: _decoracao('Telefone'),
                validator: (v) => _validarObrigatorio(v, 'o telefone'),
              ),
              const SizedBox(height: 16),

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
