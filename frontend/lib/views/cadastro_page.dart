//isabela
import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../services/auth_service.dart';

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  String _tipoUtilizador = 'investidor';

  final AuthService _authService = AuthService();

  void _fazerCadastro() async {
    Usuario novo = Usuario(
      nome: _nomeController.text,
      email: _emailController.text,
      senha: _senhaController.text,
      tipo: _tipoUtilizador,
    );

    try {
      await _authService.cadastrarNovoUsuario(novo);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sucesso! ${novo.nome} salvo no Firebase!"),
          backgroundColor: Colors.green,
        ),
      );

      _nomeController.clear();
      _emailController.clear();
      _senhaController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao salvar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro MesclaInvest"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.person_add, size: 80, color: Colors.blueAccent),
            SizedBox(height: 20),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: "Nome Completo",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "E-mail",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 15),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(
                labelText: "Senha",
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Text(
              "Selecione seu perfil:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio(
                  value: 'investidor',
                  groupValue: _tipoUtilizador,
                  onChanged: (value) =>
                      setState(() => _tipoUtilizador = value!),
                ),
                Text("Investidor"),
                SizedBox(width: 20),
                Radio(
                  value: 'empreendedor',
                  groupValue: _tipoUtilizador,
                  onChanged: (value) =>
                      setState(() => _tipoUtilizador = value!),
                ),
                Text("Empreendedor"),
              ],
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _fazerCadastro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "FINALIZAR CADASTRO",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
