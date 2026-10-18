// =============================================================================
// app_test.dart — teste de widget da "casca" do app (navegação inferior).
//
// É um teste de infraestrutura (não pertence a um RF): garante que o projeto
// compila, abre na aba Início e troca de aba. Também dá ao CI algo para rodar
// desde o primeiro commit.
//
// Estrutura de um teste Flutter, comparando com JUnit:
//   group(...)       ≈ uma classe de teste / @Nested
//   testWidgets(...) ≈ um método @Test que monta widgets
//   expect(a, b)     ≈ assertThat(a, b)
// =============================================================================
import 'package:alerta_cheia_itajai/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Navegação principal', () {
    testWidgets('abre na aba Início e mostra as 4 abas', (tester) async {
      // ARRANGE/ACT: "pumpWidget" monta o app numa tela virtual de teste.
      await tester.pumpWidget(const AlertaCheiaApp());

      // ASSERT: a tela inicial é a de Início...
      expect(find.byKey(const Key('tela_inicio')), findsOneWidget);

      // ...e os 4 botões da barra inferior existem (leitor de tela usa o rótulo).
      for (final aba in ['Início', 'Mapa', 'Ajuda', 'Ajustes']) {
        expect(find.widgetWithText(NavigationDestination, aba), findsOneWidget);
      }
    });

    testWidgets('tocar em uma aba mostra a tela correspondente', (
      tester,
    ) async {
      await tester.pumpWidget(const AlertaCheiaApp());

      // ACT: toca no botão "Mapa" e espera as animações terminarem.
      await tester.tap(find.widgetWithText(NavigationDestination, 'Mapa'));
      await tester.pumpAndSettle();

      // ASSERT: a tela do mapa apareceu e a de início saiu.
      expect(find.byKey(const Key('tela_mapa')), findsOneWidget);
      expect(find.byKey(const Key('tela_inicio')), findsNothing);
    });
  });
}
