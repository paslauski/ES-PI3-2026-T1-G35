// Mateus - Tela detalhada da Startup
import 'package:flutter/material.dart';
import '../../models/startup_model.dart';

class StartupDetailPage extends StatelessWidget {
  final Startup startup;
  const StartupDetailPage({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(startup.nome),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com avatar, nome e badges
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 32,
                  child: Text(
                    startup.nome.isNotEmpty ? startup.nome[0] : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(startup.nome,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _badge(startup.estagio, Colors.blue),
                          const SizedBox(width: 6),
                          _badge(startup.status, Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Descrição do projeto
            _tituloSecao('📋 Descrição do Projeto'),
            const SizedBox(height: 8),
            _caixaTexto(startup.descricao.isNotEmpty
                ? startup.descricao
                : 'Sem descrição disponível.'),

            const SizedBox(height: 16),

            // Sumário executivo (só aparece se tiver dado)
            if (startup.sumarioExecutivo.isNotEmpty) ...[
              _tituloSecao('📊 Sumário Executivo'),
              const SizedBox(height: 8),
              _caixaTexto(startup.sumarioExecutivo),
              const SizedBox(height: 16),
            ],

            // Dados financeiros
            _tituloSecao('💰 Dados Financeiros'),
            const SizedBox(height: 8),
            _caixaLinhas([
              _linha('Capital já aportado', startup.capital),
              _linha('Total de tokens emitidos', startup.totalTokens),
              _linha('Preço por token', startup.precoToken),
              _linha('Estágio', startup.estagio),
              _linha('Status', startup.status),
              _linha('Setor', startup.setor),
            ]),

            const SizedBox(height: 20),

            // Estrutura societária
            _tituloSecao('🤝 Estrutura Societária'),
            const SizedBox(height: 8),

            startup.socios.isEmpty
                ? _caixaTexto('Estrutura societária não informada.')
                : Column(
                    children: startup.socios.map((socio) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(socio.nome.isNotEmpty ? socio.nome[0] : '?',
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold)),
                          ),
                          title: Text(socio.nome,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(socio.cargo),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(socio.percentual,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 20),

            // Perguntas e respostas (só aparece se tiver dado)
            if (startup.perguntasRespostas.isNotEmpty) ...[
              _tituloSecao('❓ Perguntas e Respostas'),
              const SizedBox(height: 8),
              ...startup.perguntasRespostas.asMap().entries.map((entry) {
                final isPergunta = entry.key % 2 == 0;
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPergunta
                        ? Colors.blue.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isPergunta
                          ? Colors.blue.shade200
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isPergunta ? '❓ ' : '💬 ',
                          style: const TextStyle(fontSize: 16)),
                      Expanded(child: Text(entry.value)),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 20),
            Center(
              child: Text('Dados simulados para fins acadêmicos.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _tituloSecao(String titulo) => Text(titulo,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));

  Widget _caixaTexto(String texto) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10)),
        child: Text(texto, style: const TextStyle(fontSize: 14)),
      );

  Widget _caixaLinhas(List<Widget> linhas) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10)),
        child: Column(children: linhas),
      );

  Widget _linha(String label, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(color: Colors.black54, fontSize: 13)),
            Flexible(
              child: Text(
                valor.isNotEmpty ? valor : '—',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );

  Widget _badge(String texto, Color cor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cor.withOpacity(0.5)),
        ),
        child: Text(texto,
            style: TextStyle(
                fontSize: 11, color: cor, fontWeight: FontWeight.w600)),
      );
}