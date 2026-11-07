// =============================================================================
// nivel_rio_servico_alternado.dart — modo de teste do aviso (passo 49, D14).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// O estágio muda sozinho, sem depender do rio: é assim que se confere a
// notificação com o app fechado. Nunca roda em release (criarServicoDeNivel).
// =============================================================================
import '../../domain/models/leitura_nivel.dart';
import 'nivel_rio_servico.dart';
import 'nivel_rio_servico_simulado.dart';

/// Rio tranquilo na primeira meia hora de cada hora e em cheia na segunda.
class NivelRioServicoAlternado implements NivelRioServico {
  /// Cria o serviço com o relógio [agora] injetado.
  NivelRioServicoAlternado({required this.agora});

  /// Diz que horas são.
  final DateTime Function() agora;

  @override
  Future<List<LeituraNivel>> buscarLeituras() {
    final cenario = agora().minute < 30
        ? CenarioSimulado.normal
        : CenarioSimulado.cheia;
    return NivelRioServicoSimulado(
      cenario: cenario,
      agora: agora,
    ).buscarLeituras();
  }
}
