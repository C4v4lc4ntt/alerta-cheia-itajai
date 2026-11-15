// =============================================================================
// pontos_servico_falso.dart — versão de PontosServico para os testes.
//
// Em vez de gravar no Firestore, guarda os pontos numa lista para o teste
// conferir. Pode simular a falha do envio ou um envio que nunca termina
// (para testar o tempo limite de 15 s, ciclo 21). Na leitura do RF04, o teste
// manda as listas pelo [listas], como o Firestore (ciclo 5a); o "Já baixou"
// (ciclo 4b) ainda não faz nada.
// =============================================================================
import 'dart:async';

import 'package:alerta_cheia_itajai/data/servicos/pontos_servico.dart';
import 'package:alerta_cheia_itajai/domain/models/ponto_alagamento.dart';

/// Envio de pontos em memória.
class PontosServicoFalso implements PontosServico {
  /// Pontos enviados, na ordem.
  final List<PontoAlagamento> enviados = [];

  /// Quando true, simula a falha do envio (sem internet, por exemplo).
  bool deveFalhar = false;

  /// Quando true, o envio nunca termina: um Completer que ninguém completa,
  /// como um Firestore que não responde.
  bool nuncaTermina = false;

  @override
  Future<void> enviar(PontoAlagamento ponto) async {
    if (nuncaTermina) return Completer<void>().future;
    if (deveFalhar) throw Exception('Falha simulada no envio.');
    enviados.add(ponto);
  }

  /// Listas que o "Firestore" manda a quem acompanha os pontos. O teste
  /// chama listas.add(...) e confere listas.hasListener (ciclo 5a).
  final listas = StreamController<List<PontoAlagamento>>();

  @override
  Stream<List<PontoAlagamento>> acompanharPontos({required DateTime agora}) =>
      listas.stream;

  /// Ainda sem efeito: o ViewModel do mapa (ciclo 5) trará o que o teste
  /// dele precisar conferir.
  @override
  Future<void> confirmarJaBaixou(String id) async {}
}
