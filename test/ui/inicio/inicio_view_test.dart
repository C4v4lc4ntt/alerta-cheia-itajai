// =============================================================================
// inicio_view_test.dart — RF01, ciclo 7 (parte b): a tela Início.
//
// ETAPA VERMELHA: a tela ainda não recebe o ViewModel, então este teste nem
// compila. Usa o InicioViewModel de verdade com os serviços mockados: a
// tela é testada do jeito que o morador a vê, sem internet.
// =============================================================================
import 'dart:async';

import 'package:alerta_cheia_itajai/core/tema/cores.dart';
import 'package:alerta_cheia_itajai/data/servicos/boletim_servico.dart';
import 'package:alerta_cheia_itajai/data/servicos/nivel_rio_servico.dart';
import 'package:alerta_cheia_itajai/data/servicos/portal_defesa_civil.dart';
import 'package:alerta_cheia_itajai/domain/models/boletim_oficial.dart';
import 'package:alerta_cheia_itajai/domain/models/leitura_nivel.dart';
import 'package:alerta_cheia_itajai/domain/models/tabua_mare.dart';
import 'package:alerta_cheia_itajai/ui/inicio/inicio_view.dart';
import 'package:alerta_cheia_itajai/ui/inicio/inicio_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../apoio/preferencias_falsas.dart';

class NivelRioServicoMock extends Mock implements NivelRioServico {}

class BoletimServicoMock extends Mock implements BoletimServico {}

void main() {
  late NivelRioServicoMock niveis;
  late BoletimServicoMock boletins;

  // 21:30 UTC = 18:30 em Brasília (medição).
  final as2130 = DateTime.utc(2026, 10, 26, 21, 30);

  // 21:45 UTC = 18:45 em Brasília (consulta ao portal, relógio injetado).
  final as2145 = DateTime.utc(2026, 10, 26, 21, 45);

  final leiturasNormais = [
    LeituraNivel(codigoEstacao: 'DC01', nivel: 0.80, medidoEm: as2130),
    LeituraNivel(codigoEstacao: 'DC07', nivel: 0.06, medidoEm: as2130),
  ];

  setUp(() {
    niveis = NivelRioServicoMock();
    boletins = BoletimServicoMock();
    when(() => niveis.buscarLeituras())
        .thenAnswer((_) async => leiturasNormais);
    when(() => boletins.buscarBoletim()).thenAnswer(
      (_) async => BoletimOficial(
        codigo: 'normalidade',
        situacao: 'Normalidade',
        texto: 'Maré alta entre 13h e 15h.',
        atualizadoEm: as2130,
      ),
    );
    when(() => boletins.buscarTabuaMare()).thenAnswer(
      (_) async => TabuaMare(
        mesReferencia: '2026-10',
        endereco: Uri.parse('https://exemplo.com/tabua.jpeg'),
        tipoArquivo: 'image/jpeg',
        doMesAtual: true,
      ),
    );
  });

  // Monta a tela com o ViewModel de verdade e espera carregar.
  // Por padrão há um bairro escolhido, então o convite não aparece.
  Future<void> abrirTela(
    WidgetTester tester, {
    List<String> bairros = const ['Murta'],
    VoidCallback? aoEscolherBairro,
  }) async {
    final viewModel = InicioViewModel(
      niveis: niveis,
      boletins: boletins,
      preferencias: PreferenciasFalsas(bairros: bairros),
      verificar: () async {},
      agora: () => as2145,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: InicioView(
          viewModel: viewModel,
          aoEscolherBairro: aoEscolherBairro ?? () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('enquanto carrega, mostra o indicador de progresso', (
    tester,
  ) async {
    // Um Future que nunca termina: a tela fica parada em "carregando".
    when(() => niveis.buscarLeituras())
        .thenAnswer((_) => Completer<List<LeituraNivel>>().future);
    final viewModel = InicioViewModel(
      niveis: niveis,
      boletins: boletins,
      preferencias: PreferenciasFalsas(bairros: ['Murta']),
      verificar: () async {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: InicioView(viewModel: viewModel, aoEscolherBairro: () {}),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  // D16 (revisa a D11): o cartão grande mostra a situação OFICIAL.
  testWidgets('o cartão grande mostra a situação oficial e a hora', (
    tester,
  ) async {
    await abrirTela(tester);

    expect(find.text('Situação oficial da Defesa Civil'), findsOneWidget);
    expect(find.text('Normalidade'), findsOneWidget);
    expect(find.text('Boletim de 26/10 às 18:30'), findsOneWidget);
  });

  // A estação em Alerta não muda o que o cartão oficial diz.
  testWidgets('o leitor de tela anuncia a situação oficial', (tester) async {
    when(() => niveis.buscarLeituras()).thenAnswer(
      (_) async => [
        ...leiturasNormais,
        LeituraNivel(codigoEstacao: 'DC09', nivel: 1.42, medidoEm: as2130),
      ],
    );

    await abrirTela(tester);

    expect(
      find.bySemanticsLabel('Situação oficial da Defesa Civil: Normalidade'),
      findsOneWidget,
    );
  });

  // D16: sem boletim, o cartão volta ao estágio calculado e diz isso.
  testWidgets('sem boletim → mostra o estágio mais grave entre as estações', (
    tester,
  ) async {
    when(() => boletins.buscarBoletim()).thenAnswer((_) async => null);
    when(() => niveis.buscarLeituras()).thenAnswer(
      (_) async => [
        ...leiturasNormais,
        LeituraNivel(codigoEstacao: 'DC09', nivel: 1.42, medidoEm: as2130),
      ],
    );

    await abrirTela(tester);

    expect(find.text('Boletim oficial indisponível'), findsOneWidget);
    expect(
      find.text('Estágio mais grave entre as estações: Alerta'),
      findsOneWidget,
    );
  });

  // D05: a barra usa o rótulo curto "Monitor.".
  testWidgets('a barra mostra os 4 estágios', (tester) async {
    await abrirTela(tester);

    for (final rotulo in ['Monitor.', 'Atenção', 'Alerta', 'Emergência']) {
      expect(find.text(rotulo), findsOneWidget, reason: rotulo);
    }
  });

  // Sem bairro, a estação mais crítica tem o cartão dela, com o nome completo.
  testWidgets('mostra a estação mais crítica e o nível com vírgula', (
    tester,
  ) async {
    await abrirTela(tester, bairros: const []);

    expect(find.text('DC01 · ICMBio/CEPSUL · Rio Itajaí-Açu'), findsOneWidget);
    expect(find.text('0,80 m'), findsOneWidget);
  });

  testWidgets('mostra o boletim oficial como veio (D10)', (tester) async {
    await abrirTela(tester);

    expect(find.text('Normalidade'), findsOneWidget);
    expect(find.text('Maré alta entre 13h e 15h.'), findsOneWidget);
  });

  testWidgets('o botão da tábua de marés abre a tela da tábua', (tester) async {
    await abrirTela(tester);

    await tester.ensureVisible(find.text('Ver tábua de marés'));
    await tester.tap(find.text('Ver tábua de marés'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tela_tabua_mare')), findsOneWidget);
  });

  // "Atualizado às" confundia: parecia que o app não tinha consultado.
  testWidgets('o rodapé mostra quando foi medido e quando foi consultado', (
    tester,
  ) async {
    await abrirTela(tester);

    expect(find.text('Medido às 18:30 · consultado às 18:45'), findsOneWidget);
    expect(find.text('Dados: Defesa Civil de Itajaí'), findsOneWidget);
  });

  testWidgets('no erro, "Tentar de novo" busca os dados outra vez', (
    tester,
  ) async {
    when(() => niveis.buscarLeituras())
        .thenAnswer((_) async => throw PortalIndisponivel(503));

    await abrirTela(tester);
    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();

    verify(() => niveis.buscarLeituras()).called(2);
  });

  // D10: no começo do mês a Defesa Civil pode ainda não ter publicado a
  // tábua nova; o portal devolve a anterior e o app precisa deixar claro.
  testWidgets('avisa quando a tábua não é do mês atual', (tester) async {
    when(() => boletins.buscarTabuaMare()).thenAnswer(
      (_) async => TabuaMare(
        mesReferencia: '2026-10',
        endereco: Uri.parse('https://exemplo.com/tabua.jpeg'),
        tipoArquivo: 'image/jpeg',
        doMesAtual: false,
      ),
    );

    await abrirTela(tester);

    expect(
      find.text(
        'A tábua deste mês ainda não foi publicada. '
        'Mostrando a de 2026-10.',
      ),
      findsOneWidget,
    );
  });

  // No Android, "fechar" o app costuma só mandá-lo para o segundo plano:
  // ao voltar, a tela não é recriada e precisa buscar de novo.
  testWidgets('ao voltar para o app, busca os dados de novo', (tester) async {
    await abrirTela(tester);

    // O Flutter exige a sequência real de estados, passo a passo:
    // sair do app (inactive → hidden → paused) e voltar (o caminho inverso).
    for (final estado in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(estado);
    }
    await tester.pumpAndSettle();

    verify(() => niveis.buscarLeituras()).called(2);
  });

  testWidgets('puxar a tela para baixo busca os dados de novo', (tester) async {
    await abrirTela(tester);

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    verify(() => niveis.buscarLeituras()).called(2);
  });

  testWidgets('"Todas as estações" abre a lista com nível e estágio', (
    tester,
  ) async {
    await abrirTela(tester);

    await tester.ensureVisible(find.text('Todas as estações (2)'));
    await tester.tap(find.text('Todas as estações (2)'));
    await tester.pumpAndSettle();

    expect(find.text('DC07 · Portal · Ribeirão da Murta'), findsOneWidget);
    expect(find.text('0,06 m'), findsOneWidget);
  });

  // D15: a tela Início convida quem ainda não escolheu um bairro.
  group('convite para escolher um bairro', () {
    const convite =
        'Escolha um bairro para receber avisos quando o estágio mudar.';

    testWidgets('sem bairro escolhido → mostra o convite', (tester) async {
      await abrirTela(tester, bairros: const []);

      expect(find.text(convite), findsOneWidget);
    });

    testWidgets('com bairro escolhido → não mostra o convite', (tester) async {
      await abrirTela(tester);

      expect(find.text(convite), findsNothing);
    });

    testWidgets('tocar em Escolher bairro chama a navegação', (tester) async {
      var toques = 0;
      await abrirTela(
        tester,
        bairros: const [],
        aoEscolherBairro: () => toques++,
      );

      await tester.tap(find.text('Escolher bairro'));

      expect(toques, 1);
    });
  });

  // D16: cor do cartão oficial e cartões dos bairros escolhidos.
  group('destaque oficial e bairros (D16)', () {
    // Níveis reais do portal em 07/11/2026, 07:31 (10:31 UTC).
    final as1031 = DateTime.utc(2026, 11, 7, 10, 31);
    final leiturasDe0711 = [
      LeituraNivel(codigoEstacao: 'DC02', nivel: 0.97, medidoEm: as1031),
      LeituraNivel(codigoEstacao: 'DC07', nivel: 1.53, medidoEm: as1031),
      LeituraNivel(codigoEstacao: 'DC09', nivel: 1.42, medidoEm: as1031),
    ];

    void boletimCom(String situacao) {
      when(() => boletins.buscarBoletim()).thenAnswer(
        (_) async => BoletimOficial(
          codigo: 'qualquer',
          situacao: situacao,
          texto: 'Texto do boletim.',
          atualizadoEm: as1031,
        ),
      );
    }

    Color corDoCartaoOficial(WidgetTester tester) {
      final caixa = tester.widget<Container>(
        find.byKey(const Key('cartao_oficial')),
      );
      return (caixa.decoration! as BoxDecoration).color!;
    }

    testWidgets('boletim em Alerta → cartão na cor de Alerta', (tester) async {
      boletimCom('Alerta');

      await abrirTela(tester);

      expect(corDoCartaoOficial(tester), CoresApp.estagioAlerta);
    });

    // O app não adivinha: mostra o nome que veio, na cor principal.
    testWidgets('nome desconhecido → cor principal e o nome como veio', (
      tester,
    ) async {
      boletimCom('Alerta Máximo');

      await abrirTela(tester);

      expect(corDoCartaoOficial(tester), CoresApp.principal);
      expect(find.text('Alerta Máximo'), findsOneWidget);
      expect(find.text('Monitor.'), findsNothing); // sem a barra de estágios
    });

    // O caso real de 07/11: oficial em Atenção, DC07 acima da Emergência.
    testWidgets('Atenção oficial com estação em Emergência → destaca Atenção', (
      tester,
    ) async {
      boletimCom('Atenção');
      when(() => niveis.buscarLeituras())
          .thenAnswer((_) async => leiturasDe0711);

      await abrirTela(tester);

      expect(
        find.bySemanticsLabel('Situação oficial da Defesa Civil: Atenção'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Estação mais grave da cidade: DC07 · Portal · Ribeirão da Murta '
          '· 1,53 m · Emergência',
        ),
        findsOneWidget,
      );
    });

    testWidgets('cartão do bairro com as estações próximas', (tester) async {
      when(() => niveis.buscarLeituras())
          .thenAnswer((_) async => leiturasDe0711);

      await abrirTela(tester);

      expect(
        find.text('Murta · estações próximas (estimativa)'),
        findsOneWidget,
      );
      expect(
        find.text('DC09 · Ponte da Rua Lidia Puel Peixer · Ribeirão da Murta'),
        findsOneWidget,
      );
      expect(find.text('1,42 m · Alerta'), findsOneWidget);
    });

    // Com bairro, os cartões dos bairros ocupam o lugar da estação mais
    // crítica, que vira a linha menor quando ficar de fora.
    testWidgets('com bairro → sem o cartão da estação mais crítica', (
      tester,
    ) async {
      await abrirTela(tester);

      expect(find.text('Estação mais perto da cota'), findsNothing);
    });

    testWidgets('mais grave dentro de um bairro → sem a linha menor', (
      tester,
    ) async {
      when(() => niveis.buscarLeituras())
          .thenAnswer((_) async => leiturasDe0711);

      await abrirTela(tester, bairros: const ['Portal I e II']);

      expect(find.textContaining('Estação mais grave da cidade'), findsNothing);
    });

    testWidgets('dois bairros → dois cartões', (tester) async {
      await abrirTela(tester, bairros: const ['Murta', 'Centro']);

      expect(find.textContaining('· estações próximas'), findsNWidgets(2));
    });

    // Murta usa DC02 e DC09, que não têm leitura no cenário padrão.
    testWidgets('bairro sem leitura nas estações próximas → avisa', (
      tester,
    ) async {
      await abrirTela(tester);

      expect(
        find.text('Sem leitura das estações próximas agora.'),
        findsOneWidget,
      );
    });
  });
}
