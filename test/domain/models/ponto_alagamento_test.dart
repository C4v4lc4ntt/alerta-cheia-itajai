// =============================================================================
// ponto_alagamento_test.dart — RF03 (D17): registro de um ponto de alagamento.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// Teste planejado na Etapa 1 (Tabela 5): registro sem localização ou sem
// altura da água é rejeitado; registro válido é salvo com data e hora.
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/area_itajai.dart';
import 'package:alerta_cheia_itajai/domain/models/altura_agua.dart';
import 'package:alerta_cheia_itajai/domain/models/ponto_alagamento.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Relógio fixo: o teste não depende da hora real.
  final momento = DateTime.utc(2026, 11, 9, 22, 50);
  DateTime relogio() => momento;

  // Ponto qualquer dentro do retângulo, perto do Centro.
  const latitudeValida = -26.9078;
  const longitudeValida = -48.6616;

  group('PontoAlagamento.registrar', () {
    test('sem latitude → ArgumentError', () {
      expect(
        () => PontoAlagamento.registrar(
          latitude: null,
          longitude: longitudeValida,
          altura: AlturaAgua.joelho,
          area: areaItajai,
          agora: relogio,
        ),
        throwsArgumentError,
      );
    });

    test('sem longitude → ArgumentError', () {
      expect(
        () => PontoAlagamento.registrar(
          latitude: latitudeValida,
          longitude: null,
          altura: AlturaAgua.joelho,
          area: areaItajai,
          agora: relogio,
        ),
        throwsArgumentError,
      );
    });

    test('sem altura da água → ArgumentError', () {
      expect(
        () => PontoAlagamento.registrar(
          latitude: latitudeValida,
          longitude: longitudeValida,
          altura: null,
          area: areaItajai,
          agora: relogio,
        ),
        throwsArgumentError,
      );
    });

    test('fora da área de Itajaí → ArgumentError', () {
      // A oeste do retângulo.
      expect(
        () => PontoAlagamento.registrar(
          latitude: latitudeValida,
          longitude: -49.0,
          altura: AlturaAgua.canela,
          area: areaItajai,
          agora: relogio,
        ),
        throwsArgumentError,
      );
    });

    test('registro válido → guarda posição, altura e data e hora', () {
      // Act
      final ponto = PontoAlagamento.registrar(
        latitude: latitudeValida,
        longitude: longitudeValida,
        altura: AlturaAgua.cintura,
        area: areaItajai,
        agora: relogio,
      );

      // Assert
      expect(ponto.latitude, latitudeValida);
      expect(ponto.longitude, longitudeValida);
      expect(ponto.altura, AlturaAgua.cintura);
      expect(ponto.criadoEm, momento);
    });
  });
}
