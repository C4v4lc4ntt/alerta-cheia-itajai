// =============================================================================
// leitor_boletim_oficial_test.dart — RF01, ciclo 5 (parte a): boletim oficial.
//
// ETAPA VERMELHA: o leitor ainda não existe, então este teste nem compila.
// Fonte: /api/v1/situacao-atual do portal da Defesa Civil de Itajaí, salvo
// em 26/10/2026 19:15 (D10). O teste lê a cópia: nunca acessa a internet.
// =============================================================================
import 'dart:io';

import 'package:alerta_cheia_itajai/data/servicos/leitor_boletim_oficial.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final conteudo = File('test/fixtures/situacao_atual_2026-10-26.json')
      .readAsStringSync();

  group('lerBoletimOficial', () {
    test('lê a situação e o horário do boletim de 26/10/2026', () {
      final boletim = lerBoletimOficial(conteudo)!;

      expect(boletim.codigo, 'normalidade');
      expect(boletim.situacao, 'Normalidade');
      // 14:34:55 em Brasília (-03:00) = 17:34:55 UTC.
      expect(boletim.atualizadoEm, DateTime.utc(2026, 10, 26, 17, 34, 55));
    });

    test('o texto traz o aviso de maré da Defesa Civil', () {
      expect(lerBoletimOficial(conteudo)!.texto, contains('maré astronômica'));
    });

    // O portal separa as linhas com \r\n; a tela só precisa de \n.
    test('o texto não tem o caractere \\r', () {
      expect(lerBoletimOficial(conteudo)!.texto, isNot(contains('\r')));
    });

    test('sem boletim publicado ("data": null) → null', () {
      expect(lerBoletimOficial('{"data": null}'), isNull);
    });
  });
}
