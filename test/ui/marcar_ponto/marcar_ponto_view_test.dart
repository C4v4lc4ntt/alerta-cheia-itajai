// =============================================================================
// marcar_ponto_view_test.dart — RF03 (D17): a tela "Marcar rua alagada",
// parte 1 (ciclo 22a): a localização.
//
// Escrito ANTES do código (etapa vermelha do TDD). Usa o ViewModel de verdade
// com os serviços falsos de test/apoio/: a tela é testada do jeito que o
// morador a vê. Os textos são os aprovados em 09/11 e 10/11. As posições saem
// do catálogo areaItajai, sem coordenadas inventadas.
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/area_itajai.dart';
import 'package:alerta_cheia_itajai/domain/models/leitura_localizacao.dart';
import 'package:alerta_cheia_itajai/ui/marcar_ponto/marcar_ponto_view.dart';
import 'package:alerta_cheia_itajai/ui/marcar_ponto/marcar_ponto_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/localizacao_servico_falso.dart';
import '../../apoio/pontos_servico_falso.dart';

// Centro do retângulo de Itajaí: com certeza dentro da área. A precisão tem
// casa decimal, como a do GPS de verdade, e a tela arredonda para metros
// inteiros.
final _dentroDeItajai = LocalizacaoObtida(
  latitude: (areaItajai.latitudeMinima + areaItajai.latitudeMaxima) / 2,
  longitude: (areaItajai.longitudeMinima + areaItajai.longitudeMaxima) / 2,
  precisaoMetros: 12.4,
);

// Um pouco ao norte da latitude máxima: fora da área.
final _foraDeItajai = LocalizacaoObtida(
  latitude: areaItajai.latitudeMaxima + 0.01,
  longitude: _dentroDeItajai.longitude,
  precisaoMetros: 12.4,
);

const _buscando = 'Buscando sua localização…';
const _precisao = 'Sua localização atual · precisão de 12 m';
const _foraDaArea =
    'Você está fora de Itajaí. Só é possível marcar pontos dentro do '
    'município.';

// Botões dos casos sem localização: nenhum aparece enquanto busca.
const _botoesDeLocalizacao = [
  'Ligar a localização',
  'Permitir localização',
  'Abrir configurações',
  'Tentar de novo',
];

void main() {
  late LocalizacaoServicoFalso localizacao;
  late MarcarPontoViewModel viewModel;

  setUp(() {
    localizacao = LocalizacaoServicoFalso(resposta: _dentroDeItajai);
    viewModel = MarcarPontoViewModel(
      localizacao: localizacao,
      pontos: PontosServicoFalso(),
      agora: () => DateTime.utc(2026, 11, 10, 22),
    );
  });

  // Abre a tela e espera a leitura falsa terminar.
  Future<void> abrirTela(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MarcarPontoView(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();
  }

  // Acha o botão pelo texto, seja FilledButton, OutlinedButton ou TextButton
  // (todos herdam de ButtonStyleButton), com ou sem ícone.
  ButtonStyleButton botao(WidgetTester tester, String texto) =>
      tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text(texto),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        ),
      );

  // D17: sem posição válida, o envio fica desativado.
  void conferirEnvioDesativado(WidgetTester tester) =>
      expect(botao(tester, 'Enviar para o mapa').onPressed, isNull);

  testWidgets('mostra o título "Marcar rua alagada"', (tester) async {
    await abrirTela(tester);

    expect(find.text('Marcar rua alagada'), findsOneWidget);
    expect(find.text('1. Onde está alagado?'), findsOneWidget);
  });

  testWidgets('enquanto busca → "Buscando sua localização…", sem botão', (
    tester,
  ) async {
    // Arrange: o "GPS" nunca responde.
    localizacao.nuncaTermina = true;

    // Act: só um quadro, sem pumpAndSettle (o indicador de progresso gira
    // para sempre e o pumpAndSettle nunca terminaria).
    await tester.pumpWidget(
      MaterialApp(home: MarcarPontoView(viewModel: viewModel)),
    );
    await tester.pump();

    // Assert
    expect(find.text(_buscando), findsOneWidget);
    for (final texto in _botoesDeLocalizacao) {
      expect(find.text(texto), findsNothing);
    }
    conferirEnvioDesativado(tester);
  });

  // Tabela de casos (como o @ParameterizedTest do JUnit): cada caso sem
  // localização tem a sua mensagem, o seu botão e a sua ação (decisões de
  // 10/11). O contador diz se o botão chamou a ação certa.
  final casosSemLocalizacao =
      <
        LeituraLocalizacao,
        ({String mensagem, String botao, int Function() contador, int esperado})
      >{
        const GpsDesligado(): (
          mensagem:
              'A localização do celular está desligada. Ligue para marcar '
              'onde está alagado.',
          botao: 'Ligar a localização',
          contador: () => localizacao.aberturasDaLocalizacao,
          esperado: 1,
        ),
        const PermissaoNegada(): (
          mensagem:
              'Precisamos da sua localização para marcar onde está '
              'alagado.',
          botao: 'Permitir localização',
          // 1 leitura ao abrir a tela + 1 pelo botão.
          contador: () => localizacao.leituras,
          esperado: 2,
        ),
        const PermissaoBloqueada(): (
          mensagem:
              'A localização está bloqueada para o Alerta Cheia. Libere nas '
              'configurações do app.',
          botao: 'Abrir configurações',
          contador: () => localizacao.aberturasDoApp,
          esperado: 1,
        ),
        const FalhaNaLeitura(): (
          mensagem:
              'Não foi possível achar sua localização. Se puder, vá para um '
              'lugar aberto e tente de novo.',
          botao: 'Tentar de novo',
          contador: () => localizacao.leituras,
          esperado: 2,
        ),
      };

  casosSemLocalizacao.forEach((leitura, caso) {
    final nome = leitura.runtimeType;

    testWidgets('$nome → mensagem e botão "${caso.botao}", sem envio', (
      tester,
    ) async {
      localizacao.resposta = leitura;

      await abrirTela(tester);

      expect(find.text(caso.mensagem), findsOneWidget);
      expect(find.text(caso.botao), findsOneWidget);
      conferirEnvioDesativado(tester);
    });

    testWidgets('$nome → tocar em "${caso.botao}" chama a ação certa', (
      tester,
    ) async {
      localizacao.resposta = leitura;
      await abrirTela(tester);

      await tester.tap(find.text(caso.botao));
      await tester.pumpAndSettle();

      expect(caso.contador(), caso.esperado);
    });
  });

  testWidgets('posição dentro de Itajaí → mostra a precisão em metros', (
    tester,
  ) async {
    await abrirTela(tester);

    expect(find.text(_precisao), findsOneWidget);
    expect(find.text(_foraDaArea), findsNothing);
  });

  testWidgets('posição fora de Itajaí → aviso próprio, sem botão e sem envio', (
    tester,
  ) async {
    localizacao.resposta = _foraDeItajai;

    await abrirTela(tester);

    expect(find.text(_foraDaArea), findsOneWidget);
    expect(find.text(_precisao), findsNothing);
    for (final texto in _botoesDeLocalizacao) {
      expect(find.text(texto), findsNothing);
    }
    conferirEnvioDesativado(tester);
  });

  testWidgets('voltar ao app (das configurações) busca a localização de novo', (
    tester,
  ) async {
    // Arrange: o morador abre a tela com o GPS desligado...
    localizacao.resposta = const GpsDesligado();
    await abrirTela(tester);

    // ...vai às configurações, liga a localização e volta ao app. O Flutter
    // passa por estes estados ao sair e ao voltar.
    localizacao.resposta = _dentroDeItajai;
    for (final estado in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(estado);
    }
    await tester.pumpAndSettle();

    // Assert: leu de novo e a tela mostra a posição nova.
    expect(localizacao.leituras, 2);
    expect(find.text(_precisao), findsOneWidget);
  });
}
