// Isabela - Widget de Perguntas e Respostas
// ARQUIVO: frontend/lib/views/startups/perguntas_widget.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/error_translator.dart';

/*
Widget responsável pela seção de perguntas e respostas de uma startup.

Funcionalidades:
- exibir perguntas públicas para qualquer usuário;
- exibir perguntas privadas apenas para investidores;
- permitir envio de nova pergunta (pública ou privada);
- indicar visualmente o tipo de cada pergunta;
- integrar Firebase Auth e Firestore.
*/
class PerguntasWidget extends StatefulWidget {
  /*
  ID da startup cujas perguntas serão exibidas.
  */
  final String startupId;

  const PerguntasWidget({
    super.key,
    required this.startupId,
  });

  @override
  State<PerguntasWidget> createState() => _PerguntasWidgetState();
}

class _PerguntasWidgetState extends State<PerguntasWidget> {
  /*
  Controlador do campo de texto da nova pergunta.
  */
  final TextEditingController _ctrl = TextEditingController();

  /*
  Tipo da pergunta que será enviada: pública ou privada.
  */
  String _tipoSelecionado = 'publica';

  /*
  Controla o estado de envio (loading).
  */
  bool _enviando = false;

  /*
  Indica se o usuário atual é investidor desta startup.
  Determina se o botão "Privada" está disponível e
  se perguntas privadas serão exibidas.
  */
  bool _ehInvestidor = false;

  @override
  void initState() {
    super.initState();
    _verificarInvestidor();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /*
  Verifica se o usuário logado possui tokens da startup.
  Se sim, libera envio de perguntas privadas e exibição delas.
  */
  Future<void> _verificarInvestidor() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final carteiraId = '${user.uid}_${widget.startupId}';
    final snap = await FirebaseFirestore.instance
        .collection('carteiras')
        .doc(carteiraId)
        .get();

    if (mounted) {
      setState(() => _ehInvestidor = snap.exists);
    }
  }

  /*
  Envia a pergunta para o Firestore.

  Regras:
  - texto não pode estar vazio;
  - pergunta privada exige que o usuário seja investidor;
  - salva na coleção 'perguntas' com campo 'tipo'.
  */
  Future<void> _enviarPergunta() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _snack('Você precisa estar logado.', erro: true);
      return;
    }

    final texto = _ctrl.text.trim();

    if (texto.length < 5) {
      _snack('Escreva uma pergunta mais detalhada.', erro: true);
      return;
    }

    // Bloqueia privada se não for investidor
    if (_tipoSelecionado == 'privada' && !_ehInvestidor) {
      _snack(
        'Apenas investidores podem enviar perguntas privadas.',
        erro: true,
      );
      return;
    }

    setState(() => _enviando = true);

    try {
      await FirebaseFirestore.instance.collection('perguntas').add({
        'startupId': widget.startupId,
        'usuarioId': user.uid,
        'nomeUsuario': user.displayName ?? user.email ?? 'Usuário',
        'texto': texto,
        'tipo': _tipoSelecionado,       // "publica" ou "privada"
        'respondida': false,
        'resposta': '',
        'criadoEm': FieldValue.serverTimestamp(),
      });

      _ctrl.clear();
      _snack('✅ Pergunta enviada com sucesso!');
    } catch (e) {
      _snack(ErrorTranslator.traduzir(e), erro: true);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  /*
  Exibe SnackBar de feedback ao usuário.
  */
  void _snack(String msg, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: erro ? Colors.red : const Color(0xFF00C897),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── TÍTULO DA SEÇÃO ──────────────────────────────────────────
        const Text(
          '❓ Perguntas e Respostas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),

        const SizedBox(height: 12),

        // ── FORMULÁRIO DE NOVA PERGUNTA ──────────────────────────────
        if (user != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enviar nova pergunta',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 10),

                // Campo de texto da pergunta
                TextField(
                  controller: _ctrl,
                  maxLines: 3,
                  minLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Digite sua pergunta aqui...',
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),

                const SizedBox(height: 10),

                // Seletor de tipo: Pública / Privada
                Row(
                  children: [
                    /*
                    Opção Pública — disponível para todos.
                    */
                    _chipTipo(
                      label: '🌐 Pública',
                      valor: 'publica',
                      cor: const Color(0xFF6C63FF),
                    ),

                    const SizedBox(width: 8),

                    /*
                    Opção Privada — só para investidores.
                    Desabilitada visualmente se não for investidor.
                    */
                    _chipTipo(
                      label: '🔒 Privada',
                      valor: 'privada',
                      cor: const Color(0xFFFF9500),
                      desabilitado: !_ehInvestidor,
                      tooltip: _ehInvestidor
                          ? null
                          : 'Somente investidores podem enviar perguntas privadas',
                    ),

                    const Spacer(),

                    // Botão enviar
                    _enviando
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : ElevatedButton(
                            onPressed: _enviarPergunta,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C63FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Enviar'),
                          ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],

        // ── LISTA DE PERGUNTAS ───────────────────────────────────────
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('perguntas')
              .where('startupId', isEqualTo: widget.startupId)
              .snapshots(),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final docs = snapshot.data?.docs ?? [];
            docs.sort((a, b) {                                       
              final ta = (a.data() as Map<String, dynamic>)['criadoEm'];
              final tb = (b.data() as Map<String, dynamic>)['criadoEm'];
              if (ta == null) return 1;
              if (tb == null) return -1;
              return (ta as Timestamp).compareTo(tb as Timestamp);
           });       
                                
            /*
            Filtra as perguntas que o usuário pode ver:
            - públicas: todos veem
            - privadas: só investidores veem
            */
            final visiveis = docs.where((doc) {
              final d = doc.data() as Map<String, dynamic>;
              final tipo = d['tipo']?.toString() ?? 'publica';
              if (tipo == 'privada' && !_ehInvestidor) return false;
              return true;
            }).toList();

            if (visiveis.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Nenhuma pergunta ainda. Seja o primeiro a perguntar!',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Column(
              children: visiveis.map((doc) {
                final d = doc.data() as Map<String, dynamic>;

                final texto = d['texto']?.toString() ?? '';
                final resposta = d['resposta']?.toString() ?? '';
                final respondida = d['respondida'] == true;
                final tipo = d['tipo']?.toString() ?? 'publica';
                final nomeUsuario = d['nomeUsuario']?.toString() ?? 'Usuário';
                final isPrivada = tipo == 'privada';

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isPrivada
                          ? const Color(0xFFFF9500).withOpacity(0.3)
                          : const Color(0xFFEEEEEE),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho da pergunta
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                        child: Row(
                          children: [
                            /*
                            Badge do tipo da pergunta.
                            */
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isPrivada
                                    ? const Color(0xFFFF9500).withOpacity(0.1)
                                    : const Color(0xFF6C63FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isPrivada ? '🔒 Privada' : '🌐 Pública',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isPrivada
                                      ? const Color(0xFFFF9500)
                                      : const Color(0xFF6C63FF),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Nome do autor
                            Expanded(
                              child: Text(
                                nomeUsuario,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF888888),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Texto da pergunta
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('❓ ',
                                style: TextStyle(fontSize: 14)),
                            Expanded(
                              child: Text(
                                texto,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Resposta (só exibe se existir)
                      if (respondida && resposta.isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C897).withOpacity(0.07),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF00C897).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('💬 ',
                                  style: TextStyle(fontSize: 14)),
                              Expanded(
                                child: Text(
                                  resposta,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF2D6A4F),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Indica que aguarda resposta
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                          child: Text(
                            'Aguardando resposta...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  /*
  Widget do chip de seleção de tipo (Pública / Privada).
  */
  Widget _chipTipo({
    required String label,
    required String valor,
    required Color cor,
    bool desabilitado = false,
    String? tooltip,
  }) {
    final selecionado = _tipoSelecionado == valor;

    final chip = GestureDetector(
      onTap: desabilitado
          ? null
          : () => setState(() => _tipoSelecionado = valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selecionado ? cor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: desabilitado
                ? Colors.grey.shade300
                : selecionado
                    ? cor
                    : cor.withOpacity(0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: desabilitado
                ? Colors.grey.shade400
                : selecionado
                    ? Colors.white
                    : cor,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: chip);
    }

    return chip;
  }
}
