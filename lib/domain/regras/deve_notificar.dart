// =============================================================================
// deve_notificar.dart — regra do RF02 (D06 e D12): decide se a leitura nova
// gera uma notificação local.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// =============================================================================
import '../models/estagio_alerta.dart';

/// Devolve `true` quando o estágio mudou em relação à leitura [anterior].
///
/// Sem estágio [anterior] não há mudança, então a primeira leitura não
/// notifica (D12). Subir ou descer de estágio notifica; repetir o mesmo, não.
bool deveNotificar({
  required EstagioAlerta? anterior,
  required EstagioAlerta atual,
}) {
  return anterior != null && anterior != atual;
}
