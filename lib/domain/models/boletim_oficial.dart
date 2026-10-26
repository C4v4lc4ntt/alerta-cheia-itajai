// =============================================================================
// boletim_oficial.dart — situação da cidade publicada pela Defesa Civil.
//
// ETAPA VERDE: código mínimo para os testes passarem (D10).
// =============================================================================

/// Boletim da Defesa Civil de Itajaí, como publicado no portal.
class BoletimOficial {
  /// Cria o boletim com os dados do portal.
  BoletimOficial({
    required this.codigo,
    required this.situacao,
    required this.texto,
    required this.atualizadoEm,
  });

  /// Código da situação no portal (ex.: "normalidade").
  final String codigo;

  /// Nome da situação para exibir (ex.: "Normalidade").
  final String situacao;

  /// Texto do boletim, com os avisos (inclusive de maré).
  final String texto;

  /// Quando a Defesa Civil atualizou o boletim.
  final DateTime atualizadoEm;
}
