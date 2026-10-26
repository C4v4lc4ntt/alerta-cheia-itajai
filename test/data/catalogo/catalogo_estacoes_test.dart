// =============================================================================
// catalogo_estacoes_test.dart — RF01, ciclo 3: catálogo das 11 estações.
//
// ETAPA VERMELHA: o catálogo ainda não existe, então este teste nem compila.
// Fonte dos valores: portal de monitoramento da Defesa Civil de Itajaí,
// consultado em 19/10/2026 (docs/catalogo-estacoes.md, D07).
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/catalogo_estacoes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('catalogoEstacoes', () {
    test('tem as 11 estações de nível de Itajaí', () {
      expect(catalogoEstacoes, hasLength(11));
    });

    test('os códigos não se repetem', () {
      final codigos = catalogoEstacoes.map((e) => e.codigo).toSet();

      expect(codigos, hasLength(catalogoEstacoes.length));
    });

    // Mesmo formato do portal, sem hífen (D07).
    test('todos os códigos seguem o formato do portal (ex.: DC01)', () {
      for (final estacao in catalogoEstacoes) {
        expect(estacao.codigo, matches(RegExp(r'^DC\d{2}$')));
      }
    });

    test('DC01 tem as cotas do portal: 1,21 / 1,61 / 1,75 m', () {
      final dc01 = catalogoEstacoes.firstWhere((e) => e.codigo == 'DC01');

      expect(dc01.rio, 'Rio Itajaí-Açu');
      expect(dc01.cotas.atencao, 1.21);
      expect(dc01.cotas.alerta, 1.61);
      expect(dc01.cotas.emergencia, 1.75);
    });

    test('DC07 tem as cotas do portal: 1,00 / 1,40 / 1,50 m', () {
      final dc07 = catalogoEstacoes.firstWhere((e) => e.codigo == 'DC07');

      expect(dc07.rio, 'Ribeirão da Murta');
      expect(dc07.cotas.atencao, 1.00);
      expect(dc07.cotas.alerta, 1.40);
      expect(dc07.cotas.emergencia, 1.50);
    });
  });
}
