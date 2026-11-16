// =============================================================================
// preferencias_servico_local_test.dart — RF02 (D14): os dados do morador
// guardados no celular com o pacote shared_preferences.
//
// Escrito ANTES do código (etapa vermelha do TDD). O armazenamento é trocado
// por um mapa em memória, então o teste não depende do celular.
// Passo 57 (D21), ETAPA VERMELHA: guardar e ler a última consulta que deu
// certo, para a tela Início mostrar sem internet.
// =============================================================================
import 'package:alerta_cheia_itajai/data/servicos/preferencias_servico.dart';
import 'package:alerta_cheia_itajai/data/servicos/preferencias_servico_local.dart';
import 'package:alerta_cheia_itajai/domain/models/boletim_oficial.dart';
import 'package:alerta_cheia_itajai/domain/models/consulta_guardada.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:alerta_cheia_itajai/domain/models/leitura_nivel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Só os métodos usados são escritos; qualquer outro falha no teste.
class _ArmazemFalso extends Fake implements SharedPreferencesAsync {
  final dados = <String, Object>{};

  @override
  Future<List<String>?> getStringList(String key) async =>
      dados[key] as List<String>?;

  @override
  Future<String?> getString(String key) async => dados[key] as String?;

  @override
  Future<void> setString(String key, String value) async {
    dados[key] = value;
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    dados[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    dados.remove(key);
  }
}

void main() {
  late _ArmazemFalso armazem;
  late PreferenciasServico preferencias;

  setUp(() {
    armazem = _ArmazemFalso();
    preferencias = PreferenciasServicoLocal(armazem: armazem);
  });

  group('PreferenciasServicoLocal', () {
    test('sem bairros salvos → lista vazia', () async {
      expect(await preferencias.lerBairrosEscolhidos(), isEmpty);
    });

    test('com bairros salvos → devolve os nomes', () async {
      armazem.dados['bairros_escolhidos'] = ['Murta', 'Centro'];

      expect(await preferencias.lerBairrosEscolhidos(), ['Murta', 'Centro']);
    });

    test('salvar e ler de volta os bairros', () async {
      await preferencias.salvarBairrosEscolhidos(['Murta', 'Centro']);

      expect(await preferencias.lerBairrosEscolhidos(), ['Murta', 'Centro']);
    });

    // Salvar substitui a escolha anterior: não acumula bairros desmarcados.
    test('salvar de novo substitui os bairros', () async {
      await preferencias.salvarBairrosEscolhidos(['Murta', 'Centro']);

      await preferencias.salvarBairrosEscolhidos(['Centro']);

      expect(await preferencias.lerBairrosEscolhidos(), ['Centro']);
    });

    test('salvar lista vazia → nenhum bairro escolhido', () async {
      await preferencias.salvarBairrosEscolhidos(['Murta']);

      await preferencias.salvarBairrosEscolhidos(const []);

      expect(await preferencias.lerBairrosEscolhidos(), isEmpty);
    });

    // Sem bairro não há verificação; um estágio antigo não pode virar a base
    // de um aviso quando o morador voltar a escolher um bairro (adendo à D15).
    test('apagar o último estágio → volta a null', () async {
      await preferencias.salvarUltimoEstagio(EstagioAlerta.atencao);

      await preferencias.apagarUltimoEstagio();

      expect(await preferencias.lerUltimoEstagio(), isNull);
    });

    test('sem estágio salvo → null', () async {
      expect(await preferencias.lerUltimoEstagio(), isNull);
    });

    // O enum vira texto no celular, e cada valor precisa voltar igual.
    for (final estagio in EstagioAlerta.values) {
      test('salvar e ler de volta: ${estagio.name}', () async {
        await preferencias.salvarUltimoEstagio(estagio);

        expect(await preferencias.lerUltimoEstagio(), estagio);
      });
    }

    test('guarda o estágio pelo nome', () async {
      await preferencias.salvarUltimoEstagio(EstagioAlerta.atencao);

      expect(armazem.dados['ultimo_estagio'], 'atencao');
    });

    // Sem estágio válido, a próxima leitura vira só o ponto de partida (D12).
    test('valor desconhecido → null', () async {
      armazem.dados['ultimo_estagio'] = 'normal';

      expect(await preferencias.lerUltimoEstagio(), isNull);
    });
  });

  group('última consulta (D21, uso sem internet)', () {
    // Leituras e boletim reais de 07/11/2026 (10:57 UTC = 07:57 em Brasília).
    final as1057 = DateTime.utc(2026, 11, 7, 10, 57);
    final as1100 = DateTime.utc(2026, 11, 7, 11);

    ConsultaGuardada consulta({BoletimOficial? boletim}) => ConsultaGuardada(
      leituras: [
        LeituraNivel(codigoEstacao: 'DC01', nivel: 0.8, medidoEm: as1057),
        LeituraNivel(codigoEstacao: 'DC07', nivel: 0.06, medidoEm: as1057),
      ],
      boletim: boletim,
      consultadoEm: as1100,
    );

    final boletim = BoletimOficial(
      codigo: 'normalidade',
      situacao: 'Normalidade',
      texto: 'Maré alta entre 13h e 15h.',
      atualizadoEm: as1057,
    );

    test('sem consulta guardada → null', () async {
      expect(await preferencias.lerUltimaConsulta(), isNull);
    });

    test('salvar e ler de volta: as leituras', () async {
      await preferencias.salvarUltimaConsulta(consulta());

      final lida = (await preferencias.lerUltimaConsulta())!;

      expect(
        [for (final l in lida.leituras) l.codigoEstacao],
        ['DC01', 'DC07'],
      );
      expect([for (final l in lida.leituras) l.nivel], [0.8, 0.06]);
      expect([for (final l in lida.leituras) l.medidoEm], [as1057, as1057]);
    });

    test('salvar e ler de volta: a hora da consulta', () async {
      await preferencias.salvarUltimaConsulta(consulta());

      expect((await preferencias.lerUltimaConsulta())!.consultadoEm, as1100);
    });

    test('salvar e ler de volta: o boletim oficial', () async {
      await preferencias.salvarUltimaConsulta(consulta(boletim: boletim));

      final lido = (await preferencias.lerUltimaConsulta())!.boletim!;

      expect(lido.codigo, 'normalidade');
      expect(lido.situacao, 'Normalidade');
      expect(lido.texto, 'Maré alta entre 13h e 15h.');
      expect(lido.atualizadoEm, as1057);
    });

    test('consulta sem boletim → volta sem boletim', () async {
      await preferencias.salvarUltimaConsulta(consulta());

      expect((await preferencias.lerUltimaConsulta())!.boletim, isNull);
    });

    test('salvar de novo substitui a consulta anterior', () async {
      await preferencias.salvarUltimaConsulta(consulta(boletim: boletim));

      await preferencias.salvarUltimaConsulta(consulta());

      expect((await preferencias.lerUltimaConsulta())!.boletim, isNull);
    });

    // D21: dado corrompido não pode derrubar a tela; vira "nada guardado".
    final invalidos = {
      'texto que não é JSON': 'não é json',
      'JSON sem as leituras': '{"consultadoEm": "2026-11-07T11:00:00.000Z"}',
      'data inválida':
          '{"consultadoEm": "ontem", "leituras": [], "boletim": null}',
    };
    invalidos.forEach((caso, texto) {
      test('$caso → null', () async {
        armazem.dados['ultima_consulta'] = texto;

        expect(await preferencias.lerUltimaConsulta(), isNull);
      });
    });
  });
}
