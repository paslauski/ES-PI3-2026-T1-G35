import 'package:cloud_firestore/cloud_firestore.dart';

class TokenService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _carteiraId(String usuarioId, String startupId) {
    return '${usuarioId}_$startupId';
  }

  Future<void> comprarTokens({
    required String usuarioId,
    required String startupId,
    required int quantidade,
    required double precoToken,
    String nomeStartup = '',
  }) async {
    if (quantidade <= 0) {
      throw Exception('A quantidade precisa ser maior que zero.');
    }

    if (precoToken <= 0) {
      throw Exception('Preço do token inválido.');
    }

    final usuarioRef = _db.collection('usuarios').doc(usuarioId);
    final startupRef = _db.collection('startups').doc(startupId);
    final transacaoRef = _db.collection('transacoes').doc();

    final carteiraRef = _db
        .collection('carteiras')
        .doc(_carteiraId(usuarioId, startupId));

    await _db.runTransaction((transaction) async {
      final usuarioSnap = await transaction.get(usuarioRef);
      final startupSnap = await transaction.get(startupRef);
      final carteiraSnap = await transaction.get(carteiraRef);

      if (!usuarioSnap.exists) {
        throw Exception('Usuário não encontrado.');
      }

      if (!startupSnap.exists) {
        throw Exception('Startup não encontrada.');
      }

      final usuarioData = usuarioSnap.data() as Map<String, dynamic>;
      final startupData = startupSnap.data() as Map<String, dynamic>;

      final double saldoAtual =
          double.tryParse((usuarioData['saldo'] ?? 10000).toString()) ?? 10000;

      final int tokensDisponiveis =
          int.tryParse(
            (startupData['tokens_disponiveis'] ??
                    startupData['total_tokens'] ??
                    1000)
                .toString(),
          ) ??
          1000;

      final double valorTotal = quantidade * precoToken;

      if (saldoAtual < valorTotal) {
        throw Exception('Saldo insuficiente.');
      }

      if (tokensDisponiveis < quantidade) {
        throw Exception('Tokens insuficientes disponíveis.');
      }

      int quantidadeAtualCarteira = 0;
      double totalInvestidoAtual = 0;

      if (carteiraSnap.exists) {
        final carteiraData = carteiraSnap.data() as Map<String, dynamic>;

        quantidadeAtualCarteira =
            int.tryParse((carteiraData['quantidade'] ?? 0).toString()) ?? 0;

        totalInvestidoAtual =
            double.tryParse((carteiraData['totalInvestido'] ?? 0).toString()) ??
            0;
      }

      final novaQuantidadeCarteira = quantidadeAtualCarteira + quantidade;
      final novoTotalInvestido = totalInvestidoAtual + valorTotal;
      final novoPrecoMedio = novoTotalInvestido / novaQuantidadeCarteira;

      transaction.update(usuarioRef, {'saldo': saldoAtual - valorTotal});

      transaction.update(startupRef, {
        'tokens_disponiveis': tokensDisponiveis - quantidade,
      });

      transaction.set(carteiraRef, {
        'usuarioId': usuarioId,
        'startupId': startupId,
        'nomeStartup': nomeStartup,
        'quantidade': novaQuantidadeCarteira,
        'precoMedio': novoPrecoMedio,
        'totalInvestido': novoTotalInvestido,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(transacaoRef, {
        'usuarioId': usuarioId,
        'startupId': startupId,
        'nomeStartup': nomeStartup,
        'quantidade': quantidade,
        'precoToken': precoToken,
        'valorTotal': valorTotal,
        'tipo': 'compra',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> venderTokens({
    required String usuarioId,
    required String startupId,
    required int quantidade,
    required double precoToken,
    String nomeStartup = '',
  }) async {
    if (quantidade <= 0) {
      throw Exception('A quantidade precisa ser maior que zero.');
    }

    if (precoToken <= 0) {
      throw Exception('Preço do token inválido.');
    }

    final usuarioRef = _db.collection('usuarios').doc(usuarioId);
    final startupRef = _db.collection('startups').doc(startupId);
    final transacaoRef = _db.collection('transacoes').doc();

    final carteiraRef = _db
        .collection('carteiras')
        .doc(_carteiraId(usuarioId, startupId));

    await _db.runTransaction((transaction) async {
      final usuarioSnap = await transaction.get(usuarioRef);
      final startupSnap = await transaction.get(startupRef);
      final carteiraSnap = await transaction.get(carteiraRef);

      if (!usuarioSnap.exists) {
        throw Exception('Usuário não encontrado.');
      }

      if (!startupSnap.exists) {
        throw Exception('Startup não encontrada.');
      }

      if (!carteiraSnap.exists) {
        throw Exception('Você não possui tokens dessa startup.');
      }

      final usuarioData = usuarioSnap.data() as Map<String, dynamic>;
      final startupData = startupSnap.data() as Map<String, dynamic>;
      final carteiraData = carteiraSnap.data() as Map<String, dynamic>;

      final double saldoAtual =
          double.tryParse((usuarioData['saldo'] ?? 10000).toString()) ?? 10000;

      final int tokensDisponiveis =
          int.tryParse(
            (startupData['tokens_disponiveis'] ??
                    startupData['total_tokens'] ??
                    1000)
                .toString(),
          ) ??
          1000;

      final int quantidadeCarteira =
          int.tryParse((carteiraData['quantidade'] ?? 0).toString()) ?? 0;

      final double totalInvestido =
          double.tryParse((carteiraData['totalInvestido'] ?? 0).toString()) ??
          0;

      if (quantidadeCarteira < quantidade) {
        throw Exception('Você não possui tokens suficientes para vender.');
      }

      final double valorTotal = quantidade * precoToken;
      final int novaQuantidadeCarteira = quantidadeCarteira - quantidade;

      transaction.update(usuarioRef, {'saldo': saldoAtual + valorTotal});

      transaction.update(startupRef, {
        'tokens_disponiveis': tokensDisponiveis + quantidade,
      });

      if (novaQuantidadeCarteira <= 0) {
        transaction.delete(carteiraRef);
      } else {
        final double novoTotalInvestido =
            totalInvestido * (novaQuantidadeCarteira / quantidadeCarteira);

        final double novoPrecoMedio =
            novoTotalInvestido / novaQuantidadeCarteira;

        transaction.update(carteiraRef, {
          'quantidade': novaQuantidadeCarteira,
          'totalInvestido': novoTotalInvestido,
          'precoMedio': novoPrecoMedio,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      transaction.set(transacaoRef, {
        'usuarioId': usuarioId,
        'startupId': startupId,
        'nomeStartup': nomeStartup,
        'quantidade': quantidade,
        'precoToken': precoToken,
        'valorTotal': valorTotal,
        'tipo': 'venda',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
