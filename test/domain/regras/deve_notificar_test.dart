// =============================================================================
// deve_notificar_test.dart — RF02 (D06 e D12): decide se a leitura nova gera
// uma notificação local, comparando o estágio atual com o anterior.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// =============================================================================
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:alerta_cheia_itajai/domain/regras/deve_notificar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('deveNotificar', () {
    // D12: sem estágio anterior não há mudança, qualquer que seja o atual.
    for (final atual in EstagioAlerta.values) {
      test('sem estágio anterior → ${atual.name} não notifica', () {
        expect(deveNotificar(anterior: null, atual: atual), isFalse);
      });
    }

    // D06: repetir o mesmo estágio não gera aviso.
    for (final estagio in EstagioAlerta.values) {
      test('${estagio.name} → ${estagio.name} não notifica', () {
        expect(deveNotificar(anterior: estagio, atual: estagio), isFalse);
      });
    }

    // Qualquer mudança notifica, ao subir ou ao descer de estágio.
    for (final anterior in EstagioAlerta.values) {
      for (final atual in EstagioAlerta.values) {
        if (anterior == atual) continue;

        test('${anterior.name} → ${atual.name} notifica', () {
          expect(deveNotificar(anterior: anterior, atual: atual), isTrue);
        });
      }
    }
  });
}
