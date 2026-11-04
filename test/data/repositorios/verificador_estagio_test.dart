// =============================================================================
// verificador_estagio_test.dart — RF02 (D06, D12, D14 e D15): a verificação do
// estágio, a mesma com o app aberto e em segundo plano.
//
// ETAPA VERMELHA: o verificador e as interfaces ainda não existem, então este
// teste nem compila. Só a fonte das leituras é mock; as regras e as cotas do
// catálogo rodam de verdade.
// =============================================================================
import 'package:alerta_cheia_itajai/data/repositorios/verificador_estagio.dart';
import 'package:alerta_cheia_itajai/data/servicos/nivel_rio_servico.dart';
import 'package:alerta_cheia_itajai/data/servicos/portal_defesa_civil.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:alerta_cheia_itajai/domain/models/leitura_nivel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../apoio/notificador_falso.dart';
import '../../apoio/preferencias_falsas.dart';

class _NiveisMock extends Mock implements NivelRioServico {}

void main() {
  // Cotas da DC01 no catálogo oficial: Atenção 1,21 m e Alerta 1,61 m.
  const nivelMonitoramento = 1.20;
  const nivelAtencao = 1.21;
  const nivelAlerta = 1.61;

  late _NiveisMock niveis;
  late PreferenciasFalsas preferencias;
  late NotificadorFalso notificador;
  late VerificadorEstagio verificador;

  LeituraNivel leitura(String codigo, double nivel) => LeituraNivel(
    codigoEstacao: codigo,
    nivel: nivel,
    medidoEm: DateTime.utc(2026, 11, 4, 12),
  );

  // Define o que o portal responde: uma leitura da DC01 no nível pedido.
  void rioEm(double nivel) {
    when(() => niveis.buscarLeituras())
        .thenAnswer((_) async => [leitura('DC01', nivel)]);
  }

  setUp(() {
    niveis = _NiveisMock();
    preferencias = PreferenciasFalsas(bairros: ['Murta']);
    notificador = NotificadorFalso();
    verificador = VerificadorEstagio(
      niveis: niveis,
      preferencias: preferencias,
      notificador: notificador,
    );
  });

  group('VerificadorEstagio', () {
    test('estágio subiu → notifica e salva o novo estágio', () async {
      preferencias.ultimoEstagio = EstagioAlerta.monitoramento;
      rioEm(nivelAtencao);

      await verificador.verificar();

      expect(notificador.pedidas, [
        (
          bairro: 'Murta',
          anterior: EstagioAlerta.monitoramento,
          atual: EstagioAlerta.atencao,
        ),
      ]);
      expect(preferencias.ultimoEstagio, EstagioAlerta.atencao);
    });

    test('estágio desceu → notifica e salva o novo estágio', () async {
      preferencias.ultimoEstagio = EstagioAlerta.alerta;
      rioEm(nivelAtencao);

      await verificador.verificar();

      expect(notificador.pedidas, [
        (
          bairro: 'Murta',
          anterior: EstagioAlerta.alerta,
          atual: EstagioAlerta.atencao,
        ),
      ]);
      expect(preferencias.ultimoEstagio, EstagioAlerta.atencao);
    });

    test('mesmo estágio → não notifica', () async {
      preferencias.ultimoEstagio = EstagioAlerta.alerta;
      rioEm(nivelAlerta);

      await verificador.verificar();

      expect(notificador.pedidas, isEmpty);
      expect(preferencias.ultimoEstagio, EstagioAlerta.alerta);
    });

    // D12: a primeira leitura é só o ponto de partida.
    test('primeira leitura → só salva, sem notificar', () async {
      rioEm(nivelMonitoramento);

      await verificador.verificar();

      expect(notificador.pedidas, isEmpty);
      expect(preferencias.ultimoEstagio, EstagioAlerta.monitoramento);
    });

    // D15: sem bairro escolhido, nem consulta o portal.
    test('sem bairro escolhido → não busca, não notifica, não salva', () async {
      preferencias.bairros = [];

      await verificador.verificar();

      verifyNever(() => niveis.buscarLeituras());
      expect(notificador.pedidas, isEmpty);
      expect(preferencias.ultimoEstagio, isNull);
    });

    // D15: uma notificação para cada bairro escolhido.
    test('dois bairros → uma notificação para cada um', () async {
      preferencias
        ..bairros = ['Murta', 'Centro']
        ..ultimoEstagio = EstagioAlerta.monitoramento;
      rioEm(nivelAtencao);

      await verificador.verificar();

      expect(notificador.pedidas.map((pedida) => pedida.bairro), [
        'Murta',
        'Centro',
      ]);
    });

    // D02 e D08: a estação mais grave define o estágio do bairro.
    test('uma estação em Alerta entre outras → notifica Alerta', () async {
      preferencias.ultimoEstagio = EstagioAlerta.monitoramento;
      when(() => niveis.buscarLeituras()).thenAnswer(
        (_) async => [leitura('DC01', nivelAlerta), leitura('DC02', 0.50)],
      );

      await verificador.verificar();

      expect(notificador.pedidas.single.atual, EstagioAlerta.alerta);
    });

    // D14: a falha não muda nada e não derruba a tarefa em segundo plano.
    test('falha na busca → mantém o estágio e não notifica', () async {
      preferencias.ultimoEstagio = EstagioAlerta.atencao;
      when(() => niveis.buscarLeituras()).thenThrow(PortalIndisponivel(503));

      await verificador.verificar();

      expect(notificador.pedidas, isEmpty);
      expect(preferencias.ultimoEstagio, EstagioAlerta.atencao);
    });

    // Regra de segurança: sem leitura reconhecida, nunca assume Monitoramento.
    test('nenhuma estação reconhecida → mantém o estágio salvo', () async {
      preferencias.ultimoEstagio = EstagioAlerta.alerta;
      when(() => niveis.buscarLeituras())
          .thenAnswer((_) async => [leitura('XX99', 0.10)]);

      await verificador.verificar();

      expect(notificador.pedidas, isEmpty);
      expect(preferencias.ultimoEstagio, EstagioAlerta.alerta);
    });

    // Se o aviso falhar, a próxima verificação ainda enxerga a mudança.
    test('falha ao notificar → não salva o novo estágio', () async {
      preferencias.ultimoEstagio = EstagioAlerta.monitoramento;
      notificador.deveFalhar = true;
      rioEm(nivelAtencao);

      await verificador.verificar();

      expect(preferencias.ultimoEstagio, EstagioAlerta.monitoramento);
    });
  });
}
