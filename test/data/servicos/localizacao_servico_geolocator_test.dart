// =============================================================================
// localizacao_servico_geolocator_test.dart — RF03: leitura da posição atual
// do celular, uma vez, com a precisão.
//
// Escrito ANTES do código (etapa vermelha do TDD, ciclo 18).
// Sem GPS de verdade: o GeolocatorPlatform (a borda com o celular) é trocado
// por um mock do mocktail, como um @Mock do Mockito sobre um client externo.
// Cada situação de "sem localização" tem um resultado próprio, para a tela
// explicar ao morador o que fazer (ligar o GPS, permitir, abrir as
// configurações do app ou tentar de novo).
// =============================================================================
import 'package:alerta_cheia_itajai/data/servicos/localizacao_servico_geolocator.dart';
import 'package:alerta_cheia_itajai/domain/models/leitura_localizacao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

class GeolocatorPlatformMock extends Mock implements GeolocatorPlatform {}

void main() {
  // Posição qualquer perto do Centro, com 12 m de precisão.
  const latitude = -26.9078;
  const longitude = -48.6616;
  const precisao = 12.0;

  late GeolocatorPlatformMock gps;
  late LocalizacaoServicoGeolocator servico;

  // O mocktail precisa de um valor "qualquer" para o parâmetro nomeado
  // locationSettings, usado no any(named: ...) abaixo.
  setUpAll(() => registerFallbackValue(const LocationSettings()));

  setUp(() {
    gps = GeolocatorPlatformMock();
    servico = LocalizacaoServicoGeolocator(gps);
  });

  // ---------------------------------------------------------------------------
  // Atalhos para montar o cenário (Arrange).
  // ---------------------------------------------------------------------------
  void gpsLigado(bool ligado) =>
      when(() => gps.isLocationServiceEnabled())
          .thenAnswer((_) async => ligado);

  void permissaoAtual(LocationPermission permissao) =>
      when(() => gps.checkPermission()).thenAnswer((_) async => permissao);

  void respostaAoPedido(LocationPermission permissao) =>
      when(() => gps.requestPermission()).thenAnswer((_) async => permissao);

  void posicaoLida() =>
      when(
        () => gps.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer(
        (_) async => Position(
          latitude: latitude,
          longitude: longitude,
          accuracy: precisao,
          timestamp: DateTime.utc(2026, 11, 10, 18, 30),
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        ),
      );

  // Confere se o resultado é a posição esperada, com a precisão.
  final ehAPosicaoLida = isA<LocalizacaoObtida>()
      .having((l) => l.latitude, 'latitude', latitude)
      .having((l) => l.longitude, 'longitude', longitude)
      .having((l) => l.precisaoMetros, 'precisaoMetros', precisao);

  // ---------------------------------------------------------------------------
  // Caminho feliz.
  // ---------------------------------------------------------------------------
  test(
    'GPS ligado e permissão já concedida → devolve a posição e a precisão',
    () async {
      gpsLigado(true);
      permissaoAtual(LocationPermission.whileInUse);
      posicaoLida();

      final leitura = await servico.obterAtual();

      expect(leitura, ehAPosicaoLida);
      verifyNever(() => gps.requestPermission());
    },
  );

  test(
    'permissão negada, morador permite no pedido → devolve a posição',
    () async {
      gpsLigado(true);
      permissaoAtual(LocationPermission.denied);
      respostaAoPedido(LocationPermission.whileInUse);
      posicaoLida();

      final leitura = await servico.obterAtual();

      expect(leitura, ehAPosicaoLida);
    },
  );

  // ---------------------------------------------------------------------------
  // As 4 situações de "sem localização" (decisão de 10/11).
  // ---------------------------------------------------------------------------
  test('GPS desligado → GpsDesligado, sem pedir permissão', () async {
    gpsLigado(false);

    final leitura = await servico.obterAtual();

    expect(leitura, isA<GpsDesligado>());
    verifyNever(() => gps.requestPermission());
  });

  test(
    'permissão negada e morador nega de novo no pedido → PermissaoNegada',
    () async {
      gpsLigado(true);
      permissaoAtual(LocationPermission.denied);
      respostaAoPedido(LocationPermission.denied);

      final leitura = await servico.obterAtual();

      expect(leitura, isA<PermissaoNegada>());
    },
  );

  test(
    'permissão já bloqueada → PermissaoBloqueada, sem pedir de novo',
    () async {
      gpsLigado(true);
      permissaoAtual(LocationPermission.deniedForever);

      final leitura = await servico.obterAtual();

      expect(leitura, isA<PermissaoBloqueada>());
      verifyNever(() => gps.requestPermission());
    },
  );

  test(
    'morador marca "não perguntar novamente" no pedido → PermissaoBloqueada',
    () async {
      gpsLigado(true);
      permissaoAtual(LocationPermission.denied);
      respostaAoPedido(LocationPermission.deniedForever);

      final leitura = await servico.obterAtual();

      expect(leitura, isA<PermissaoBloqueada>());
    },
  );

  test('erro ao ler o GPS → FalhaNaLeitura', () async {
    gpsLigado(true);
    permissaoAtual(LocationPermission.whileInUse);
    when(
      () => gps.getCurrentPosition(
        locationSettings: any(named: 'locationSettings'),
      ),
    ).thenThrow(const PositionUpdateException('GPS sem sinal'));

    final leitura = await servico.obterAtual();

    expect(leitura, isA<FalhaNaLeitura>());
  });
}
