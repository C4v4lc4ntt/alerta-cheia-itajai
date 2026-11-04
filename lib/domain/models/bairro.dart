// =============================================================================
// bairro.dart — bairro ou localidade com as estações mais próximas (D08).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// =============================================================================

/// Bairro ou localidade que o morador pode escolher no app.
class Bairro {
  /// Cria o bairro.
  ///
  /// Lança [ArgumentError] se o [nome] estiver vazio ou só com espaços, ou se
  /// não houver nenhuma estação em [estacoesProximas].
  Bairro({required this.nome, required this.estacoesProximas}) {
    if (nome.trim().isEmpty) {
      throw ArgumentError('O nome do bairro não pode ficar vazio.');
    }
    if (estacoesProximas.isEmpty) {
      throw ArgumentError('O bairro "$nome" precisa de ao menos uma estação.');
    }
  }

  /// Nome usado no Plano de Contingência (ex.: "Murta").
  final String nome;

  /// Códigos das estações, da mais próxima para a menos próxima. É uma
  /// ESTIMATIVA, não um dado oficial (D08).
  final List<String> estacoesProximas;
}
