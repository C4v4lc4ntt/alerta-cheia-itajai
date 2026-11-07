// =============================================================================
// estagio_do_boletim_test.dart — D16: o cartão oficial da tela Início usa a cor
// do estágio que tem o mesmo nome da situação publicada pela Defesa Civil.
//
// Escrito ANTES do código (etapa vermelha do TDD). A regra lê o nome oficial
// (campo "flag"), não o código, porque o portal só confirmou alguns códigos.
// Nomes vistos no portal: "Normalidade" (26/10/2026), "Atenção" e "Alerta"
// (07/11/2026). Os demais são os estágios oficiais da D01.
// =============================================================================
import 'dart:io';

import 'package:alerta_cheia_itajai/data/servicos/leitor_boletim_oficial.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:alerta_cheia_itajai/domain/regras/estagio_do_boletim.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('estagioDoBoletim', () {
    // Tabela de casos: nome publicado → estágio da cor do cartão.
    const casos = <String, EstagioAlerta>{
      'Normalidade': EstagioAlerta.monitoramento,
      'Monitoramento': EstagioAlerta.monitoramento,
      'Atenção': EstagioAlerta.atencao,
      'Alerta': EstagioAlerta.alerta,
      'Emergência': EstagioAlerta.emergencia,
    };
    casos.forEach((situacao, esperado) {
      test('"$situacao" → ${esperado.name}', () {
        expect(estagioDoBoletim(situacao), esperado);
      });
    });

    // O portal pode mudar a grafia sem mudar o sentido.
    test('ignora maiúsculas, acentos e espaços nas pontas', () {
      expect(estagioDoBoletim('  ATENCAO '), EstagioAlerta.atencao);
    });

    // Nome desconhecido: o app não adivinha estágio nenhum.
    test('nome desconhecido → null', () {
      expect(estagioDoBoletim('Alerta Máximo'), isNull);
    });

    test('nome vazio → null', () {
      expect(estagioDoBoletim(''), isNull);
    });

    // Dado real: /api/v1/situacao-atual em 07/11/2026, boletim das 07:57.
    test('boletim real de 07/11/2026 → alerta', () {
      final conteudo = File('test/fixtures/situacao_atual_2026-11-07.json')
          .readAsStringSync();

      final boletim = lerBoletimOficial(conteudo)!;

      expect(estagioDoBoletim(boletim.situacao), EstagioAlerta.alerta);
    });
  });
}
