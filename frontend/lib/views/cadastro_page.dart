// Isabela
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para criar o usuário
import 'cadastro_startup_page.dart'; // Para pular para a próxima tela

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  // Controladores para pegar o texto
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _nomeController = TextEditingController();

  // Função para cadastrar o usuário na nuvem
  void _fazerCadastro() async {
    try {
      // 1. Cria o usuário no Firebase Auth real (Nuvem)
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      // 2. Se deu certo, avisa o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Usuário criado com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );

      // 3. PULA AUTOMATICAMENTE para a tela de cadastrar Startup que você fez
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CadastroStartupPage()),
      );
    } catch (e) {
      // Se der erro (ex: e-mail já existe), avisa aqui
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Criar Conta - MesclaInvest")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: "Nome Completo"),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "E-mail"),
            ),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(labelText: "Senha"),
              obscureText: true,
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _fazerCadastro,
                child: Text("CADASTRAR E CONTINUAR"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
