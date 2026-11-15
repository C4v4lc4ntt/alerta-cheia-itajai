// =============================================================================
// mapa_de_pontos_test.dart — RF04 (D13 e D19, ciclo 6a): o mapa com um
// marcador por ponto ativo. Ciclo 6b: o "Já baixou" no marcador (adendos
// da D18 e da D13).
//
// Escrito ANTES do código (etapa vermelha do TDD). Usa os serviços falsos de
// pontos e de localização e o MapaViewModel de verdade. Os ladrilhos ficam
// desligados (mostrarLadrilhos: false), para nenhum teste acessar a internet
// (D19). Posições a partir do centroItajai do catálogo.
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/area_itajai.dart';
import 'package:alerta_cheia_itajai/domain/models/altura_agua.dart';
import 'package:alerta_cheia_itajai/domain/models/leitura_localizacao.dart';
import 'package:alerta_cheia_itajai/domain/models/ponto_alagamento.dart';
import 'package:alerta_cheia_itajai/ui/mapa/mapa_de_pontos.dart';
import 'package:alerta_cheia_itajai/ui/mapa/mapa_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import '../../apoio/localizacao_servico_falso.dart';
import '../../apoio/pontos_servico_falso.dart';

void main() {
  // Hora em que o mapa abre (relógio fixo).
  final abertura = DateTime.utc(2026, 11, 15, 14, 0);
  late PontosServicoFalso pontos;
  late LocalizacaoServicoFalso localizacao;
  late MapaViewModel viewModel;

  setUp(() {
    pontos = PontosServicoFalso();
    localizacao = LocalizacaoServicoFalso(resposta: const PermissaoNegada());
    viewModel = MapaViewModel(
      pontos: pontos,
      localizacao: localizacao,
      agora: () => abertura,
    );
  });

  // Ponto perto do centro de Itajaí, criado [criadoHa] antes da abertura.
  PontoAlagamento ponto({
    required String id,
    required Duration criadoHa,
    double deslocamento = 0,
  }) => PontoAlagamento.registrar(
    latitude: centroItajai.latitude + deslocamento,
    longitude: centroItajai.longitude,
    altura: AlturaAgua.joelho,
    area: areaItajai,
    agora: () => abertura.subtract(criadoHa),
    id: id,
  );

  Future<void> montar(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MapaDePontos(viewModel: viewModel, mostrarLadrilhos: false),
      ),
    ),
  );

  // Tira a tela primeiro e só depois descarta o ViewModel, para não sobrar
  // o Timer da revisão (ciclo 5a) nem um ouvinte num ViewModel descartado.
  Future<void> encerrar(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    viewModel.dispose();
  }

  testWidgets('sem centro → "Buscando sua localização…"', (tester) async {
    await montar(tester);

    expect(find.text('Buscando sua localização…'), findsOneWidget);
    expect(find.byType(FlutterMap), findsNothing);
    await encerrar(tester);
  });

  testWidgets('com centro → mapa centralizado nele', (tester) async {
    // Arrange: sem permissão, o centro é o de Itajaí (D13).
    await viewModel.buscarCentro();

    // Act
    await montar(tester);

    // Assert
    final mapa = tester.widget<FlutterMap>(find.byType(FlutterMap));
    expect(
      mapa.options.initialCenter,
      LatLng(centroItajai.latitude, centroItajai.longitude),
    );
    await encerrar(tester);
  });

  testWidgets('um marcador por ponto ativo', (tester) async {
    // Arrange: 2 pontos ativos e 1 vencido (6 h), perto do centro.
    await viewModel.buscarCentro();
    viewModel.iniciar();
    pontos.listas.add([
      ponto(id: 'a', criadoHa: const Duration(hours: 1)),
      ponto(id: 'b', criadoHa: const Duration(hours: 2), deslocamento: 0.001),
      ponto(id: 'vencido', criadoHa: const Duration(hours: 6)),
    ]);

    // Act
    await montar(tester);
    await tester.pump();

    // Assert: cada marcador leva o ID do ponto na Key.
    expect(find.byKey(const ValueKey('marcador_a')), findsOneWidget);
    expect(find.byKey(const ValueKey('marcador_b')), findsOneWidget);
    expect(find.byKey(const ValueKey('marcador_vencido')), findsNothing);
    await encerrar(tester);
  });

  // D19: a política dos ladrilhos do OpenStreetMap pede a atribuição.
  testWidgets('mostra a atribuição do OpenStreetMap', (tester) async {
    await viewModel.buscarCentro();

    await montar(tester);

    expect(find.textContaining('OpenStreetMap'), findsOneWidget);
    await encerrar(tester);
  });

  // RF04 (ciclo 6b): tocar no marcador abre um painel com a altura, a hora da
  // marcação e o botão "Já baixou" (uma vez por ponto, adendo da D18).
  group('"Já baixou" no marcador', () {
    // Mapa aberto com o ponto 'a', marcado 1 h antes (13:00 UTC = 10:00 em
    // Brasília), com a água no joelho.
    Future<void> abrirComUmPonto(WidgetTester tester) async {
      await viewModel.buscarCentro();
      viewModel.iniciar();
      pontos.listas.add([ponto(id: 'a', criadoHa: const Duration(hours: 1))]);
      await montar(tester);
      await tester.pump();
    }

    // Acessibilidade (CLAUDE.md): o leitor de tela diz o que é o marcador.
    testWidgets('o marcador tem rótulo para leitor de tela', (tester) async {
      await abrirComUmPonto(tester);

      expect(
        find.bySemanticsLabel('Ponto de alagamento: Joelho · 20 a 50 cm'),
        findsOneWidget,
      );
      await encerrar(tester);
    });

    testWidgets('tocar no marcador → painel com a altura e a hora', (
      tester,
    ) async {
      await abrirComUmPonto(tester);

      // Act
      await tester.tap(find.byKey(const ValueKey('marcador_a')));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Joelho · 20 a 50 cm'), findsOneWidget);
      expect(find.text('Marcado às 10:00'), findsOneWidget);
      await encerrar(tester);
    });

    testWidgets('tocar em "Já baixou" → envia o +1 daquele ponto', (
      tester,
    ) async {
      await abrirComUmPonto(tester);
      await tester.tap(find.byKey(const ValueKey('marcador_a')));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Já baixou'));
      await tester.pump();

      // Assert
      expect(pontos.confirmados, ['a']);
      await encerrar(tester);
    });

    testWidgets('depois do toque → "Você já avisou", desativado', (
      tester,
    ) async {
      await abrirComUmPonto(tester);
      await tester.tap(find.byKey(const ValueKey('marcador_a')));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Já baixou'));
      await tester.pump();

      // Assert: o botão muda de texto e fica desativado (onPressed nulo).
      final botao = find.widgetWithText(FilledButton, 'Você já avisou');
      expect(botao, findsOneWidget);
      expect(tester.widget<FilledButton>(botao).onPressed, isNull);
      await encerrar(tester);
    });
  });
}
