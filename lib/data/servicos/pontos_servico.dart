// =============================================================================
// pontos_servico.dart — contrato do envio dos pontos de alagamento (RF03, D17)
// e da leitura em tempo real dos pontos das últimas 6 h (RF04, ciclo 3b).
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

  /// Pontos marcados nas últimas 6 h antes de [agora], numa lista nova a
  /// cada mudança na coleção (tempo real). O corte pelos 3 "Já baixou" e o
  /// passar das horas com o mapa aberto ficam com a regra pontoAtivo.
  Stream<List<PontoAlagamento>> acompanharPontos({required DateTime agora});
}
