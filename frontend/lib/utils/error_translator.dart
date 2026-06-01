// ARQUIVO: frontend/lib/utils/error_translator.dart

/*
Traduz mensagens de erro do Firebase e do sistema para português.
*/
class ErrorTranslator {
  static const Map<String, String> _erros = {
    // ── AUTENTICAÇÃO ─────────────────────────────────────────────
    'user-not-found':
        'Usuário não encontrado. Verifique o e-mail informado.',
    'wrong-password':
        'Senha incorreta. Tente novamente.',
    'invalid-credential':
        'E-mail ou senha inválidos. Tente novamente.',
    'email-already-in-use':
        'Este e-mail já está cadastrado. Faça login ou use outro e-mail.',
    'weak-password':
        'Senha muito fraca. Use pelo menos 6 caracteres.',
    'invalid-email':
        'E-mail inválido. Verifique o formato digitado.',
    'user-disabled':
        'Esta conta foi desativada. Entre em contato com o suporte.',
    'too-many-requests':
        'Muitas tentativas. Aguarde alguns minutos e tente novamente.',
    'network-request-failed':
        'Sem conexão com a internet. Verifique sua rede.',
    'requires-recent-login':
        'Por segurança, faça login novamente para continuar.',
    'account-exists-with-different-credential':
        'Já existe uma conta com este e-mail usando outro método de login.',
    'popup-closed-by-user':
        'Login cancelado. A janela foi fechada antes de concluir.',
    'expired-action-code':
        'O link expirou. Solicite um novo.',
    'invalid-action-code':
        'Link inválido. Solicite um novo.',

    // ── FIRESTORE ────────────────────────────────────────────────
    'permission-denied':
        'Você não tem permissão para realizar esta ação.',
    'not-found':
        'O recurso solicitado não foi encontrado.',
    'already-exists':
        'Este registro já existe.',
    'resource-exhausted':
        'Limite de requisições atingido. Tente novamente em instantes.',
    'unavailable':
        'Serviço temporariamente indisponível. Tente novamente.',
    'deadline-exceeded':
        'A operação demorou muito. Verifique sua conexão e tente novamente.',
    'cancelled':
        'Operação cancelada.',
    'unauthenticated':
        'Você precisa estar logado para realizar esta ação.',

    // ── GENÉRICOS ────────────────────────────────────────────────
    'internal':
        'Erro interno. Tente novamente mais tarde.',
    'unknown':
        'Ocorreu um erro inesperado. Tente novamente.',
  };

  /*
  Recebe uma mensagem de erro em inglês e retorna a versão em português.
  Se não encontrar tradução, retorna a mensagem original limpa.
  */
  static String traduzir(dynamic erro) {
    final mensagem = erro.toString();

    // Tenta extrair o código do erro do Firebase
    // Ex: "[firebase_auth/wrong-password] ..." → "wrong-password"
    final regex = RegExp(r'\[[\w-]+\/([\w-]+)\]');
    final match = regex.firstMatch(mensagem);

    if (match != null) {
      final codigo = match.group(1) ?? '';
      if (_erros.containsKey(codigo)) {
        return _erros[codigo]!;
      }
    }

    // Tenta encontrar qualquer chave conhecida dentro da mensagem
    for (final entry in _erros.entries) {
      if (mensagem.contains(entry.key)) {
        return entry.value;
      }
    }

    // Se não encontrou tradução, limpa a mensagem e retorna
    return mensagem
        .replaceAll('Exception: ', '')
        .replaceAll('[firebase_auth]', '')
        .replaceAll('[cloud_firestore]', '')
        .trim();
  }
}