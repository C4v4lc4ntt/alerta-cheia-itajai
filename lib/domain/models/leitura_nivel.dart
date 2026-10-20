// =============================================================================
// leitura_nivel.dart — uma medição de nível feita numa estação.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// =============================================================================

/// Nível do rio medido numa estação, num horário.
class LeituraNivel {
  /// Cria a leitura e arredonda o [nivel] para centímetros.
  ///
  /// Lança [ArgumentError] se o [codigoEstacao] estiver vazio ou só com
  /// espaços.
  LeituraNivel({
    required this.codigoEstacao,
    required double nivel,
    required this.medidoEm,
  }) : nivel = (nivel * 100).round() / 100 {
    // Por que arredondar: em double, 1.2 + 0.41 vira 1.6099999999999999
    // e ficaria abaixo da cota de 1,61 m. A régua mede em centímetros.
    if (codigoEstacao.trim().isEmpty) {
      throw ArgumentError('O código da estação não pode ficar vazio.');
    }
  }

  /// Código da estação no formato do portal (ex.: "DC01").
  final String codigoEstacao;

  /// Nível em metros, já arredondado para centímetros.
  final double nivel;

  /// Horário em que a estação fez a medição.
  final DateTime medidoEm;
}
