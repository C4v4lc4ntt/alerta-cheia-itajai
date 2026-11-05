// =============================================================================
// ajustes_view_model_test.dart — RF02 (D15): o estado da tela Bairros e avisos.
//
// Escrito ANTES do código (etapa vermelha do TDD). Usa as preferências falsas,
// em memória, e um catálogo pequeno para os casos ficarem fáceis de ler.
// =============================================================================
import 'package:alerta_cheia_itajai/domain/models/bairro.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:alerta_cheia_itajai/ui/ajustes/ajustes_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../apoio/notificador_falso.dart';
import '../../apoio/preferencias_falsas.dart';

// Fora de ordem de propósito: quem ordena é o ViewModel.
final _catalogo = [
  Bairro(nome: 'São João', estacoesProximas: const ['DC04']),
  Bairro(nome: 'Murta', estacoesProximas: const ['DC02']),
  Bairro(nome: 'Santa Regina', estacoesProximas: const ['DC11']),
  Bairro(nome: 'Sul', estacoesProximas: const ['DC01']),
  Bairro(nome: 'Centro', estacoesProximas: const ['DC01']),
];

void main() {
  late PreferenciasFalsas preferencias;
  late NotificadorFalso notificador;
  late AjustesViewModel viewModel;

  List<String> nomesVisiveis() => [
    for (final bairro in viewModel.bairrosVisiveis) bairro.nome,
  ];

  setUp(() {
    preferencias = PreferenciasFalsas();
    notificador = NotificadorFalso();
    viewModel = AjustesViewModel(
      preferencias: preferencias,
      notificador: notificador,
      catalogo: _catalogo,
    );
  });

  group('lista de bairros', () {
    // O acento não pode jogar "São" para depois de "Sul".
    test('fica em ordem alfabética, ignorando acentos', () {
      expect(nomesVisiveis(), [
        'Centro',
        'Murta',
        'Santa Regina',
        'São João',
        'Sul',
      ]);
    });

    test('a busca filtra pelo trecho digitado', () {
      viewModel.buscar('mur');

      expect(nomesVisiveis(), ['Murta']);
    });

    test('a busca ignora maiúsculas', () {
      viewModel.buscar('CENTRO');

      expect(nomesVisiveis(), ['Centro']);
    });

    // Quem digita no celular costuma não pôr acento.
    test('a busca ignora acentos', () {
      viewModel.buscar('sao');

      expect(nomesVisiveis(), ['São João']);
    });

    test('a busca sem resultado → lista vazia', () {
      viewModel.buscar('xyz');

      expect(nomesVisiveis(), isEmpty);
    });

    test('limpar a busca → volta a lista inteira', () {
      viewModel.buscar('mur');

      viewModel.buscar('');

      expect(nomesVisiveis(), hasLength(_catalogo.length));
    });

    test('buscar avisa a tela', () {
      var avisos = 0;
      viewModel.addListener(() => avisos++);

      viewModel.buscar('mur');

      expect(avisos, 1);
    });
  });

  group('bairros escolhidos', () {
    test('carregar traz o que está salvo no celular', () async {
      preferencias.bairros = ['Murta'];

      await viewModel.carregar();

      expect(viewModel.estaEscolhido('Murta'), isTrue);
      expect(viewModel.estaEscolhido('Centro'), isFalse);
    });

    test('carregar avisa a tela', () async {
      var avisos = 0;
      viewModel.addListener(() => avisos++);

      await viewModel.carregar();

      expect(avisos, 1);
    });

    test('marcar um bairro → salva na hora', () async {
      await viewModel.alternar('Murta');

      expect(preferencias.bairros, ['Murta']);
      expect(viewModel.estaEscolhido('Murta'), isTrue);
    });

    test('marcar dois bairros → salva os dois', () async {
      await viewModel.alternar('Murta');

      await viewModel.alternar('Centro');

      expect(preferencias.bairros, ['Murta', 'Centro']);
    });

    test('desmarcar um bairro → tira só ele', () async {
      preferencias.bairros = ['Murta', 'Centro'];
      await viewModel.carregar();

      await viewModel.alternar('Murta');

      expect(preferencias.bairros, ['Centro']);
      expect(viewModel.estaEscolhido('Murta'), isFalse);
    });

    test('alternar avisa a tela', () async {
      var avisos = 0;
      viewModel.addListener(() => avisos++);

      await viewModel.alternar('Murta');

      expect(avisos, 1);
    });

    // Adendo à D15: sem bairro não há verificação, e um estágio antigo não
    // pode gerar aviso quando o morador voltar a escolher um bairro.
    test('desmarcar o último bairro → apaga o último estágio', () async {
      preferencias
        ..bairros = ['Murta']
        ..ultimoEstagio = EstagioAlerta.atencao;
      await viewModel.carregar();

      await viewModel.alternar('Murta');

      expect(preferencias.ultimoEstagio, isNull);
    });

    test('ainda com bairro escolhido → mantém o último estágio', () async {
      preferencias
        ..bairros = ['Murta', 'Centro']
        ..ultimoEstagio = EstagioAlerta.atencao;
      await viewModel.carregar();

      await viewModel.alternar('Murta');

      expect(preferencias.ultimoEstagio, EstagioAlerta.atencao);
    });
  });

  group('permissão de notificação', () {
    test('marcar um bairro → pede a permissão', () async {
      await viewModel.alternar('Murta');

      expect(notificador.pedidosDePermissao, 1);
    });

    test('desmarcar um bairro → não pede a permissão', () async {
      preferencias.bairros = ['Murta', 'Centro'];
      await viewModel.carregar();
      final pedidosAntes = notificador.pedidosDePermissao;

      await viewModel.alternar('Murta');

      expect(notificador.pedidosDePermissao, pedidosAntes);
    });

    test('começa sem o aviso de permissão negada', () {
      expect(viewModel.permissaoNegada, isFalse);
    });

    // O morador pode ativar depois nos ajustes do celular: a escolha fica.
    test('permissão negada → mantém o bairro e mostra o aviso', () async {
      notificador.permissaoConcedida = false;

      await viewModel.alternar('Murta');

      expect(preferencias.bairros, ['Murta']);
      expect(viewModel.estaEscolhido('Murta'), isTrue);
      expect(viewModel.permissaoNegada, isTrue);
    });

    // A tela desenha a marca antes da resposta e o aviso depois dela.
    test('permissão negada → avisa a tela de novo', () async {
      notificador.permissaoConcedida = false;
      var avisos = 0;
      viewModel.addListener(() => avisos++);

      await viewModel.alternar('Murta');

      expect(avisos, 2);
    });

    test('permissão concedida depois → o aviso some', () async {
      notificador.permissaoConcedida = false;
      await viewModel.alternar('Murta');

      notificador.permissaoConcedida = true;
      await viewModel.alternar('Centro');

      expect(viewModel.permissaoNegada, isFalse);
    });

    test('desmarcar o último bairro → o aviso some', () async {
      notificador.permissaoConcedida = false;
      await viewModel.alternar('Murta');

      await viewModel.alternar('Murta');

      expect(viewModel.permissaoNegada, isFalse);
    });

    // O morador pode ter desligado as notificações nos ajustes do celular.
    test('carregar com bairro salvo → confere a permissão', () async {
      preferencias.bairros = ['Murta'];
      notificador.permissaoConcedida = false;

      await viewModel.carregar();

      expect(viewModel.permissaoNegada, isTrue);
    });

    test('carregar sem bairro → não pede a permissão', () async {
      await viewModel.carregar();

      expect(notificador.pedidosDePermissao, 0);
    });
  });
}
