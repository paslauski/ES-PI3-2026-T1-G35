//isabela
// ARQUIVO: functions/src/startups/shared/validation.ts
// OBJETIVO: Limpar e validar os textos antes de salvar no banco de dados.

export function normalizeString(value: unknown): string | undefined {
  // Se o que chegou não for um texto (string), ele recusa e devolve "undefined"
    if (typeof value !== "string") {
        return undefined;
    }

  // O .trim() corta os espaços em branco no começo e no final da palavra
    const trimmed = value.trim();

  // Se depois de cortar os espaços ainda sobrar alguma letra, ele devolve o texto limpo.
  // Se ficou vazio, ele devolve "undefined" (inválido).
    return trimmed.length > 0 ? trimmed : undefined;
}