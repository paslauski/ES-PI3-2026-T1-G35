import 'package:cloud_firestore/cloud_firestore.dart';

class TokenService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> comprarTokens({
    required String usuarioId,
    required String startupId,
    required int quantidade,
    required double precoToken,
  }) async {
    if (quantidade <= 0) {
      throw Exception('A quantidade precisa ser maior que zero.');
    }

    final usuarioRef = _db.collection('usuarios').doc(usuarioId);
    final startupRef = _db.collection('startups').doc(startupId);
    final transacaoRef = _db.collection('transacoes').doc();

    await _db.runTransaction((transaction) async {
      final usuarioSnap = await transaction.get(usuarioRef);
      final startupSnap = await transaction.get(startupRef);

      if (!usuarioSnap.exists) {
        throw Exception('Usuário não encontrado.');
      }

      if (!startupSnap.exists) {
        throw Exception('Startup não encontrada.');
      }

      final usuarioData = usuarioSnap.data() as Map<String, dynamic>;
      final startupData = startupSnap.data() as Map<String, dynamic>;

      final double saldoAtual = (usuarioData['saldo'] ?? 0).toDouble();

      final int tokensDisponiveis =
          (startupData['tokens_disponiveis'] ??
                  startupData['total_tokens'] ??
                  0)
              .toInt();

      final double valorTotal = quantidade * precoToken;

      if (saldoAtual < valorTotal) {
        throw Exception('Saldo insuficiente.');
      }

      if (tokensDisponiveis < quantidade) {
        throw Exception('Tokens insuficientes disponíveis.');
      }

      transaction.update(usuarioRef, {'saldo': saldoAtual - valorTotal});

      transaction.update(startupRef, {
        'tokens_disponiveis': tokensDisponiveis - quantidade,
      });

      transaction.set(transacaoRef, {
        'usuarioId': usuarioId,
        'startupId': startupId,
        'quantidade': quantidade,
        'precoToken': precoToken,
        'valorTotal': valorTotal,
        'tipo': 'compra',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
