// =============================================================================
// mapa_view_model_test.dart — RF04 (D06 e adendos da D06 e da D18): o estado
// da aba Mapa.
//
// Escrito ANTES do código (etapa vermelha do TDD). Usa o serviço falso de
// pontos, que manda listas como o Firestore, e um relógio controlado pelo
// teste. O testWidgets controla o tempo do Timer: tester.pump avança o
// relógio do teste sem esperar de verdade. As posições saem do catálogo
// areaItajai, sem coordenadas inventadas.
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/area_itajai.dart';
import 'package:alerta_cheia_itajai/domain/models/altura_agua.dart';
import 'package:alerta_cheia_itajai/domain/models/ponto_alagamento.dart';
import 'package:alerta_cheia_itajai/ui/mapa/mapa_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/pontos_servico_falso.dart';

// Centro do retângulo de Itajaí: com certeza dentro da área.
final _latitude = (areaItajai.latitudeMinima + areaItajai.latitudeMaxima) / 2;
final _longitude =
    (areaItajai.longitudeMinima + areaItajai.longitudeMaxima) / 2;

void main() {
  // Hora em que o mapa abre; o teste avança este relógio junto com o pump.
  final abertura = DateTime.utc(2026, 11, 15, 14, 0);
  late DateTime agora;
  late PontosServicoFalso pontos;
  late MapaViewModel viewModel;

  setUp(() {
    agora = abertura;
    pontos = PontosServicoFalso();
    viewModel = MapaViewModel(pontos: pontos, agora: () => agora);
  });

  // Ponto criado [criadoHa] antes da abertura do mapa.
  PontoAlagamento ponto({required Duration criadoHa, int jaBaixou = 0}) =>
      PontoAlagamento.registrar(
        latitude: _latitude,
        longitude: _longitude,
        altura: AlturaAgua.joelho,
        area: areaItajai,
        agora: () => abertura.subtract(criadoHa),
        jaBaixou: jaBaixou,
      );

  // Cada teste descarta o ViewModel no fim, para não sobrar o Timer da
  // revisão pendente (o testWidgets reclama de Timer esquecido).
  testWidgets('lista recebida → só os pontos ativos', (tester) async {
    // Arrange: um ativo, um vencido (6 h) e um com 3 "Já baixou".
    final ativo = ponto(criadoHa: const Duration(hours: 1));
    final vencido = ponto(criadoHa: const Duration(hours: 6));
    final comTresJaBaixou = ponto(
      criadoHa: const Duration(hours: 1),
      jaBaixou: 3,
    );
    viewModel.iniciar();

    // Act: o "Firestore" manda a lista.
    pontos.listas.add([ativo, vencido, comTresJaBaixou]);
    await tester.pump();

    // Assert
    expect(viewModel.pontosAtivos, [ativo]);
    viewModel.dispose();
  });

  testWidgets('lista recebida → avisa a tela', (tester) async {
    var avisos = 0;
    viewModel.addListener(() => avisos++);
    viewModel.iniciar();

    pontos.listas.add([ponto(criadoHa: const Duration(hours: 1))]);
    await tester.pump();

    expect(avisos, greaterThanOrEqualTo(1));
    viewModel.dispose();
  });

  // Revisão a cada minuto: o ponto sai da tela mesmo sem lista nova.
  testWidgets('na revisão de 1 minuto → o ponto que completou 6 h some', (
    tester,
  ) async {
    // Arrange: ponto com 5 h 59 min, ainda ativo na abertura.
    viewModel.iniciar();
    pontos.listas.add([ponto(criadoHa: const Duration(hours: 5, minutes: 59))]);
    await tester.pump();
    expect(viewModel.pontosAtivos, hasLength(1));

    // Act: passa 1 minuto sem lista nova; o ponto completa 6 h.
    agora = abertura.add(const Duration(minutes: 1));
    await tester.pump(const Duration(minutes: 1));

    // Assert
    expect(viewModel.pontosAtivos, isEmpty);
    viewModel.dispose();
  });

  // Mapa fechado não pode continuar ouvindo o Firestore (leituras e memória).
  testWidgets('descartado → para de ouvir o Firestore', (tester) async {
    viewModel.iniciar();
    await tester.pump();
    expect(pontos.listas.hasListener, isTrue);

    viewModel.dispose();

    expect(pontos.listas.hasListener, isFalse);
  });
}
