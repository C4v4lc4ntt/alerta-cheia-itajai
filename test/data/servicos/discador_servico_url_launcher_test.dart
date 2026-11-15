// =============================================================================
// discador_servico_url_launcher_test.dart — RF05 (D20): abrir o discador do
// celular com o número já digitado, sem quebrar o app.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// A função que abre o endereço é injetada: os testes passam uma versão falsa
// e nunca abrem o discador de verdade.
// =============================================================================
import 'package:alerta_cheia_itajai/data/servicos/discador_servico.dart';
import 'package:alerta_cheia_itajai/data/servicos/discador_servico_url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiscadorServicoUrlLauncher', () {
    test('ligar("199") abre tel:199 e devolve true', () async {
      // Arrange: a função falsa anota o endereço e diz que abriu.
      final abertos = <Uri>[];
      final DiscadorServico discador = DiscadorServicoUrlLauncher(
        abrir: (uri) async {
          abertos.add(uri);
          return true;
        },
      );

      // Act
      final abriu = await discador.ligar('199');

      // Assert
      expect(abriu, isTrue);
      expect(abertos, [Uri(scheme: 'tel', path: '199')]);
    });

    // Ex.: tablet sem telefone; a tela mostra o número para discar à mão.
    test('celular não consegue abrir → devolve false', () async {
      final discador = DiscadorServicoUrlLauncher(abrir: (uri) async => false);

      expect(await discador.ligar('193'), isFalse);
    });

    // O plugin pode lançar PlatformException; a tela não deve quebrar.
    test('plugin lança exceção → devolve false', () async {
      final discador = DiscadorServicoUrlLauncher(
        abrir: (uri) async =>
            throw PlatformException(code: 'ACTIVITY_NOT_FOUND'),
      );

      expect(await discador.ligar('192'), isFalse);
    });
  });
}
