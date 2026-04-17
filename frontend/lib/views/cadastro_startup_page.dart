// Isabela
// TELA PARA O EMPREENDEDOR CADASTRAR A SUA STARTUP

import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart'; // Importa a biblioteca dos Robôs

class CadastroStartupPage extends StatefulWidget {
  @override
  _CadastroStartupPageState createState() => _CadastroStartupPageState();
}

class _CadastroStartupPageState extends State<CadastroStartupPage> {
  // Controladores para apanhar o que o utilizador digita
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  // Variável para mostrar a "bolinha a girar" enquanto o servidor pensa
  bool _carregando = false;

  // Função assíncrona que fala com o nosso Backend (Cloud Functions)
  Future<void> _salvarStartup() async {
    setState(() {
      _carregando = true; // Liga a bolinha a girar
    });

    try {
      print("A chamar o robô createStartup no servidor (América do Sul)...");

      // 1. PREPARA A CHAMADA: Procura o robô pelo nome exato e na região certa!
      final roboCreateStartup = FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('createStartup');

      // 2. ENVIA OS DADOS: Manda o pacote para o robô e ESPERA (await) a resposta
      final resposta = await roboCreateStartup.call({
        'nome': _nomeController.text,
        'descricao': _descricaoController.text,
      });

      // 3. SUCESSO! Mostra a mensagem verde com a resposta que o robô mandou
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ ${resposta.data['mensagem']}"),
          backgroundColor: Colors.green,
        ),
      );

      // Limpa os campos
      _nomeController.clear();
      _descricaoController.clear();
    } on FirebaseFunctionsException catch (e) {
      // BARREIRA DE SEGURANÇA!
      // Se o utilizador não estiver logado, ou se o texto estiver vazio, cai aqui.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Erro do Servidor: ${e.message}"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // Erro geral do telemóvel/navegador
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erro: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _carregando = false; // Desliga a bolinha a girar
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastrar Nova Startup"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: "Nome da Startup",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descricaoController,
              maxLines: 4, // Caixa de texto maior para a descrição
              decoration: InputDecoration(
                labelText: "Descreva a sua ideia (Elevator Pitch)",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),

            // Se estiver a carregar, mostra a bolinha. Se não, mostra o botão.
            _carregando
                ? CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _salvarStartup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: Text(
                        "ENVIAR PARA ANÁLISE",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
