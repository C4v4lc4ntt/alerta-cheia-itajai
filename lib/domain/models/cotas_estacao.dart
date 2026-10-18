// =============================================================================
// cotas_estacao.dart — as três cotas (em metros) de uma estação.
//
// ETAPA REFATORAR: mesmo comportamento da etapa verde (os testes não mudam),
// mas com a validação extraída para um método e mensagens de erro que dizem
// QUAIS valores estão errados — ajuda muito quando alguém digitar uma cota
// errada no catálogo.
// =============================================================================

/// Cotas de Atenção, Alerta e Emergência de UMA estação de monitoramento.
///
/// Cada estação tem a sua própria régua (o "zero" muda de lugar), por isso
/// as cotas são um DADO da estação e não um número fixo dentro da regra.
/// Fonte dos valores: catálogo oficial da Defesa Civil de Itajaí.
class CotasEstacao {
  /// Cria as cotas e valida que estão em ordem crescente e sem empate.
  ///
  /// Lança [ArgumentError] se a ordem `atenção < alerta < emergência`
  /// não for respeitada.
  CotasEstacao({
    required this.atencao,
    required this.alerta,
    required this.emergencia,
  }) {
    _validarOrdem();
  }

  /// Nível (m) a partir do qual a estação entra em Atenção.
  final double atencao;

  /// Nível (m) a partir do qual a estação entra em Alerta.
  final double alerta;

  /// Nível (m) a partir do qual a estação entra em Emergência.
  final double emergencia;

  // Regra de consistência: cada cota precisa ser maior que a anterior.
  void _validarOrdem() {
    if (atencao >= alerta) {
      throw ArgumentError(
        'A cota de Atenção ($atencao m) deve ser menor que a de Alerta '
        '($alerta m).',
      );
    }
    if (alerta >= emergencia) {
      throw ArgumentError(
        'A cota de Alerta ($alerta m) deve ser menor que a de Emergência '
        '($emergencia m).',
      );
    }
  }

  // toString deixa as mensagens de teste e os logs legíveis,
  // ex.: "CotasEstacao(atenção: 1.21, alerta: 1.61, emergência: 1.75)".
  @override
  String toString() =>
      'CotasEstacao(atenção: $atencao, alerta: $alerta, '
      'emergência: $emergencia)';
}
