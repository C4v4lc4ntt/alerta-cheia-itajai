// =============================================================================
// nivel_rio_servico_alternado_test.dart — RF02 (passo 49): o modo de teste que
// muda o estágio sozinho, para conferir a notificação com o app fechado.
//
// Escrito ANTES do código (etapa vermelha do TDD). O relógio é injetado, e as
// regras do domínio rodam de verdade. O último grupo protege a regra mais
// importante: o APK dos moradores nunca usa dados simulados.
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/catalogo_estacoes.dart';
import 'package:alerta_cheia_itajai/data/servicos/criar_servico_de_nivel.dart';
import 'package:alerta_cheia_itajai/data/servicos/nivel_rio_servico_alternado.dart';
import 'package:alerta_cheia_itajai/data/servicos/nivel_rio_servico_defesa_civil.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:alerta_cheia_itajai/domain/regras/avaliar_leituras.dart';
import 'package:alerta_cheia_itajai/domain/regras/estagio_mais_grave.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('NivelRioServicoAlternado', () {
    // Valores-limite: a virada acontece em 30 minutos, dentro de cada hora.
    const casos = <int, EstagioAlerta>{
      0: EstagioAlerta.monitoramento,
      29: EstagioAlerta.monitoramento,
      30: EstagioAlerta.emergencia,
      59: EstagioAlerta.emergencia,
    };

    casos.forEach((minuto, esperado) {
      test('minuto $minuto → ${esperado.name}', () async {
        final servico = NivelRioServicoAlternado(
          agora: () => DateTime(2026, 11, 6, 10, minuto),
        );

        final leituras = await servico.buscarLeituras();

        final avaliadas = avaliarLeituras(leituras, catalogoEstacoes);
        expect(
          estagioMaisGrave([for (final item in avaliadas) item.estagio]),
          esperado,
        );
      });
    });

    test('as leituras levam o horário do relógio', () async {
      final horario = DateTime(2026, 11, 6, 10, 30);
      final servico = NivelRioServicoAlternado(agora: () => horario);

      final leituras = await servico.buscarLeituras();

      expect(leituras.first.medidoEm, horario);
    });
  });

  group('criarServicoDeNivel', () {
    final cliente = MockClient((_) async => http.Response('', 200));

    test('sem modo de teste → portal da Defesa Civil', () {
      final servico = criarServicoDeNivel(
        modoTeste: '',
        ehRelease: false,
        cliente: cliente,
      );

      expect(servico, isA<NivelRioServicoDefesaCivil>());
    });

    test('modo alternado → serviço alternado', () {
      final servico = criarServicoDeNivel(
        modoTeste: 'alternado',
        ehRelease: false,
        cliente: cliente,
      );

      expect(servico, isA<NivelRioServicoAlternado>());
    });

    // Modo escrito errado não pode virar dado simulado.
    test('modo desconhecido → portal da Defesa Civil', () {
      final servico = criarServicoDeNivel(
        modoTeste: 'alternadoo',
        ehRelease: false,
        cliente: cliente,
      );

      expect(servico, isA<NivelRioServicoDefesaCivil>());
    });

    // O app é sobre segurança: o APK de release só mostra dados reais.
    test('em release, o modo alternado é ignorado', () {
      final servico = criarServicoDeNivel(
        modoTeste: 'alternado',
        ehRelease: true,
        cliente: cliente,
      );

      expect(servico, isA<NivelRioServicoDefesaCivil>());
    });
  });
}
