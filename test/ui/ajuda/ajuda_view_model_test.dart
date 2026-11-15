// =============================================================================
// ajuda_view_model_test.dart — RF05 (D20): tocar num número da aba Ajuda abre
// o discador; se não abrir, a tela recebe o número para discar à mão.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// O discador é a versão falsa de test/apoio: nada abre de verdade.
// =============================================================================
import 'package:alerta_cheia_itajai/ui/ajuda/ajuda_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/discador_falso.dart';

void main() {
  group('AjudaViewModel.ligar', () {
    late DiscadorFalso discador;
    late AjudaViewModel viewModel;

    setUp(() {
      discador = DiscadorFalso();
      viewModel = AjudaViewModel(discador: discador);
    });

    test('pede ao discador o número tocado', () async {
      await viewModel.ligar('199');

      expect(discador.numeros, ['199']);
    });

    test('discador abriu → nenhum número para discar à mão', () async {
      discador.abre = true;

      await viewModel.ligar('199');

      expect(viewModel.numeroParaDiscarAMao, isNull);
    });

    test('discador não abriu → mostra o número e avisa a tela', () async {
      // Arrange
      discador.abre = false;
      var avisos = 0;
      viewModel.addListener(() => avisos++);

      // Act
      await viewModel.ligar('199');

      // Assert
      expect(viewModel.numeroParaDiscarAMao, '199');
      expect(avisos, 1);
    });

    // Sem isso, o aviso de uma falha antiga ficaria na tela para sempre.
    test('nova tentativa que abre apaga o número da falha anterior', () async {
      discador.abre = false;
      await viewModel.ligar('199');

      discador.abre = true;
      await viewModel.ligar('193');

      expect(viewModel.numeroParaDiscarAMao, isNull);
    });
  });
}
