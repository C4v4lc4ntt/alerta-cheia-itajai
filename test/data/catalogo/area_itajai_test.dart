// =============================================================================
// area_itajai_test.dart — RF03 (D17): retângulo do município de Itajaí.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// Fonte: OpenStreetMap, relation 296666, consulta de 09/11/2026.
// Valor-limite em graus: 0,0000001° (cerca de 1 cm no chão).
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/area_itajai.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('areaItajai', () {
    test('limites do OpenStreetMap (relation 296666, 09/11/2026)', () {
      expect(areaItajai.latitudeMinima, -27.0960000);
      expect(areaItajai.latitudeMaxima, -26.8378087);
      expect(areaItajai.longitudeMinima, -48.8690000);
      expect(areaItajai.longitudeMaxima, -48.6213454);
    });

    // Ao testar um lado, a outra coordenada fica no meio do retângulo.
    const latitudeMeio = -26.97;
    const longitudeMeio = -48.75;

    // Os valores são escritos por extenso, sem soma, para evitar o erro de
    // ponto flutuante (ex.: 1,2 + 0,41).
    final casos = <String, (double, double, bool)>{
      'sul, 0,0000001° para dentro → dentro': (
        -27.0959999,
        longitudeMeio,
        true,
      ),
      'sul, na borda → dentro': (-27.0960000, longitudeMeio, true),
      'sul, 0,0000001° para fora → fora': (-27.0960001, longitudeMeio, false),
      'norte, 0,0000001° para dentro → dentro': (
        -26.8378088,
        longitudeMeio,
        true,
      ),
      'norte, na borda → dentro': (-26.8378087, longitudeMeio, true),
      'norte, 0,0000001° para fora → fora': (-26.8378086, longitudeMeio, false),
      'oeste, 0,0000001° para dentro → dentro': (
        latitudeMeio,
        -48.8689999,
        true,
      ),
      'oeste, na borda → dentro': (latitudeMeio, -48.8690000, true),
      'oeste, 0,0000001° para fora → fora': (latitudeMeio, -48.8690001, false),
      'leste, 0,0000001° para dentro → dentro': (
        latitudeMeio,
        -48.6213455,
        true,
      ),
      'leste, na borda → dentro': (latitudeMeio, -48.6213454, true),
      'leste, 0,0000001° para fora → fora': (latitudeMeio, -48.6213453, false),
    };

    casos.forEach((nome, caso) {
      final (latitude, longitude, esperado) = caso;
      test(nome, () {
        expect(areaItajai.contem(latitude, longitude), esperado);
      });
    });
  });
}
