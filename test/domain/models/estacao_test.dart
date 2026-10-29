// =============================================================================
// estacao_test.dart — RF01, ciclo 2: o modelo Estacao.
//
// ETAPA VERMELHA: Estacao ainda não existe, então este teste nem compila.
// Código da estação no formato do portal, sem hífen (D07).
// =============================================================================
import 'package:alerta_cheia_itajai/domain/models/cotas_estacao.dart';
import 'package:alerta_cheia_itajai/domain/models/estacao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cotasDc01 = CotasEstacao(atencao: 1.21, alerta: 1.61, emergencia: 1.75);

  group('Estacao', () {
    test('guarda código, nome, rio e cotas', () {
      final estacao = Estacao(
        codigo: 'DC01',
        nome: 'ICMBio/CEPSUL',
        rio: 'Rio Itajaí-Açu',
        cotas: cotasDc01,
      );

      expect(estacao.codigo, 'DC01');
      expect(estacao.nome, 'ICMBio/CEPSUL');
      expect(estacao.rio, 'Rio Itajaí-Açu');
      expect(estacao.cotas, same(cotasDc01));
    });

    // Código vazio ou só com espaços não identifica estação nenhuma.
    for (final codigo in ['', '   ']) {
      test('rejeita código "$codigo"', () {
        expect(
          () => Estacao(
            codigo: codigo,
            nome: 'ICMBio/CEPSUL',
            rio: 'Rio Itajaí-Açu',
            cotas: cotasDc01,
          ),
          throwsArgumentError,
        );
      });
    }
  });
}
