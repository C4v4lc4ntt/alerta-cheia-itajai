// =============================================================================
// estagio_alerta.dart — os 4 estágios oficiais da Defesa Civil de Itajaí.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// =============================================================================

/// Estágio de alerta de uma estação (ou da cidade).
///
/// A ORDEM importa: vai do menos grave para o mais grave. Mais adiante
/// usaremos essa ordem para achar o estágio mais grave entre as estações.
enum EstagioAlerta { monitoramento, atencao, alerta, emergencia }
