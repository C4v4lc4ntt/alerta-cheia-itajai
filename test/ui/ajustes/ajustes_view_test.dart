// =============================================================================
// ajustes_view_test.dart — RF02 (D08, D14 e D15): a tela Bairros e avisos.
//
// Escrito ANTES do código (etapa vermelha do TDD). Usa o ViewModel de verdade
// com serviços falsos: a tela é testada do jeito que o morador a vê.
// =============================================================================
import 'package:alerta_cheia_itajai/domain/models/bairro.dart';
import 'package:alerta_cheia_itajai/ui/ajustes/ajustes_view.dart';
import 'package:alerta_cheia_itajai/ui/ajustes/ajustes_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/notificador_falso.dart';
import '../../apoio/preferencias_falsas.dart';

const _avisoFixo =
    'O aviso pode atrasar e não substitui os canais oficiais. '
    'Emergência: 199, 193 ou 192.';
const _avisoIphone = 'No iPhone, o app só verifica com ele em uso.';
const _avisoPermissao =
    'Sem permissão, o app não consegue avisar. '
    'Ative as notificações nos ajustes do celular.';

// Estações reais do catálogo: a tela mostra o código e o rio de cada uma.
final _catalogo = [
  Bairro(nome: 'Centro', estacoesProximas: const ['DC01']),
  Bairro(nome: 'Murta', estacoesProximas: const ['DC02', 'DC01']),
  Bairro(nome: 'São João', estacoesProximas: const ['DC04']),
];

void main() {
  late PreferenciasFalsas preferencias;
  late NotificadorFalso notificador;
  late AjustesViewModel viewModel;

  setUp(() {
    preferencias = PreferenciasFalsas();
    notificador = NotificadorFalso();
    viewModel = AjustesViewModel(
      preferencias: preferencias,
      notificador: notificador,
      catalogo: _catalogo,
    );
  });

  Future<void> abrirTela(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: AjustesView(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();
  }

  // Lê o estado da caixa de marcação do bairro.
  bool? marcado(WidgetTester tester, String nome) => tester
      .widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, nome))
      .value;

  testWidgets('mostra o título, a introdução e o aviso fixo', (tester) async {
    await abrirTela(tester);

    expect(find.byKey(const Key('tela_ajustes')), findsOneWidget);
    expect(find.text('Bairros e avisos'), findsOneWidget);
    expect(
      find.text(
        'Escolha os bairros que você quer acompanhar. '
        'O app avisa quando o estágio mudar.',
      ),
      findsOneWidget,
    );
    expect(find.text(_avisoFixo), findsOneWidget);
  });

  testWidgets('lista os bairros do catálogo', (tester) async {
    await abrirTela(tester);

    for (final bairro in _catalogo) {
      expect(find.text(bairro.nome), findsOneWidget);
    }
  });

  testWidgets('ao abrir, marca o que já está salvo', (tester) async {
    preferencias.bairros = ['Murta'];

    await abrirTela(tester);

    expect(marcado(tester, 'Murta'), isTrue);
    expect(marcado(tester, 'Centro'), isFalse);
  });

  testWidgets('tocar em um bairro marca e salva', (tester) async {
    await abrirTela(tester);

    await tester.tap(find.text('Centro'));
    await tester.pumpAndSettle();

    expect(marcado(tester, 'Centro'), isTrue);
    expect(preferencias.bairros, ['Centro']);
  });

  // D08: a proximidade é estimada e a tela precisa dizer isso.
  testWidgets('bairro marcado mostra as estações como estimativa', (
    tester,
  ) async {
    preferencias.bairros = ['Murta'];

    await abrirTela(tester);

    expect(
      find.text(
        'Estações próximas (estimativa, não é dado oficial): '
        'DC02 · Rio Itajaí-Açu, DC01 · Rio Itajaí-Açu',
      ),
      findsOneWidget,
    );
  });

  testWidgets('bairro sem marcar não mostra as estações', (tester) async {
    await abrirTela(tester);

    expect(find.textContaining('Estações próximas'), findsNothing);
  });

  testWidgets('digitar na busca filtra a lista', (tester) async {
    await abrirTela(tester);

    await tester.enterText(find.byType(TextField), 'sao');
    await tester.pumpAndSettle();

    expect(find.text('São João'), findsOneWidget);
    expect(find.text('Centro'), findsNothing);
  });

  testWidgets('busca sem resultado explica que nada foi encontrado', (
    tester,
  ) async {
    await abrirTela(tester);

    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pumpAndSettle();

    expect(find.text('Nenhum bairro encontrado.'), findsOneWidget);
  });

  // Trocar de aba recria a tela com a busca vazia; a lista precisa acompanhar.
  testWidgets('ao abrir de novo, a busca anterior é limpa', (tester) async {
    viewModel.buscar('mur');

    await abrirTela(tester);

    expect(find.text('Centro'), findsOneWidget);
  });

  testWidgets('permissão negada mostra como resolver', (tester) async {
    notificador.permissaoConcedida = false;
    await abrirTela(tester);

    await tester.tap(find.text('Centro'));
    await tester.pumpAndSettle();

    expect(find.text(_avisoPermissao), findsOneWidget);
  });

  testWidgets('permissão concedida não mostra o aviso', (tester) async {
    await abrirTela(tester);

    await tester.tap(find.text('Centro'));
    await tester.pumpAndSettle();

    expect(find.text(_avisoPermissao), findsNothing);
  });

  // D14: no iOS não há verificação com o app fechado.
  testWidgets('no iPhone, avisa que só verifica em uso', (tester) async {
    await abrirTela(tester);

    expect(find.text(_avisoIphone), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('no Android, não mostra o aviso do iPhone', (tester) async {
    await abrirTela(tester);

    expect(find.text(_avisoIphone), findsNothing);
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
