// =============================================================================
// bairro_test.dart — RF02 (D08): bairro ou localidade com as estações mais
// próximas, estimadas.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// =============================================================================
import 'package:alerta_cheia_itajai/domain/models/bairro.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bairro', () {
    // Um nome em branco apareceria como uma linha vazia na lista do app.
    test('nome só com espaços → ArgumentError', () {
      expect(
        () => Bairro(nome: '   ', estacoesProximas: const ['DC01']),
        throwsArgumentError,
      );
    });

    // Sem estação não há o que mostrar como complemento (D08).
    test('sem estações próximas → ArgumentError', () {
      expect(
        () => Bairro(nome: 'Centro', estacoesProximas: const []),
        throwsArgumentError,
      );
    });
  });
}
