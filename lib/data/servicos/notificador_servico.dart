// =============================================================================
// notificador_servico.dart — contrato de quem mostra o aviso ao morador (RF02).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// A implementação real usará o pacote flutter_local_notifications (D14).
// =============================================================================
import '../../domain/models/estagio_alerta.dart';

/// Mostra as notificações locais do app.
abstract interface class NotificadorServico {
  /// Pede ao sistema a permissão para notificar e diz se ela foi concedida.
  /// Se o morador já respondeu, o sistema responde sem mostrar nada.
  Future<bool> pedirPermissao();

  /// Avisa que o estágio do [bairro] mudou de [anterior] para [atual].
  Future<void> notificarMudanca({
    required String bairro,
    required EstagioAlerta anterior,
    required EstagioAlerta atual,
  });
}
