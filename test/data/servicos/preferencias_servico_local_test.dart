// =============================================================================
// preferencias_servico_local_test.dart — RF02 (D14): os dados do morador
// guardados no celular com o pacote shared_preferences.
//
// Escrito ANTES do código (etapa vermelha do TDD). O armazenamento é trocado
// por um mapa em memória, então o teste não depende do celular.
// =============================================================================
import 'package:alerta_cheia_itajai/data/servicos/preferencias_servico.dart';
import 'package:alerta_cheia_itajai/data/servicos/preferencias_servico_local.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
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
}
