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
import 'package:alerta_cheia_itajai/data/servicos/boletim_servico.dart';
import 'package:alerta_cheia_itajai/data/servicos/nivel_rio_servico.dart';
import 'package:alerta_cheia_itajai/domain/models/leitura_nivel.dart';
import 'package:alerta_cheia_itajai/ui/inicio/inicio_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class NivelRioServicoMock extends Mock implements NivelRioServico {}

class BoletimServicoMock extends Mock implements BoletimServico {}

void main() {
  late AlertaCheiaApp app;

  // Desde o ciclo 7 o app recebe o ViewModel da tela Início pronto.
  // Aqui ele usa serviços falsos: o teste de navegação não acessa a internet.
  setUp(() {
    final niveis = NivelRioServicoMock();
    final boletins = BoletimServicoMock();
    when(() => niveis.buscarLeituras()).thenAnswer(
      (_) async => [
        LeituraNivel(
          codigoEstacao: 'DC01',
          nivel: 0.80,
          medidoEm: DateTime.utc(2026, 10, 26, 21, 30),
        ),
      ],
    );
    when(() => boletins.buscarBoletim()).thenAnswer((_) async => null);
    when(() => boletins.buscarTabuaMare()).thenAnswer((_) async => null);
    app = AlertaCheiaApp(
      inicioViewModel: InicioViewModel(niveis: niveis, boletins: boletins),
    );
  });

  group('Navegação principal', () {
    testWidgets('abre na aba Início e mostra as 4 abas', (tester) async {
      // ARRANGE/ACT: "pumpWidget" monta o app numa tela virtual de teste.
      await tester.pumpWidget(app);

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
      await tester.pumpWidget(app);

      // ACT: toca no botão "Mapa" e espera as animações terminarem.
      await tester.tap(find.widgetWithText(NavigationDestination, 'Mapa'));
      await tester.pumpAndSettle();

      // ASSERT: a tela do mapa apareceu e a de início saiu.
      expect(find.byKey(const Key('tela_mapa')), findsOneWidget);
      expect(find.byKey(const Key('tela_inicio')), findsNothing);
    });
  });
}
