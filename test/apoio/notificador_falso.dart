// =============================================================================
// notificador_falso.dart — versão de NotificadorServico para os testes.
//
// Em vez de mostrar a notificação no celular, anota o pedido numa lista para o
// teste conferir.
// =============================================================================
import 'package:alerta_cheia_itajai/data/servicos/notificador_servico.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';

/// Uma notificação pedida ao notificador.
typedef NotificacaoPedida = ({
  String bairro,
  EstagioAlerta anterior,
  EstagioAlerta atual,
});

/// Notificador que só registra os pedidos.
class NotificadorFalso implements NotificadorServico {
  /// Notificações pedidas, na ordem.
  final List<NotificacaoPedida> pedidas = [];

  /// Quando true, simula a falha ao mostrar a notificação.
  bool deveFalhar = false;

  /// Resposta simulada do sistema ao pedido de permissão.
  bool permissaoConcedida = true;

  /// Quantas vezes a permissão foi pedida.
  int pedidosDePermissao = 0;

  @override
  Future<bool> pedirPermissao() async {
    pedidosDePermissao++;
    return permissaoConcedida;
  }

  @override
  Future<void> notificarMudanca({
    required String bairro,
    required EstagioAlerta anterior,
    required EstagioAlerta atual,
  }) async {
    if (deveFalhar) throw StateError('Falha simulada na notificação.');
    pedidas.add((bairro: bairro, anterior: anterior, atual: atual));
  }
}
