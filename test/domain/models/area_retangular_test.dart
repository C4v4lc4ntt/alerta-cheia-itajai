// =============================================================================
// area_retangular_test.dart — RF03 (D17): retângulo usado para barrar pontos
// de alagamento fora do município.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// =============================================================================
import 'package:alerta_cheia_itajai/domain/models/area_retangular.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AreaRetangular', () {
    // Limites trocados deixariam a área vazia, e todo ponto seria recusado.
    test('latitude mínima maior que a máxima → ArgumentError', () {
      expect(
        () => AreaRetangular(
          latitudeMinima: -26.8,
          latitudeMaxima: -27.0,
          longitudeMinima: -48.8,
          longitudeMaxima: -48.6,
        ),
        throwsArgumentError,
      );
    });

    test('longitude mínima maior que a máxima → ArgumentError', () {
      expect(
        () => AreaRetangular(
          latitudeMinima: -27.0,
          latitudeMaxima: -26.8,
          longitudeMinima: -48.6,
          longitudeMaxima: -48.8,
        ),
        throwsArgumentError,
      );
    });
  });
}
