// =============================================================================
// inicio_view_test.dart — RF01, ciclo 7 (parte b): a tela Início.
//
// ETAPA VERMELHA: a tela ainda não recebe o ViewModel, então este teste nem
// compila. Usa o InicioViewModel de verdade com os serviços mockados: a
// tela é testada do jeito que o morador a vê, sem internet.
// =============================================================================
import 'dart:async';

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
  Future<void> abrirTela(WidgetTester tester) async {
    final viewModel = InicioViewModel(
      niveis: niveis,
      boletins: boletins,
      agora: () => as2145,
    );
    await tester.pumpWidget(
      MaterialApp(home: InicioView(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('enquanto carrega, mostra o indicador de progresso', (
    tester,
  ) async {
    // Um Future que nunca termina: a tela fica parada em "carregando".
    when(() => niveis.buscarLeituras())
        .thenAnswer((_) => Completer<List<LeituraNivel>>().future);
    final viewModel = InicioViewModel(niveis: niveis, boletins: boletins);

    await tester.pumpWidget(
      MaterialApp(home: InicioView(viewModel: viewModel)),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('mostra o estágio da cidade por extenso', (tester) async {
    await abrirTela(tester);

    expect(find.text('Monitoramento'), findsOneWidget);
  });

  // D11: o título diz o que o app calcula, para não parecer uma declaração
  // oficial da Defesa Civil (o boletim oficial vem logo abaixo).
  testWidgets('o cartão grande diz que é o mais grave entre as estações', (
    tester,
  ) async {
    await abrirTela(tester);

    expect(find.text('Estágio mais grave entre as estações'), findsOneWidget);
    expect(find.text('ESTÁGIO EM ITAJAÍ'), findsNothing);
  });

  testWidgets('o leitor de tela anuncia o estágio da cidade', (tester) async {
    when(() => niveis.buscarLeituras()).thenAnswer(
      (_) async => [
        ...leiturasNormais,
        LeituraNivel(codigoEstacao: 'DC09', nivel: 1.42, medidoEm: as2130),
      ],
    );

    await abrirTela(tester);

    expect(
      find.bySemanticsLabel('Estágio mais grave entre as estações: Alerta'),
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

  testWidgets('mostra a estação mais crítica e o nível com vírgula', (
    tester,
  ) async {
    await abrirTela(tester);

    expect(find.textContaining('DC01'), findsOneWidget);
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

    expect(find.text('DC07 · Ribeirão da Murta'), findsOneWidget);
    expect(find.text('0,06 m'), findsOneWidget);
  });
}
