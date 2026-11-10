// =============================================================================
// pontos_servico_falso.dart — versão de PontosServico para os testes.
//
// Em vez de gravar no Firestore, guarda os pontos numa lista para o teste
// conferir. Pode simular a falha do envio.
// =============================================================================
import 'package:alerta_cheia_itajai/data/servicos/pontos_servico.dart';
import 'package:alerta_cheia_itajai/domain/models/ponto_alagamento.dart';

/// Envio de pontos em memória.
class PontosServicoFalso implements PontosServico {
  /// Pontos enviados, na ordem.
  final List<PontoAlagamento> enviados = [];

  /// Quando true, simula a falha do envio (sem internet, por exemplo).
  bool deveFalhar = false;

  @override
  Future<void> enviar(PontoAlagamento ponto) async {
    if (deveFalhar) throw Exception('Falha simulada no envio.');
    enviados.add(ponto);
  }
}
