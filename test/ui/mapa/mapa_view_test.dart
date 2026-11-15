// =============================================================================
// mapa_view_test.dart — RF03 (D17, item 7): o botão "Marcar rua alagada" na
// aba Mapa. Ciclo 23. RF04 (ciclo 6c): a aba mostra o mapa dos pontos.
//
// Escrito ANTES do código (etapa vermelha do TDD). A MapaView recebe uma
// função que cria o MarcarPontoViewModel (como um Supplier do Java). Se ela
// vier null, o Firebase não ligou: o botão fica desativado, com o texto
// aprovado em 10/11, e a tela de marcar não abre. Os ViewModels criados aqui
// usam os serviços falsos de test/apoio/, sem GPS e sem Firestore.
// No RF04, a MapaView também recebe como criar o MapaViewModel (criarMapa);
// null = Firebase desligado, e a aba fica como no RF03, sem mapa vazio que
// pareça "nenhuma rua alagada" (decisão de 15/11).
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/area_itajai.dart';
import 'package:alerta_cheia_itajai/domain/models/leitura_localizacao.dart';
import 'package:alerta_cheia_itajai/ui/mapa/mapa_de_pontos.dart';
import 'package:alerta_cheia_itajai/ui/mapa/mapa_view.dart';
import 'package:alerta_cheia_itajai/ui/mapa/mapa_view_model.dart';
import 'package:alerta_cheia_itajai/ui/marcar_ponto/marcar_ponto_view.dart';
import 'package:alerta_cheia_itajai/ui/marcar_ponto/marcar_ponto_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/localizacao_servico_falso.dart';
import '../../apoio/pontos_servico_falso.dart';

const _marcar = 'Marcar rua alagada';
const _firebaseDesligado =
    'Não foi possível ligar o envio de marcações. Feche e abra o app de novo.';

void main() {
  // Quantos ViewModels a MapaView pediu para criar.
  late int criados;

  // Função entregue à MapaView: cria um ViewModel novo a cada chamada, com
  // uma posição no centro do catálogo areaItajai (sem coordenada inventada).
  MarcarPontoViewModel criarMarcarPonto() {
    criados++;
    return MarcarPontoViewModel(
      localizacao: LocalizacaoServicoFalso(
        resposta: LocalizacaoObtida(
          latitude: (areaItajai.latitudeMinima + areaItajai.latitudeMaxima) / 2,
          longitude:
              (areaItajai.longitudeMinima + areaItajai.longitudeMaxima) / 2,
          precisaoMetros: 12.4,
        ),
      ),
      pontos: PontosServicoFalso(),
      agora: () => DateTime.utc(2026, 11, 10, 22),
    );
  }

  setUp(() => criados = 0);

  // Monta a aba dentro de um MaterialApp, que dá o Navigator para abrir
  // a tela de marcar por cima.
  Future<void> abrirMapa(
    WidgetTester tester, {
    MarcarPontoViewModel Function()? criar,
  }) async {
    await tester.pumpWidget(
      MaterialApp(home: MapaView(criarMarcarPonto: criar)),
    );
  }

  // Encontra o botão (qualquer botão do Material) que contém o texto.
  Finder botaoMarcar() => find.ancestor(
    of: find.text(_marcar),
    matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
  );

  group('MapaView — Firebase ligado', () {
    testWidgets('tocar em "Marcar rua alagada" abre a tela de marcar', (
      tester,
    ) async {
      // Arrange
      await abrirMapa(tester, criar: criarMarcarPonto);

      // Act
      await tester.tap(find.text(_marcar));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(MarcarPontoView), findsOneWidget);
    });

    testWidgets('cada abertura cria um ViewModel novo', (tester) async {
      // Um ViewModel reaproveitado guardaria o "enviado" da vez anterior,
      // e o botão de enviar continuaria desativado.
      await abrirMapa(tester, criar: criarMarcarPonto);

      await tester.tap(find.text(_marcar));
      await tester.pumpAndSettle();
      await tester.pageBack(); // seta de voltar da AppBar
      await tester.pumpAndSettle();
      await tester.tap(find.text(_marcar));
      await tester.pumpAndSettle();

      expect(criados, 2);
    });

    testWidgets('não mostra o aviso de Firebase desligado', (tester) async {
      await abrirMapa(tester, criar: criarMarcarPonto);

      expect(find.text(_firebaseDesligado), findsNothing);
    });
  });

  group('MapaView — Firebase desligado (criarMarcarPonto null)', () {
    testWidgets('o botão "Marcar rua alagada" fica desativado', (tester) async {
      await abrirMapa(tester);

      final botao = tester.widget<ButtonStyleButton>(botaoMarcar());
      expect(botao.enabled, isFalse);
    });

    testWidgets('mostra o aviso aprovado em 10/11', (tester) async {
      await abrirMapa(tester);

      expect(find.text(_firebaseDesligado), findsOneWidget);
    });

    testWidgets('tocar no botão não abre a tela de marcar', (tester) async {
      await abrirMapa(tester);

      // warnIfMissed: false porque o toque num botão desativado é esperado.
      await tester.tap(find.text(_marcar), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(MarcarPontoView), findsNothing);
    });
  });

  // RF04 (ciclo 6c): com o Firebase ligado, a aba mostra o mapa. O
  // MapaViewModel é criado ao abrir a aba e descartado ao sair dela.
  group('MapaView — mapa dos pontos (RF04)', () {
    late PontosServicoFalso pontos;
    late LocalizacaoServicoFalso localizacao;

    setUp(() {
      pontos = PontosServicoFalso();
      localizacao = LocalizacaoServicoFalso(resposta: const PermissaoNegada());
    });

    MapaViewModel criarMapa() => MapaViewModel(
      pontos: pontos,
      localizacao: localizacao,
      agora: () => DateTime.utc(2026, 11, 15, 14),
    );

    // Abre a aba com o mapa, sem ladrilhos (sem internet, D19).
    Future<void> abrirComMapa(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MapaView(
            criarMarcarPonto: criarMarcarPonto,
            criarMapa: criarMapa,
            mostrarLadrilhos: false,
          ),
        ),
      );
      await tester.pump();
    }

    // Sai da aba: a tela some e o ViewModel é descartado (sem Timer
    // pendente no fim do teste).
    Future<void> sairDaAba(WidgetTester tester) =>
        tester.pumpWidget(const SizedBox());

    testWidgets('mostra o mapa e o botão "Marcar rua alagada"', (tester) async {
      await abrirComMapa(tester);

      expect(find.byType(MapaDePontos), findsOneWidget);
      expect(find.text(_marcar), findsOneWidget);
      await sairDaAba(tester);
    });

    testWidgets('ao abrir → acompanha os pontos e lê o GPS uma vez', (
      tester,
    ) async {
      await abrirComMapa(tester);

      expect(pontos.listas.hasListener, isTrue);
      expect(localizacao.leituras, 1);
      await sairDaAba(tester);
    });

    testWidgets('ao sair da aba → para de ouvir o Firestore', (tester) async {
      await abrirComMapa(tester);

      await sairDaAba(tester);

      expect(pontos.listas.hasListener, isFalse);
    });

    testWidgets('Firebase desligado → sem mapa', (tester) async {
      await abrirMapa(tester);

      expect(find.byType(MapaDePontos), findsNothing);
    });
  });
}
