// =============================================================================
// pontos_servico.dart — contrato do envio dos pontos de alagamento (RF03, D17).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// A tela conhece só esta interface; a implementação real usa o Cloud
// Firestore, e os testes da tela usarão uma versão falsa (ciclo 19).
// =============================================================================
import '../../domain/models/ponto_alagamento.dart';

/// Envio dos pontos de alagamento para o mapa.
abstract interface class PontosServico {
  /// Envia o [ponto] para o mapa.
  Future<void> enviar(PontoAlagamento ponto);
}
