// Isabela + Mateus - Tela Minha Carteira
// Isabela Aparecida Paslauski Pinto - RA 25003335
// Tela Minha Carteira
// Responsável por exibir saldo, investimentos, depósito e resgate simulados.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/*
Tela responsável pela carteira de investimentos do usuário.

Funcionalidades:
- exibir saldo disponível;
- mostrar total investido;
- calcular valor atual da carteira;
- calcular retorno percentual;
- listar investimentos por startup;
- permitir depósito simulado;
- permitir resgate simulado;
- integrar Firebase Auth e Firestore.
*/

class MinhaCarteiraPage extends StatelessWidget {
  const MinhaCarteiraPage({super.key});

  /*
  Formata valores monetários no padrão BRL.

  Exemplo:
  1500.5 -> R$ 1500,50
  */
  String _fmt(dynamic valor) {
    final n = double.tryParse((valor ?? 0).toString()) ?? 0;
    return 'R\$ ${n.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /*
  Converte valores dinâmicos para double.

  Usado para tratar dados vindos do Firestore como int, double ou String.
  */
  double _toDouble(dynamic v) {
    return double.tryParse((v ?? 0).toString()) ?? 0;
  }

  /*
  Abre modal de sucesso após depósito.
  */
  Future<void> _abrirSucessoSaldo(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(child: SizedBox()),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Color(0xFF00C897),
              size: 72,
            ),
            SizedBox(height: 16),
            Text(
              'Saldo adicionado com sucesso!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*
  Abre modal de sucesso após resgate.
  */
  Future<void> _abrirSucessoResgate(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(child: SizedBox()),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Color(0xFF00C897),
              size: 72,
            ),
            SizedBox(height: 16),
            Text(
              'Resgate realizado com sucesso!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1A1A2E),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'O valor foi retirado do saldo simulado da carteira.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  /*
  Abre modal de depósito cancelado.
  */
  Future<void> _abrirCancelado(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Depósito cancelado',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFFFF4D4D),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            Icon(Icons.cancel_outlined, color: Color(0xFFFF4D4D), size: 56),
            SizedBox(height: 12),
            Text(
              'O depósito foi cancelado pois a identidade não foi confirmada.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF666666), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  /*
  Abre QR Code simulado para depósito.
  */
  Future<void> _abrirQrCode(
    BuildContext context,
    String uid,
    double valor,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '📲 QR Code de Pagamento',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Escaneie o QR Code para concluir o depósito:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF666666), fontSize: 13),
            ),

            const SizedBox(height: 20),

            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF6C63FF), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomPaint(painter: _QrCodePainter()),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final usuarioRef = FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(uid);

                  await FirebaseFirestore.instance.runTransaction((
                    transaction,
                  ) async {
                    final snap = await transaction.get(usuarioRef);

                    final saldoAtual = snap.exists
                        ? _toDouble(snap.data()?['saldo'])
                        : 0;

                    transaction.set(usuarioRef, {
                      'saldo': saldoAtual + valor,
                      'updatedAt': FieldValue.serverTimestamp(),
                    }, SetOptions(merge: true));

                    final transacaoRef = FirebaseFirestore.instance
                        .collection('transacoes')
                        .doc();

                    transaction.set(transacaoRef, {
                      'usuarioId': uid,
                      'tipo': 'deposito',
                      'valorTotal': valor,
                      'createdAt': FieldValue.serverTimestamp(),
                    });
                  });

                  if (ctx.mounted) Navigator.pop(ctx);

                  if (context.mounted) {
                    await _abrirSucessoSaldo(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Transação realizada'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*
  Confirma identidade antes do depósito.
  */
  Future<void> _confirmarIdentidade(
    BuildContext context,
    String uid,
    double valor,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'email não encontrado';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🔐 Confirmar identidade',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Você está depositando como:',
              style: TextStyle(color: Color(0xFF666666), fontSize: 13),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFEEEEEE)),
              ),
              child: Text(
                email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'É você mesmo?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _abrirCancelado(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFF4D4D),
                side: const BorderSide(color: Color(0xFFFF4D4D)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Não sou eu'),
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (ctx.mounted) Navigator.pop(ctx);

                if (context.mounted) {
                  await _abrirQrCode(context, uid, valor);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Sou eu'),
            ),
          ),
        ],
      ),
    );
  }

  /*
  Abre diálogo para depositar saldo fictício.
  */
  Future<void> _abrirDepositar(BuildContext context, String uid) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '💰 Depositar Saldo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Informe o valor a depositar na sua carteira simulada:',
              style: TextStyle(color: Color(0xFF666666), fontSize: 13),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                prefixText: 'R\$ ',
                hintText: '0,00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),

          ElevatedButton(
            onPressed: () async {
              final texto = controller.text
                  .replaceAll('R\$', '')
                  .replaceAll(' ', '')
                  .replaceAll(',', '.');

              final valor = double.tryParse(texto) ?? 0;

              if (valor <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Informe um valor válido.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(ctx);
              await _confirmarIdentidade(context, uid, valor);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  /*
  Abre diálogo para resgatar saldo fictício.
  */
  Future<void> _abrirResgatar(BuildContext context, String uid) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '💸 Resgatar Saldo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Informe o valor a resgatar da sua carteira simulada:',
              style: TextStyle(color: Color(0xFF666666), fontSize: 13),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                prefixText: 'R\$ ',
                hintText: '0,00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),

          ElevatedButton(
            onPressed: () async {
              final texto = controller.text
                  .replaceAll('R\$', '')
                  .replaceAll(' ', '')
                  .replaceAll(',', '.');

              final valor = double.tryParse(texto) ?? 0;

              if (valor <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Informe um valor válido.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final usuarioRef = FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(uid);

                await FirebaseFirestore.instance.runTransaction((
                  transaction,
                ) async {
                  final snap = await transaction.get(usuarioRef);

                  final saldoAtual = snap.exists
                      ? _toDouble(snap.data()?['saldo'])
                      : 0;

                  if (valor > saldoAtual) {
                    throw Exception('Saldo insuficiente para resgate.');
                  }

                  transaction.update(usuarioRef, {
                    'saldo': saldoAtual - valor,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  final transacaoRef = FirebaseFirestore.instance
                      .collection('transacoes')
                      .doc();

                  transaction.set(transacaoRef, {
                    'usuarioId': uid,
                    'tipo': 'resgate',
                    'valorTotal': valor,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                });

                if (ctx.mounted) Navigator.pop(ctx);

                if (context.mounted) {
                  await _abrirSucessoResgate(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9500),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirmar Resgate'),
          ),
        ],
      ),
    );
  }

  /*
  Busca os preços atuais das startups na coleção "startups".
  */
  Future<Map<String, double>> _buscarPrecosAtuais(
    List<QueryDocumentSnapshot> docs,
  ) async {
    final Map<String, double> precos = {};

    final ids = docs
        .map(
          (d) =>
              (d.data() as Map<String, dynamic>)['startupId']?.toString() ?? '',
        )
        .where((id) => id.isNotEmpty)
        .toSet();

    for (final id in ids) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('startups')
            .doc(id)
            .get();

        if (snap.exists) {
          final data = snap.data() as Map<String, dynamic>;

          final raw = data['preco_token'] ?? data['precoToken'] ?? 0;

          final preco =
              double.tryParse(
                raw
                    .toString()
                    .replaceAll('R\$', '')
                    .replaceAll(' ', '')
                    .replaceAll(',', '.'),
              ) ??
              0;

          if (preco > 0) {
            precos[id] = preco;
          }
        }
      } catch (_) {
        // ignora erro de preço individual para não quebrar a tela inteira
      }
    }

    return precos;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    /*
    Caso o usuário não esteja logado.
    */
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Minha Carteira'),
          automaticallyImplyLeading: false,
        ),
        body: const Center(child: Text('Você precisa estar logado.')),
      );
    }

    /*
    Query da carteira do usuário.
    */
    final carteiraQuery = FirebaseFirestore.instance
        .collection('carteiras')
        .where('usuarioId', isEqualTo: user.uid);

    /*
    Referência do documento do usuário.
    */
    final usuarioRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Carteira'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
            },
          ),
        ],
      ),

      backgroundColor: const Color(0xFFF5F5FA),

      body: StreamBuilder<QuerySnapshot>(
        stream: carteiraQuery.snapshots(),
        builder: (context, snapCarteira) {
          return StreamBuilder<DocumentSnapshot>(
            stream: usuarioRef.snapshots(),
            builder: (context, snapUsuario) {
              double saldo = 0;

              if (snapUsuario.hasData && snapUsuario.data!.exists) {
                final d = snapUsuario.data!.data() as Map<String, dynamic>;
                saldo = _toDouble(d['saldo']);
              }

              final docs = snapCarteira.data?.docs ?? [];

              return FutureBuilder<Map<String, double>>(
                future: _buscarPrecosAtuais(docs),
                builder: (context, snapPrecos) {
                  final precosAtuais = snapPrecos.data ?? {};

                  double totalInvestido = 0;
                  double valorAtualTotal = 0;

                  for (final doc in docs) {
                    final d = doc.data() as Map<String, dynamic>;

                    final startupId = (d['startupId'] ?? '').toString();
                    final quantidade = _toDouble(d['quantidade']);
                    final investido = _toDouble(d['totalInvestido']);

                    final precoAtual =
                        precosAtuais[startupId] ?? _toDouble(d['precoMedio']);

                    totalInvestido += investido;
                    valorAtualTotal += quantidade * precoAtual;
                  }

                  final retorno = totalInvestido > 0
                      ? ((valorAtualTotal - totalInvestido) /
                            totalInvestido *
                            100)
                      : 0.0;

                  return Column(
                    children: [
                      /*
                      Card principal da carteira.
                      */
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A1A2E), Color(0xFF2D2D4E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Valor atual da carteira',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              _fmt(valorAtualTotal),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Row(
                              children: [
                                Icon(
                                  retorno >= 0
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: retorno >= 0
                                      ? const Color(0xFF00C897)
                                      : Colors.red,
                                  size: 14,
                                ),

                                const SizedBox(width: 4),

                                Text(
                                  '${retorno >= 0 ? '+' : ''}${retorno.toStringAsFixed(1)}% retorno total',
                                  style: TextStyle(
                                    color: retorno >= 0
                                        ? const Color(0xFF00C897)
                                        : Colors.red,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Saldo disponível',
                                        style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _fmt(saldo),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Total investido',
                                        style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _fmt(totalInvestido),
                                        style: const TextStyle(
                                          color: Color(0xFF00C897),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      /*
                      Botões de depósito e resgate.
                      */
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _abrirDepositar(context, user.uid),
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 18,
                                ),
                                label: const Text('Depositar Saldo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C63FF),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _abrirResgatar(context, user.uid),
                                icon: const Icon(
                                  Icons.arrow_circle_down_outlined,
                                  size: 18,
                                ),
                                label: const Text('Resgatar Saldo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF9500),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      /*
                      Título da lista de investimentos.
                      */
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              'Meus Investimentos',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      /*
                      Lista de investimentos.
                      */
                      Expanded(
                        child:
                            snapCarteira.connectionState ==
                                ConnectionState.waiting
                            ? const Center(child: CircularProgressIndicator())
                            : docs.isEmpty
                            ? const Center(
                                child: Text(
                                  'Você ainda não possui tokens.',
                                  style: TextStyle(color: Color(0xFF888888)),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final d =
                                      docs[index].data()
                                          as Map<String, dynamic>;

                                  final startupId = (d['startupId'] ?? '')
                                      .toString();

                                  final nome = (d['nomeStartup'] ?? 'Startup')
                                      .toString();

                                  final quantidade = _toDouble(d['quantidade']);

                                  final investido = _toDouble(
                                    d['totalInvestido'],
                                  );

                                  final precoAtual =
                                      precosAtuais[startupId] ??
                                      _toDouble(d['precoMedio']);

                                  final valorAtual = quantidade * precoAtual;

                                  final variacao = investido > 0
                                      ? ((valorAtual - investido) /
                                            investido *
                                            100)
                                      : 0.0;

                                  final letra = nome.isNotEmpty ? nome[0] : '?';

                                  final cores = [
                                    const Color(0xFFFF9500),
                                    const Color(0xFF00C897),
                                    const Color(0xFF6C63FF),
                                    const Color(0xFFFF4D4D),
                                  ];

                                  final cor = cores[index % cores.length];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFEEEEEE),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: cor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              letra,
                                              style: TextStyle(
                                                color: cor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                nome,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1A1A2E),
                                                ),
                                              ),

                                              const SizedBox(height: 2),

                                              Text(
                                                '${quantidade.toInt()} tokens',
                                                style: const TextStyle(
                                                  color: Color(0xFF888888),
                                                  fontSize: 12,
                                                ),
                                              ),

                                              const SizedBox(height: 8),

                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Investido',
                                                        style: TextStyle(
                                                          color: Color(
                                                            0xFFAAAAAA,
                                                          ),
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                      Text(
                                                        _fmt(investido),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      const Text(
                                                        'Valor atual',
                                                        style: TextStyle(
                                                          color: Color(
                                                            0xFFAAAAAA,
                                                          ),
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                      Text(
                                                        _fmt(valorAtual),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  Text(
                                                    '${variacao >= 0 ? '+' : ''}${variacao.toStringAsFixed(0)}%',
                                                    style: TextStyle(
                                                      color: variacao >= 0
                                                          ? const Color(
                                                              0xFF00C897,
                                                            )
                                                          : Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/*
Painter responsável por desenhar um QR Code simulado.

Não representa um QR Code real de pagamento.
Serve apenas para a simulação acadêmica do depósito.
*/
class _QrCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1A1A2E);
    final bg = Paint()..color = Colors.white;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    const modules = 21;
    final cellSize = size.width / modules;

    final pattern = [
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0],
      [1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1],
      [0, 1, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0],
      [1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1],
      [0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0],
      [1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1],
      [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0],
      [1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1],
      [1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0],
      [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1],
    ];

    for (int row = 0; row < modules; row++) {
      for (int col = 0; col < modules; col++) {
        if (pattern[row][col] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
