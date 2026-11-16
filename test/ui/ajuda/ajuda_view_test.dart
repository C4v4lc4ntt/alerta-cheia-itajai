// =============================================================================
// ajuda_view_test.dart — RF05 (D20): a aba Ajuda lista os contatos de
// emergência e os abrigos, e liga com um toque.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// Usa o catálogo real (página "Telefones de emergência" da Defesa Civil,
// 15/11/2026) e o discador falso de test/apoio: nada abre de verdade.
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/catalogo_contatos.dart';
import 'package:alerta_cheia_itajai/domain/models/abrigo.dart';
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

  group('abrigos (ciclo 6c2)', () {
    // Amostra real da camada abrigos_itajai_final_2026 (lida em 15/11/2026):
    // um abrigo com telefone, um sem e um de animais.
    final abrigos = {
      'CRAS Imaruí': [
        Abrigo(
          nome: 'Paróquia São Cristóvão',
          endereco: 'R. Odílio Garcia, 445, Cordeiros',
          telefone: '4733411408',
        ),
      ],
      'CRAS Espinheiros': [
        Abrigo(
          nome: 'Capela Santo Antônio',
          endereco: 'R. Fermino Vieira Cordeiro, 915, Espinheiros',
        ),
      ],
    };
    final animais = [
      Abrigo(
        nome: 'Abrigo para animais',
        endereco: 'Rua Jorge Tzachel, 344 - Fazenda',
      ),
    ];

    Future<void> abrirComAbrigos(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AjudaView(
            viewModel: AjudaViewModel(discador: discador),
            contatos: catalogoContatos,
            abrigos: abrigos,
            abrigosAnimais: animais,
          ),
        ),
      );
    }

    // O ListView só monta o que está visível: rola até o item antes de
    // procurar, senão um "findsNothing" passaria sem provar nada.
    Future<void> rolarAte(WidgetTester tester, Finder alvo) async {
      await tester.scrollUntilVisible(
        alvo,
        200,
        scrollable: find.byType(Scrollable),
      );
    }

    testWidgets('avisa que os abrigos abrem conforme a necessidade', (
      tester,
    ) async {
      await abrirComAbrigos(tester);
      const aviso =
          'Os abrigos abrem conforme a necessidade. '
          'Confirme pelo 199 antes de ir.';

      await rolarAte(tester, find.text(aviso));

      expect(find.text(aviso), findsOneWidget);
    });

    testWidgets('mostra cada região com nome e endereço dos abrigos', (
      tester,
    ) async {
      await abrirComAbrigos(tester);

      for (final regiao in abrigos.keys) {
        for (final abrigo in abrigos[regiao]!) {
          await rolarAte(tester, find.text(abrigo.endereco));

          expect(find.text(regiao), findsOneWidget);
          expect(find.text(abrigo.nome), findsOneWidget);
          expect(find.text(abrigo.endereco), findsOneWidget);
        }
      }
    });

    testWidgets('abrigo com telefone mostra (47) 3341-1408 e liga', (
      tester,
    ) async {
      await abrirComAbrigos(tester);
      final botao = find.bySemanticsLabel(
        'Ligar para Paróquia São Cristóvão, (47) 3341-1408',
      );

      await rolarAte(tester, botao);
      await tester.tap(botao);
      await tester.pump();

      expect(find.text('(47) 3341-1408'), findsOneWidget);
      expect(discador.numeros, ['4733411408']);
    });

    testWidgets('abrigo sem telefone não tem botão de ligar', (tester) async {
      await abrirComAbrigos(tester);

      await rolarAte(tester, find.text('Capela Santo Antônio'));

      expect(
        find.bySemanticsLabel(RegExp('Ligar para Capela Santo Antônio')),
        findsNothing,
      );
    });

    testWidgets('mostra a seção "Abrigos para animais" com o endereço', (
      tester,
    ) async {
      await abrirComAbrigos(tester);

      await rolarAte(tester, find.text('Rua Jorge Tzachel, 344 - Fazenda'));

      expect(find.text('Abrigos para animais'), findsOneWidget);
      expect(find.text('Rua Jorge Tzachel, 344 - Fazenda'), findsOneWidget);
    });
  });
}
