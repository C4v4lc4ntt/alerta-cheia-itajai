// =============================================================================
// ajuda_view_test.dart — RF05 (D20): a aba Ajuda lista os contatos de
// emergência e liga com um toque.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// Usa o catálogo real (página "Telefones de emergência" da Defesa Civil,
// 15/11/2026) e o discador falso de test/apoio: nada abre de verdade.
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/catalogo_contatos.dart';
import 'package:alerta_cheia_itajai/ui/ajuda/ajuda_view.dart';
import 'package:alerta_cheia_itajai/ui/ajuda/ajuda_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/discador_falso.dart';

void main() {
  late DiscadorFalso discador;

  setUp(() => discador = DiscadorFalso());

  // Monta a aba Ajuda sozinha, com o ViewModel de verdade.
  Future<void> abrirTela(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AjudaView(
          viewModel: AjudaViewModel(discador: discador),
          contatos: catalogoContatos,
        ),
      ),
    );
  }

  testWidgets('mostra os 3 contatos com nome, número e descrição', (
    tester,
  ) async {
    await abrirTela(tester);

    for (final contato in catalogoContatos) {
      expect(find.text(contato.nome), findsOneWidget);
      expect(find.text(contato.numero), findsOneWidget);
      expect(find.text(contato.descricao), findsOneWidget);
    }
  });

  testWidgets('tocar em "Ligar para Defesa Civil, 199" pede o 199', (
    tester,
  ) async {
    await abrirTela(tester);

    await tester.tap(find.bySemanticsLabel('Ligar para Defesa Civil, 199'));
    await tester.pump();

    expect(discador.numeros, ['199']);
  });

  testWidgets('discador não abriu → mostra o número para discar à mão', (
    tester,
  ) async {
    discador.abre = false;
    await abrirTela(tester);

    await tester.tap(find.bySemanticsLabel('Ligar para Defesa Civil, 199'));
    await tester.pump();

    expect(
      find.text('Não foi possível abrir o discador. Disque 199.'),
      findsOneWidget,
    );
  });

  // Acessibilidade (CLAUDE.md, seção 7): alvos de 48 px e rótulos.
  testWidgets('alvos de toque e rótulos seguem as regras', (tester) async {
    final semantica = tester.ensureSemantics();

    await abrirTela(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    semantica.dispose();
  });
}
