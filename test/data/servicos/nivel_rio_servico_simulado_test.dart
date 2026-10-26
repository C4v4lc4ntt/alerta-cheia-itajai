// =============================================================================
// nivel_rio_servico_simulado_test.dart — RF01, ciclo 4: serviço simulado.
//
// ETAPA VERMELHA: o serviço ainda não existe, então este teste nem compila.
// O simulado serve para os testes e para demonstrar cenários de cheia (D07).
// O horário é injetado: nada de DateTime.now() dentro do serviço.
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/catalogo_estacoes.dart';
import 'package:alerta_cheia_itajai/data/servicos/nivel_rio_servico.dart';
import 'package:alerta_cheia_itajai/data/servicos/nivel_rio_servico_simulado.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:alerta_cheia_itajai/domain/models/leitura_nivel.dart';
import 'package:alerta_cheia_itajai/domain/regras/classificador_estagio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final agora = DateTime(2026, 10, 26, 18, 30);

  // Busca as leituras de um cenário. O tipo da variável é a INTERFACE:
  // assim o teste também garante que o simulado a implementa.
  Future<List<LeituraNivel>> buscar(CenarioSimulado cenario) {
    final NivelRioServico servico = NivelRioServicoSimulado(
      cenario: cenario,
      agora: () => agora,
    );
    return servico.buscarLeituras();
  }

  // Estágio de uma leitura, calculado com as cotas oficiais do catálogo.
  EstagioAlerta estagioDe(LeituraNivel leitura) {
    final estacao = catalogoEstacoes.firstWhere(
      (e) => e.codigo == leitura.codigoEstacao,
    );
    return classificarEstagio(leitura.nivel, estacao.cotas);
  }

  group('NivelRioServicoSimulado', () {
    test('devolve uma leitura para cada estação do catálogo', () async {
      final leituras = await buscar(CenarioSimulado.normal);

      expect(
        leituras.map((l) => l.codigoEstacao),
        unorderedEquals(catalogoEstacoes.map((e) => e.codigo)),
      );
    });

    test('todas as leituras têm o horário injetado', () async {
      final leituras = await buscar(CenarioSimulado.normal);

      for (final leitura in leituras) {
        expect(leitura.medidoEm, agora);
      }
    });

    test('cenário normal: todas as estações em Monitoramento', () async {
      final leituras = await buscar(CenarioSimulado.normal);

      for (final leitura in leituras) {
        expect(estagioDe(leitura), EstagioAlerta.monitoramento);
      }
    });

    test('cenário cheia: todas as estações em Emergência', () async {
      final leituras = await buscar(CenarioSimulado.cheia);

      for (final leitura in leituras) {
        expect(estagioDe(leitura), EstagioAlerta.emergencia);
      }
    });

    // RF06: o rio sobe pela chuva rio acima e pela maré, sem chover em
    // Itajaí. Os ribeirões, que dependem da chuva local, ficam baixos.
    test(
      'enchente sem chuva: rios em Alerta e ribeirões em Monitoramento',
      () async {
        final leituras = await buscar(CenarioSimulado.enchenteSemChuva);

        for (final leitura in leituras) {
          final estacao = catalogoEstacoes.firstWhere(
            (e) => e.codigo == leitura.codigoEstacao,
          );
          final esperado = estacao.rio.startsWith('Ribeirão')
              ? EstagioAlerta.monitoramento
              : EstagioAlerta.alerta;
          expect(estagioDe(leitura), esperado, reason: estacao.codigo);
        }
      },
    );
  });
}
