// =============================================================================
// nivel_rio_servico.dart — contrato de quem fornece os níveis dos rios.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Implementações: a simulada (testes e demonstração) e, no ciclo 4b, a da
// Defesa Civil, que lê o app.json do portal (D07).
// =============================================================================
import '../../domain/models/leitura_nivel.dart';

/// Fonte das leituras de nível das estações.
///
/// Como uma `interface` do Java: o resto do app só conhece este contrato e
/// não sabe se os dados vêm do portal ou do simulado.
abstract interface class NivelRioServico {
  /// Busca a leitura mais recente de cada estação.
  Future<List<LeituraNivel>> buscarLeituras();
}
