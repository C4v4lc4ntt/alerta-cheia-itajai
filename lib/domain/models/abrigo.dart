// =============================================================================
// abrigo.dart — abrigo da Defesa Civil listado na aba Ajuda (RF05, D20).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// A região (CRAS) e a seção de animais ficam no catálogo em data/, não aqui.
// =============================================================================

/// Abrigo que pode abrir numa cheia (ex.: Paróquia São Cristóvão).
class Abrigo {
  /// Cria o abrigo.
  ///
  /// Lança [ArgumentError] se o [nome] ou o [endereco] estiverem vazios ou só
  /// com espaços, ou se o [telefone], quando informado, não tiver 10 ou 11
  /// dígitos (DDD + número, porque ele vai direto no "tel:" do discador).
  Abrigo({required this.nome, required this.endereco, this.telefone}) {
    if (nome.trim().isEmpty) {
      throw ArgumentError('O nome do abrigo não pode ficar vazio.');
    }
    if (endereco.trim().isEmpty) {
      throw ArgumentError('O endereço do abrigo "$nome" não pode ficar vazio.');
    }
    // ^\d{10,11}$: só dígitos, de 10 (fixo) a 11 (celular), com o DDD.
    final numero = telefone;
    if (numero != null && !RegExp(r'^\d{10,11}$').hasMatch(numero)) {
      throw ArgumentError(
        'O telefone "$numero" do abrigo "$nome" deve ter DDD e só dígitos '
        '(10 ou 11).',
      );
    }
  }

  /// Nome como na fonte (ex.: "Paróquia São Cristóvão").
  final String nome;

  /// Endereço como na fonte, com as correções da D20.
  final String endereco;

  /// Telefone com DDD, só dígitos; `null` quando a fonte não traz.
  final String? telefone;
}
