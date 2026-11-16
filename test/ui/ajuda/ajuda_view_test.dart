// =============================================================================
// ajuda_view_test.dart — RF05 e RF06 (D20): a aba Ajuda lista os contatos de
// emergência, os abrigos e as orientações, liga com um toque e mostra o aviso
// de "enchente sem chuva" (em destaque a partir de Atenção).
//
// Escrito ANTES do código (etapa vermelha do TDD). Passo 56 (s04b, adendo da
// D20): os abrigos ganham um filtro por região e as orientações ganham abas;
// os testes do filtro e das abas também vieram antes do código.
// Usa o catálogo real (página "Telefones de emergência" da Defesa Civil,
// 15/11/2026) e o discador falso de test/apoio: nada abre de verdade.
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/catalogo_contatos.dart';
import 'package:alerta_cheia_itajai/data/catalogo/catalogo_orientacoes.dart';
import 'package:alerta_cheia_itajai/domain/models/abrigo.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:alerta_cheia_itajai/ui/ajuda/ajuda_view.dart';
import 'package:alerta_cheia_itajai/ui/ajuda/ajuda_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/acessibilidade.dart';
import '../../apoio/discador_falso.dart';

void main() {
  late DiscadorFalso discador;

  setUp(() => discador = DiscadorFalso());

  // Tela bem alta: o ListView monta todos os itens de uma vez, então um
  // "findsNothing" prova que o item está escondido (e não só fora da tela).
  void usarTelaAlta(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 8000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  // Monta a aba Ajuda sozinha, com o ViewModel de verdade.
  Future<void> abrirTela(WidgetTester tester, {ThemeData? tema}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: tema,
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
    // procurar, senão um "findsNothing" passaria sem provar nada. O
    // ensureVisible termina de trazê-lo para a tela, para o toque acertar
    // (igual ao grupo das orientações).
    Future<void> rolarAte(WidgetTester tester, Finder alvo) async {
      await tester.scrollUntilVisible(
        alvo,
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.ensureVisible(alvo);
      await tester.pump();
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

    // Passo 56: o filtro começa na primeira região do mapa de abrigos.
    testWidgets('filtro começa na primeira região e esconde as outras', (
      tester,
    ) async {
      usarTelaAlta(tester);
      await abrirComAbrigos(tester);

      expect(find.text('Paróquia São Cristóvão'), findsOneWidget);
      expect(find.text('R. Odílio Garcia, 445, Cordeiros'), findsOneWidget);
      expect(find.text('Capela Santo Antônio'), findsNothing);
    });

    testWidgets('tocar em "CRAS Espinheiros" mostra só os abrigos dela', (
      tester,
    ) async {
      usarTelaAlta(tester);
      await abrirComAbrigos(tester);

      await tester.tap(find.text('CRAS Espinheiros'));
      await tester.pump();

      expect(find.text('Capela Santo Antônio'), findsOneWidget);
      expect(
        find.text('R. Fermino Vieira Cordeiro, 915, Espinheiros'),
        findsOneWidget,
      );
      expect(find.text('Paróquia São Cristóvão'), findsNothing);
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
      usarTelaAlta(tester);
      await abrirComAbrigos(tester);

      // A Capela fica na segunda região: escolhe o filtro dela primeiro.
      await tester.tap(find.text('CRAS Espinheiros'));
      await tester.pump();
      expect(find.text('Capela Santo Antônio'), findsOneWidget);

      expect(
        find.bySemanticsLabel(RegExp('Ligar para Capela Santo Antônio')),
        findsNothing,
      );
    });

    testWidgets('tocar em "Animais" mostra os abrigos para animais', (
      tester,
    ) async {
      usarTelaAlta(tester);
      await abrirComAbrigos(tester);

      await tester.tap(find.text('Animais'));
      await tester.pump();

      expect(find.text('Rua Jorge Tzachel, 344 - Fazenda'), findsOneWidget);
      expect(find.text('Paróquia São Cristóvão'), findsNothing);
    });

    // Acessibilidade dos botões novos do filtro (CLAUDE.md, seção 7).
    testWidgets('filtro de abrigos segue as regras de alvo e rótulo', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      await abrirComAbrigos(tester);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      semantica.dispose();
    });
  });

  group('orientações e aviso (ciclos 9 e 10, RF06)', () {
    const aviso =
        'Enchente sem chuva: em Itajaí, o rio pode continuar subindo mesmo '
        'depois que a chuva para. Acompanhe o estágio no app e siga as '
        'orientações da Defesa Civil.';
    const destaque = Key('aviso_em_destaque');

    Future<void> abrirComOrientacoes(
      WidgetTester tester, {
      EstagioAlerta? estagio,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AjudaView(
            viewModel: AjudaViewModel(discador: discador),
            contatos: catalogoContatos,
            orientacoes: catalogoOrientacoes,
            estagioCidade: estagio,
          ),
        ),
      );
    }

    // Mesmo motivo do grupo dos abrigos: o ListView só monta o que está
    // perto da tela, então rola até o item antes de procurar. O
    // scrollUntilVisible para quando o item aparece só em parte; o
    // ensureVisible termina de trazê-lo para a tela, para o toque acertar.
    Future<void> rolarAte(WidgetTester tester, Finder alvo) async {
      await tester.scrollUntilVisible(
        alvo,
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.ensureVisible(alvo);
      await tester.pump();
    }

    // Passo 56: as orientações ganham abas e abrem em "Antes".
    testWidgets('orientações abrem na aba "Antes" e escondem as outras', (
      tester,
    ) async {
      usarTelaAlta(tester);
      await abrirComOrientacoes(tester);

      expect(find.text(catalogoOrientacoes['Antes']!.first), findsOneWidget);
      expect(find.text(catalogoOrientacoes['Durante']!.first), findsNothing);
    });

    // Tabela de casos: tocar em cada aba mostra só os itens dela.
    testWidgets('tocar numa aba mostra só os itens daquela seção', (
      tester,
    ) async {
      usarTelaAlta(tester);
      await abrirComOrientacoes(tester);

      for (final escolhida in catalogoOrientacoes.keys) {
        await tester.tap(find.text(escolhida));
        await tester.pump();

        catalogoOrientacoes.forEach((secao, itens) {
          expect(
            find.text(itens.first),
            secao == escolhida ? findsOneWidget : findsNothing,
            reason: 'aba "$escolhida", item de "$secao"',
          );
        });
      }
    });

    testWidgets('o aviso de enchente sem chuva aparece sempre', (tester) async {
      await abrirComOrientacoes(tester, estagio: EstagioAlerta.monitoramento);

      await rolarAte(tester, find.text(aviso));

      expect(find.text(aviso), findsOneWidget);
    });

    testWidgets('Atenção → aviso em destaque, acima dos contatos', (
      tester,
    ) async {
      await abrirComOrientacoes(tester, estagio: EstagioAlerta.atencao);

      expect(find.byKey(destaque), findsOneWidget);
      expect(
        tester.getTopLeft(find.byKey(destaque)).dy,
        lessThan(tester.getTopLeft(find.text('Defesa Civil')).dy),
      );
    });

    testWidgets('Monitoramento → aviso sem destaque', (tester) async {
      await abrirComOrientacoes(tester, estagio: EstagioAlerta.monitoramento);

      await rolarAte(tester, find.text(aviso));

      expect(find.byKey(destaque), findsNothing);
    });

    // Início ainda carregando ou com erro: sem estágio, sem destaque.
    testWidgets('estágio desconhecido → aviso sem destaque', (tester) async {
      await abrirComOrientacoes(tester);

      await rolarAte(tester, find.text(aviso));

      expect(find.byKey(destaque), findsNothing);
    });

    testWidgets('o botão das vias inundáveis abre o mapa oficial', (
      tester,
    ) async {
      await abrirComOrientacoes(tester);
      final botao = find.text(
        'Ver as vias com risco de alagar no mapa da Defesa Civil',
      );

      await rolarAte(tester, botao);
      await tester.tap(botao);
      await tester.pump();

      expect(discador.sites, [Uri.parse(linkViasInundaveis)]);
    });
  });

  // Passo 57 · CLAUDE.md, seção 7: 48 px, rótulos e contraste de 4,5:1, nos
  // dois temas do app.
  group('acessibilidade', () {
    temasDoApp.forEach((nome, tema) {
      testWidgets('tema $nome', (tester) async {
        final semantica = tester.ensureSemantics();
        await abrirTela(tester, tema: tema());
        await tester.pumpAndSettle();

        await conferirAcessibilidade(tester);
        semantica.dispose();
      });
    });
  });
}
