// =============================================================================
// leitura_nivel_test.dart — RF01, ciclo 2: o modelo LeituraNivel.
//
// ETAPA VERMELHA: LeituraNivel ainda não existe, então este teste nem compila.
// =============================================================================
import 'package:alerta_cheia_itajai/domain/models/cotas_estacao.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:alerta_cheia_itajai/domain/models/leitura_nivel.dart';
import 'package:alerta_cheia_itajai/domain/regras/classificador_estagio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cotasDc01 = CotasEstacao(atencao: 1.21, alerta: 1.61, emergencia: 1.75);
  final medidoEm = DateTime(2026, 10, 20, 14, 30);

  group('LeituraNivel', () {
    test('guarda código da estação, nível e horário da medição', () {
      final leitura =
          LeituraNivel(codigoEstacao: 'DC01', nivel: 1.45, medidoEm: medidoEm);

      expect(leitura.codigoEstacao, 'DC01');
      expect(leitura.nivel, 1.45);
      expect(leitura.medidoEm, medidoEm);
    });

    // Em double, 1.2 + 0.41 = 1.6099999999999999 (fica abaixo de 1.61).
    test('arredonda o nível para centímetros', () {
      final leitura = LeituraNivel(
          codigoEstacao: 'DC01', nivel: 1.2 + 0.41, medidoEm: medidoEm);

      expect(leitura.nivel, 1.61);
    });

    test('com o arredondamento, 1.2 + 0.41 dá Alerta na DC01, e não Atenção',
        () {
      final leitura = LeituraNivel(
          codigoEstacao: 'DC01', nivel: 1.2 + 0.41, medidoEm: medidoEm);

      expect(classificarEstagio(leitura.nivel, cotasDc01), EstagioAlerta.alerta);
    });

    for (final codigo in ['', '   ']) {
      test('rejeita código da estação "$codigo"', () {
        expect(
          () => LeituraNivel(
              codigoEstacao: codigo, nivel: 1.45, medidoEm: medidoEm),
          throwsArgumentError,
        );
      });
    }
  });
}
