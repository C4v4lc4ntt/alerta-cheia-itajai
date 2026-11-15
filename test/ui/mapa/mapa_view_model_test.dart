// =============================================================================
// mapa_view_model_test.dart — RF04 (D06 e adendos da D06 e da D18): o estado
// da aba Mapa. Ciclo 5a: só os pontos ativos; ciclo 5b: "Já baixou" uma vez
// por ponto; ciclo 5c: centro do mapa (D13); ciclo 6d: nada quebra quando
// uma resposta chega depois de o ViewModel ser descartado (aba fechada).
//
// Escrito ANTES do código (etapa vermelha do TDD). Usa o serviço falso de
// pontos, que manda listas como o Firestore, e um relógio controlado pelo
// teste. O testWidgets controla o tempo do Timer: tester.pump avança o
// relógio do teste sem esperar de verdade. As posições saem do catálogo
// areaItajai, sem coordenadas inventadas.
// =============================================================================
import 'dart:async';

import 'package:alerta_cheia_itajai/data/catalogo/area_itajai.dart';
import 'package:alerta_cheia_itajai/domain/models/altura_agua.dart';
import 'package:alerta_cheia_itajai/domain/models/leitura_localizacao.dart';
import 'package:alerta_cheia_itajai/domain/models/ponto_alagamento.dart';
import 'package:alerta_cheia_itajai/ui/mapa/mapa_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/localizacao_servico_falso.dart';
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
  late LocalizacaoServicoFalso localizacao;
  late MapaViewModel viewModel;

  setUp(() {
    agora = abertura;
    pontos = PontosServicoFalso();
    localizacao = LocalizacaoServicoFalso(resposta: const PermissaoNegada());
    viewModel = MapaViewModel(
      pontos: pontos,
      localizacao: localizacao,
      agora: () => agora,
    );
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

  // RF04 (adendo da D18, ciclo 5b): uma confirmação por ponto enquanto o
  // app estiver aberto. O botão é marcado na hora do toque, sem esperar o
  // servidor (sem internet, o +1 fica na fila do Firestore).
  group('"Já baixou"', () {
    test('tocar → envia o +1 daquele ponto', () async {
      // Act
      await viewModel.confirmarJaBaixou('abc123');

      // Assert
      expect(pontos.confirmados, ['abc123']);
    });

    test('depois do toque → o botão daquele ponto fica desativado na hora', () {
      // Arrange: o envio nunca termina, como um celular sem internet.
      pontos.nuncaTermina = true;

      // Act: sem await, como o toque na tela.
      unawaited(viewModel.confirmarJaBaixou('abc123'));

      // Assert: o ponto tocado fica bloqueado; o outro continua livre.
      expect(viewModel.podeConfirmar('abc123'), isFalse);
      expect(viewModel.podeConfirmar('outro'), isTrue);
    });

    test('servidor recusou → o botão volta a funcionar', () async {
      pontos.deveFalhar = true;

      await viewModel.confirmarJaBaixou('abc123');

      expect(viewModel.podeConfirmar('abc123'), isTrue);
    });
  });

  // RF04 (D13, ciclo 5c): o GPS é lido uma vez, só para centralizar; a
  // posição não é guardada nem enviada (LGPD). Sem posição, ou com a posição
  // fora da área, o mapa abre em Itajaí.
  group('centro do mapa (D13)', () {
    test('antes da leitura → sem centro (mapa ainda buscando)', () {
      expect(viewModel.centro, isNull);
    });

    test('posição lida dentro de Itajaí → centraliza nela', () async {
      localizacao.resposta = LocalizacaoObtida(
        latitude: _latitude,
        longitude: _longitude,
        precisaoMetros: 12,
      );

      await viewModel.buscarCentro();

      expect(viewModel.centro, (latitude: _latitude, longitude: _longitude));
    });

    final semPosicao = <String, LeituraLocalizacao>{
      'GPS desligado → centraliza em Itajaí': const GpsDesligado(),
      'permissão negada → centraliza em Itajaí': const PermissaoNegada(),
      'permissão bloqueada → centraliza em Itajaí': const PermissaoBloqueada(),
      'falha na leitura → centraliza em Itajaí': const FalhaNaLeitura(),
    };

    semPosicao.forEach((nome, leitura) {
      test(nome, () async {
        localizacao.resposta = leitura;

        await viewModel.buscarCentro();

        expect(viewModel.centro, centroItajai);
      });
    });

    // Um pouco ao norte da latitude máxima: fora da área (morador em outra
    // cidade). O mapa só tem pontos dentro de Itajaí.
    test('posição lida fora da área → centraliza em Itajaí', () async {
      localizacao.resposta = LocalizacaoObtida(
        latitude: areaItajai.latitudeMaxima + 0.01,
        longitude: _longitude,
        precisaoMetros: 12,
      );

      await viewModel.buscarCentro();

      expect(viewModel.centro, centroItajai);
    });
  });

  // RF04 (ciclo 6d): o morador pode sair da aba antes de o GPS responder
  // (até 30 s) ou antes de o servidor recusar o "Já baixou". A resposta que
  // chega depois do dispose não pode quebrar o app.
  group('resposta depois de sair da aba', () {
    test('descartado antes de o GPS responder → não quebra', () async {
      // Arrange: a busca começa e a aba fecha antes da resposta.
      final busca = viewModel.buscarCentro();

      // Act
      viewModel.dispose();

      // Assert: a busca termina sem erro.
      await expectLater(busca, completes);
    });

    test('descartado antes da recusa do "Já baixou" → não quebra', () async {
      // Arrange: o servidor vai recusar o +1.
      pontos.deveFalhar = true;
      final envio = viewModel.confirmarJaBaixou('abc123');

      // Act: a aba fecha antes da recusa chegar.
      viewModel.dispose();

      // Assert
      await expectLater(envio, completes);
    });
  });
}
