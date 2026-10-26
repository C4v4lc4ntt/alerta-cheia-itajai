// =============================================================================
// nivel_rio_servico_simulado.dart — níveis inventados, por cenário.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Usado nos testes e para demonstrar cenários de cheia (D07). Os níveis
// saem das cotas oficiais do catálogo, então continuam coerentes mesmo se
// uma cota mudar.
// =============================================================================
import '../../domain/models/estacao.dart';
import '../../domain/models/leitura_nivel.dart';
import '../catalogo/catalogo_estacoes.dart';
import 'nivel_rio_servico.dart';

/// Situações que o serviço simulado sabe reproduzir.
enum CenarioSimulado {
  /// Todas as estações abaixo da cota de Atenção.
  normal,

  /// Todas as estações acima da cota de Emergência.
  cheia,

  /// RF06: rios em Alerta e ribeirões baixos, sem chuva em Itajaí.
  enchenteSemChuva,
}

/// Serviço de nível que devolve leituras inventadas para um [cenario].
class NivelRioServicoSimulado implements NivelRioServico {
  /// Cria o serviço para um [cenario], com o relógio [agora] injetado.
  NivelRioServicoSimulado({required this.cenario, required this.agora});

  /// Situação reproduzida pelas leituras.
  final CenarioSimulado cenario;

  /// Diz que horas são. No app, o relógio do celular; nos testes, um
  /// horário fixo. Assim o serviço nunca chama DateTime.now() sozinho.
  final DateTime Function() agora;

  @override
  Future<List<LeituraNivel>> buscarLeituras() async {
    final horario = agora();
    return [
      for (final estacao in catalogoEstacoes)
        LeituraNivel(
          codigoEstacao: estacao.codigo,
          nivel: _nivelPara(estacao),
          medidoEm: horario,
        ),
    ];
  }

  // Nível inventado, sempre com folga em relação às cotas da estação.
  double _nivelPara(Estacao estacao) {
    final cotas = estacao.cotas;
    return switch (cenario) {
      CenarioSimulado.normal => cotas.atencao - 0.30,
      CenarioSimulado.cheia => cotas.emergencia + 0.20,
      CenarioSimulado.enchenteSemChuva =>
        estacao.rio.startsWith('Ribeirão')
            ? cotas.atencao - 0.30
            : cotas.alerta + 0.05,
    };
  }
}
