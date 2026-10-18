// =============================================================================
// cotas_estacao.dart — as três cotas (em metros) de uma estação.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// =============================================================================

/// Cotas de Atenção, Alerta e Emergência de UMA estação de monitoramento.
///
/// Cada estação tem a sua própria régua, por isso as cotas são um dado da
/// estação e não um número fixo dentro da regra.
class CotasEstacao {
  CotasEstacao({
    required this.atencao,
    required this.alerta,
    required this.emergencia,
  }) {
    // As cotas precisam estar em ordem crescente e sem empate.
    if (!(atencao < alerta && alerta < emergencia)) {
      throw ArgumentError('Cotas fora de ordem.');
    }
  }

  final double atencao;
  final double alerta;
  final double emergencia;
}
