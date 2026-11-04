// =============================================================================
// situacao_do_bairro_test.dart — RF02 (D08): o bairro mostra o estágio da
// cidade e, como complemento, as estações próximas com o estágio de cada uma.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// =============================================================================
import 'package:alerta_cheia_itajai/domain/models/bairro.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:alerta_cheia_itajai/domain/regras/situacao_do_bairro.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final murta = Bairro(nome: 'Murta', estacoesProximas: const ['DC02', 'DC09']);

  group('situacaoDoBairro', () {
    // Regra de segurança da D08: estações próximas tranquilas não reduzem o
    // estágio mostrado, mesmo com outra estação da cidade em Emergência.
    test('estações próximas em estágio menor → bairro fica no da cidade', () {
      final situacao = situacaoDoBairro(
        bairro: murta,
        estagiosPorEstacao: const {
          'DC02': EstagioAlerta.monitoramento,
          'DC09': EstagioAlerta.atencao,
          'DC10': EstagioAlerta.emergencia,
        },
      );

      expect(situacao.estagio, EstagioAlerta.emergencia);
    });

    // O complemento segue a ordem da tabela, da estação mais próxima à menos
    // próxima, e não mostra estações de fora do bairro.
    test('lista só as estações próximas, na ordem do bairro', () {
      final situacao = situacaoDoBairro(
        bairro: murta,
        estagiosPorEstacao: const {
          'DC10': EstagioAlerta.emergencia,
          'DC09': EstagioAlerta.atencao,
          'DC02': EstagioAlerta.monitoramento,
        },
      );

      expect(situacao.estacoesProximas, [
        (codigo: 'DC02', estagio: EstagioAlerta.monitoramento),
        (codigo: 'DC09', estagio: EstagioAlerta.atencao),
      ]);
    });

    // Uma estação sem leitura some do complemento, mas não muda o estágio.
    test('estação próxima sem leitura → fica de fora do complemento', () {
      final situacao = situacaoDoBairro(
        bairro: murta,
        estagiosPorEstacao: const {
          'DC09': EstagioAlerta.alerta,
          'DC10': EstagioAlerta.atencao,
        },
      );

      expect(situacao.estagio, EstagioAlerta.alerta);
      expect(situacao.estacoesProximas, [
        (codigo: 'DC09', estagio: EstagioAlerta.alerta),
      ]);
    });

    // Sem leituras NÃO é "está tudo bem": nunca assume Monitoramento.
    test('nenhuma leitura → ArgumentError', () {
      expect(
        () => situacaoDoBairro(bairro: murta, estagiosPorEstacao: const {}),
        throwsArgumentError,
      );
    });
  });
}
