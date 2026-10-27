// =============================================================================
// inicio_view_model_test.dart — RF01, ciclo 6: ViewModel da tela Início.
//
// ETAPA VERMELHA: o ViewModel ainda não existe, então este teste nem compila.
// Os serviços (borda do app) viram mocks do mocktail; as regras do domínio
// (classificar e estágio mais grave) rodam de verdade (CLAUDE.md).
// =============================================================================
import 'package:alerta_cheia_itajai/data/servicos/boletim_servico.dart';
import 'package:alerta_cheia_itajai/data/servicos/nivel_rio_servico.dart';
import 'package:alerta_cheia_itajai/data/servicos/portal_defesa_civil.dart';
import 'package:alerta_cheia_itajai/domain/models/boletim_oficial.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:alerta_cheia_itajai/domain/models/leitura_nivel.dart';
import 'package:alerta_cheia_itajai/domain/models/tabua_mare.dart';
import 'package:alerta_cheia_itajai/ui/inicio/inicio_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class NivelRioServicoMock extends Mock implements NivelRioServico {}

class BoletimServicoMock extends Mock implements BoletimServico {}

void main() {
  late NivelRioServicoMock niveis;
  late BoletimServicoMock boletins;
  late InicioViewModel viewModel;

  final as2130 = DateTime.utc(2026, 10, 26, 21, 30);
  final as2131 = DateTime.utc(2026, 10, 26, 21, 31);

  // Níveis reais de 26/10/2026, abaixo da Atenção nas duas estações.
  final leiturasNormais = [
    LeituraNivel(codigoEstacao: 'DC01', nivel: 0.80, medidoEm: as2131),
    LeituraNivel(codigoEstacao: 'DC07', nivel: 0.06, medidoEm: as2130),
  ];

  final boletim = BoletimOficial(
    codigo: 'normalidade',
    situacao: 'Normalidade',
    texto: 'Sem alertas.',
    atualizadoEm: as2130,
  );

  final tabua = TabuaMare(
    mesReferencia: '2026-10',
    endereco: Uri.parse('https://exemplo.com/tabua.jpeg'),
    tipoArquivo: 'image/jpeg',
    doMesAtual: true,
  );

  setUp(() {
    niveis = NivelRioServicoMock();
    boletins = BoletimServicoMock();
    when(() => niveis.buscarLeituras())
        .thenAnswer((_) async => leiturasNormais);
    when(() => boletins.buscarBoletim()).thenAnswer((_) async => boletim);
    when(() => boletins.buscarTabuaMare()).thenAnswer((_) async => tabua);
    viewModel = InicioViewModel(niveis: niveis, boletins: boletins);
  });

  // Atalho: o estado depois de carregar, já como "pronto".
  Future<InicioPronto> carregarPronto() async {
    await viewModel.carregar();
    return viewModel.estado as InicioPronto;
  }

  group('InicioViewModel', () {
    test('começa carregando', () {
      expect(viewModel.estado, isA<InicioCarregando>());
    });

    test('com os rios baixos, a cidade fica em Monitoramento', () async {
      final estado = await carregarPronto();

      expect(estado.estagioCidade, EstagioAlerta.monitoramento);
    });

    // D02: basta uma estação em Alerta para a cidade ficar em Alerta.
    test('uma estação em Alerta deixa a cidade em Alerta', () async {
      when(() => niveis.buscarLeituras()).thenAnswer(
        (_) async => [
          ...leiturasNormais,
          // DC09: cota de Alerta = 1,42 m (catálogo).
          LeituraNivel(codigoEstacao: 'DC09', nivel: 1.42, medidoEm: as2131),
        ],
      );

      final estado = await carregarPronto();

      expect(estado.estagioCidade, EstagioAlerta.alerta);
    });

    // O app não promete um dado mais novo do que o mais atrasado que usou.
    test('atualizadoEm é o horário da leitura mais antiga', () async {
      final estado = await carregarPronto();

      expect(estado.atualizadoEm, as2130);
    });

    test('traz o boletim oficial e a tábua de marés', () async {
      final estado = await carregarPronto();

      expect(estado.boletim, same(boletim));
      expect(estado.tabuaMare, same(tabua));
    });

    test('avisa a tela quando termina de carregar', () async {
      final estadosAvisados = <EstadoInicio>[];
      viewModel.addListener(() => estadosAvisados.add(viewModel.estado));

      await viewModel.carregar();

      expect(estadosAvisados.last, isA<InicioPronto>());
    });

    test('portal dos níveis fora do ar → erro', () async {
      when(() => niveis.buscarLeituras())
          .thenAnswer((_) async => throw PortalIndisponivel(503));

      await viewModel.carregar();

      expect(viewModel.estado, isA<InicioErro>());
    });

    // Ex.: o portal mudou o formato e nenhuma estação foi reconhecida.
    test('nenhuma leitura recebida → erro, nunca "Monitoramento"', () async {
      when(() => niveis.buscarLeituras()).thenAnswer((_) async => []);

      await viewModel.carregar();

      expect(viewModel.estado, isA<InicioErro>());
    });

    // O boletim é complemento: sem ele, o estágio continua aparecendo.
    test('boletim fora do ar não impede mostrar o estágio', () async {
      when(() => boletins.buscarBoletim())
          .thenAnswer((_) async => throw PortalIndisponivel(503));

      final estado = await carregarPronto();

      expect(estado.estagioCidade, EstagioAlerta.monitoramento);
      expect(estado.boletim, isNull);
    });

    // A tela mostra a estação que mais pesa no estágio da cidade.
    test('estação mais crítica: a de maior estágio', () async {
      when(() => niveis.buscarLeituras()).thenAnswer(
        (_) async => [
          ...leiturasNormais,
          LeituraNivel(codigoEstacao: 'DC09', nivel: 1.42, medidoEm: as2131),
        ],
      );

      final estado = await carregarPronto();

      expect(estado.estacaoMaisCritica.codigo, 'DC09');
      expect(estado.leituraMaisCritica.nivel, 1.42);
    });

    // DC01: 0,80 / 1,21 = 66% da cota; DC07: 0,06 / 1,00 = 6%.
    test('no empate de estágio, a mais perto da cota de Atenção', () async {
      final estado = await carregarPronto();

      expect(estado.estacaoMaisCritica.codigo, 'DC01');
    });

    // O app mostra quando consultou o portal; o relógio é injetado para o
    // teste não depender da hora real.
    test('registra a hora da consulta', () async {
      final as2145 = DateTime.utc(2026, 10, 26, 21, 45);
      viewModel = InicioViewModel(
        niveis: niveis,
        boletins: boletins,
        agora: () => as2145,
      );

      final estado = await carregarPronto();

      expect(estado.consultadoEm, as2145);
    });

    // Mesma ordem da estação mais crítica: maior estágio e, no empate,
    // a mais perto da cota de Atenção.
    test('lista as estações da mais crítica para a menos crítica', () async {
      when(() => niveis.buscarLeituras()).thenAnswer(
        (_) async => [
          ...leiturasNormais, // DC01 (66% da cota) e DC07 (6%)
          LeituraNivel(codigoEstacao: 'DC09', nivel: 1.42, medidoEm: as2131),
        ],
      );

      final estado = await carregarPronto();

      expect(estado.estacoes.map((s) => s.estacao.codigo), [
        'DC09',
        'DC01',
        'DC07',
      ]);
      expect(estado.estacoes.first.estagio, EstagioAlerta.alerta);
    });
  });
}
