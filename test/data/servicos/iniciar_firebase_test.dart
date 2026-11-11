// =============================================================================
// iniciar_firebase_test.dart — RF03/D17: ligar o Firebase ao abrir o app sem
// derrubar o resto. O RF01 e o RF02 não dependem do Firebase, então uma falha
// na inicialização não pode impedir o app de abrir.
//
// Escrito ANTES do código (etapa vermelha do TDD). A inicialização é injetada:
// o teste nunca chama o Firebase de verdade.
// =============================================================================
import 'package:alerta_cheia_itajai/data/servicos/iniciar_firebase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('iniciarFirebase', () {
    test('inicialização que funciona → true', () async {
      // Arrange: uma inicialização falsa que termina sem erro.
      Future<void> inicializar() async {}

      // Act
      final ligado = await iniciarFirebase(inicializar);

      // Assert
      expect(ligado, isTrue);
    });

    test('inicialização que falha → false, sem derrubar o app', () async {
      // Arrange: simula, por exemplo, uma configuração corrompida.
      Future<void> inicializar() async {
        throw Exception('configuração inválida');
      }

      // Act + Assert: não lança a exceção para o main.dart, só devolve false.
      expect(await iniciarFirebase(inicializar), isFalse);
    });

    test('chama a inicialização uma única vez', () async {
      // Arrange: conta quantas vezes a inicialização foi pedida.
      var chamadas = 0;
      Future<void> inicializar() async {
        chamadas++;
      }

      // Act
      await iniciarFirebase(inicializar);

      // Assert: inicializar duas vezes faz o Firebase reclamar de app duplicado.
      expect(chamadas, 1);
    });
  });
}
