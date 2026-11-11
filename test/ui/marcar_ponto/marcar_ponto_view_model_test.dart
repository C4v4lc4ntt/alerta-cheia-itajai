// =============================================================================
// marcar_ponto_view_model_test.dart — RF03 (D17): o estado da tela
// "Marcar rua alagada".
//
// Escrito ANTES do código (etapa vermelha do TDD). Usa os serviços falsos de
// localização e de envio, e um relógio fixo, para não depender do GPS, da
// internet nem da hora real. As posições saem do próprio catálogo areaItajai,
// sem coordenadas inventadas.
// =============================================================================
import 'dart:async';

import 'package:alerta_cheia_itajai/data/catalogo/area_itajai.dart';
import 'package:alerta_cheia_itajai/domain/models/altura_agua.dart';
import 'package:alerta_cheia_itajai/domain/models/leitura_localizacao.dart';
import 'package:alerta_cheia_itajai/ui/marcar_ponto/estado_envio.dart';
import 'package:alerta_cheia_itajai/ui/marcar_ponto/marcar_ponto_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/localizacao_servico_falso.dart';
import '../../apoio/pontos_servico_falso.dart';

// Centro do retângulo de Itajaí: com certeza dentro da área.
final _latitudeDentro =
    (areaItajai.latitudeMinima + areaItajai.latitudeMaxima) / 2;
final _longitudeDentro =
    (areaItajai.longitudeMinima + areaItajai.longitudeMaxima) / 2;

final _dentroDeItajai = LocalizacaoObtida(
  latitude: _latitudeDentro,
  longitude: _longitudeDentro,
  precisaoMetros: 12,
);

// Um pouco ao norte da latitude máxima: fora da área.
final _foraDeItajai = LocalizacaoObtida(
  latitude: areaItajai.latitudeMaxima + 0.01,
  longitude: _longitudeDentro,
  precisaoMetros: 12,
);

// Relógio fixo, em UTC, para conferir a data e a hora do ponto.
final _agora = DateTime.utc(2026, 11, 10, 22);

void main() {
  late LocalizacaoServicoFalso localizacao;
  late PontosServicoFalso pontos;
  late MarcarPontoViewModel viewModel;

  setUp(() {
    localizacao = LocalizacaoServicoFalso(resposta: _dentroDeItajai);
    pontos = PontosServicoFalso();
    viewModel = MarcarPontoViewModel(
      localizacao: localizacao,
      pontos: pontos,
      agora: () => _agora,
    );
  });

  group('localização', () {
    test('começa buscando, sem leitura e sem poder enviar', () {
      expect(viewModel.leitura, isNull);
      expect(viewModel.podeEnviar, isFalse);
    });

    // Os 4 casos sem localização: a tela mostra a mensagem do caso e o
    // botão "Enviar para o mapa" fica desativado, mesmo com a altura (D17).
    final semLocalizacao = <String, LeituraLocalizacao>{
      'GPS desligado': const GpsDesligado(),
      'permissão negada': const PermissaoNegada(),
      'permissão bloqueada': const PermissaoBloqueada(),
      'falha na leitura': const FalhaNaLeitura(),
    };
    semLocalizacao.forEach((caso, resposta) {
      test('$caso → mostra o caso e não deixa enviar', () async {
        // Arrange
        localizacao.resposta = resposta;

        // Act
        await viewModel.buscarLocalizacao();
        viewModel.escolherAltura(AlturaAgua.joelho);

        // Assert
        expect(viewModel.leitura, same(resposta));
        expect(viewModel.podeEnviar, isFalse);
      });
    });

    test(
      'localização obtida dentro de Itajaí → não está fora da área',
      () async {
        await viewModel.buscarLocalizacao();

        expect(viewModel.leitura, same(_dentroDeItajai));
        expect(viewModel.foraDaArea, isFalse);
      },
    );

    test('localização obtida fora de Itajaí → fora da área e não deixa '
        'enviar', () async {
      localizacao.resposta = _foraDeItajai;

      await viewModel.buscarLocalizacao();
      viewModel.escolherAltura(AlturaAgua.joelho);

      expect(viewModel.foraDaArea, isTrue);
      expect(viewModel.podeEnviar, isFalse);
    });

    test('avisa a tela quando a localização chega', () async {
      var avisos = 0;
      viewModel.addListener(() => avisos++);

      await viewModel.buscarLocalizacao();

      expect(avisos, isPositive);
    });

    // "Permitir localização" e "Tentar de novo" chamam buscarLocalizacao.
    test(
      'buscar de novo volta para buscando e lê a posição outra vez',
      () async {
        // Arrange: a primeira leitura falhou.
        localizacao.resposta = const FalhaNaLeitura();
        await viewModel.buscarLocalizacao();
        localizacao.resposta = _dentroDeItajai;

        // Act: sem await, para ver o estado enquanto lê.
        final buscando = viewModel.buscarLocalizacao();

        // Assert
        expect(viewModel.leitura, isNull);
        await buscando;
        expect(viewModel.leitura, same(_dentroDeItajai));
        expect(localizacao.leituras, 2);
      },
    );
  });

  group('altura da água', () {
    test('guarda a altura escolhida e avisa a tela', () {
      var avisos = 0;
      viewModel.addListener(() => avisos++);

      viewModel.escolherAltura(AlturaAgua.cintura);

      expect(viewModel.altura, AlturaAgua.cintura);
      expect(avisos, 1);
    });

    test('com localização e sem altura → não deixa enviar', () async {
      await viewModel.buscarLocalizacao();

      expect(viewModel.podeEnviar, isFalse);
    });

    test('com localização e altura → deixa enviar', () async {
      await viewModel.buscarLocalizacao();
      viewModel.escolherAltura(AlturaAgua.canela);

      expect(viewModel.podeEnviar, isTrue);
    });
  });

  group('botões dos casos sem localização', () {
    test(
      '"Ligar a localização" abre a tela de localização do celular',
      () async {
        await viewModel.ligarLocalizacao();

        expect(localizacao.aberturasDaLocalizacao, 1);
        expect(localizacao.aberturasDoApp, 0);
      },
    );

    test('"Abrir configurações" abre as configurações do app', () async {
      await viewModel.abrirConfiguracoes();

      expect(localizacao.aberturasDoApp, 1);
      expect(localizacao.aberturasDaLocalizacao, 0);
    });
  });

  group('envio', () {
    // Prepara a tela pronta para enviar: localização dentro e altura joelho.
    Future<void> prontoParaEnviar() async {
      await viewModel.buscarLocalizacao();
      viewModel.escolherAltura(AlturaAgua.joelho);
    }

    test('antes de enviar → nenhum envio', () {
      expect(viewModel.envio, EstadoEnvio.nenhum);
    });

    test('envia o ponto com a posição, a altura e a hora do relógio', () async {
      await prontoParaEnviar();

      await viewModel.enviar();

      final ponto = pontos.enviados.single;
      expect(ponto.latitude, _latitudeDentro);
      expect(ponto.longitude, _longitudeDentro);
      expect(ponto.altura, AlturaAgua.joelho);
      expect(ponto.criadoEm, _agora);
    });

    test('enquanto envia → enviando e não deixa enviar de novo', () async {
      await prontoParaEnviar();

      final envio = viewModel.enviar();

      expect(viewModel.envio, EstadoEnvio.enviando);
      expect(viewModel.podeEnviar, isFalse);
      await envio;
    });

    // Evita marcação duplicada por um segundo toque.
    test('depois de enviado → enviado e não deixa enviar de novo', () async {
      await prontoParaEnviar();

      await viewModel.enviar();

      expect(viewModel.envio, EstadoEnvio.enviado);
      expect(viewModel.podeEnviar, isFalse);
    });

    test('falha do serviço → erro e deixa tentar de novo', () async {
      await prontoParaEnviar();
      pontos.deveFalhar = true;

      await viewModel.enviar();

      expect(viewModel.envio, EstadoEnvio.erro);
      expect(viewModel.podeEnviar, isTrue);
    });

    test('sem poder enviar → não manda nada ao serviço', () async {
      // Só a localização, sem a altura.
      await viewModel.buscarLocalizacao();

      await viewModel.enviar();

      expect(pontos.enviados, isEmpty);
      expect(viewModel.envio, EstadoEnvio.nenhum);
    });

    // Tempo limite do envio (decisão de 10/11): sem resposta em 15 s, a
    // tela mostra o erro. O testWidgets controla o relógio do teste, então
    // tester.pump avança o tempo sem esperar de verdade.
    testWidgets('sem resposta até 14 s → continua enviando', (tester) async {
      await prontoParaEnviar();
      pontos.nuncaTermina = true;

      unawaited(viewModel.enviar());
      await tester.pump(const Duration(seconds: 14));

      expect(viewModel.envio, EstadoEnvio.enviando);
      // Deixa o tempo limite vencer, para não sobrar relógio pendente.
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('sem resposta em 15 s → erro e deixa tentar de novo', (
      tester,
    ) async {
      await prontoParaEnviar();
      pontos.nuncaTermina = true;

      unawaited(viewModel.enviar());
      await tester.pump(const Duration(seconds: 15));

      expect(viewModel.envio, EstadoEnvio.erro);
      expect(viewModel.podeEnviar, isTrue);
    });
  });
}
