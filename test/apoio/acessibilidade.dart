// =============================================================================
// acessibilidade.dart — apoio dos testes de acessibilidade (passo 57, s05).
//
// Junta num lugar só as três regras da seção 7 do CLAUDE.md, para cada tela
// conferir as mesmas coisas, nos dois temas do app (claro e escuro):
// - alvos de toque de pelo menos 48 px;
// - todo alvo de toque com rótulo para o leitor de tela;
// - contraste de texto de pelo menos 4,5:1.
// =============================================================================
import 'package:alerta_cheia_itajai/core/tema/tema_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Os dois temas do app, pelo nome, para o teste rodar uma vez em cada um
/// (como um @ParameterizedTest do JUnit).
final temasDoApp = <String, ThemeData Function()>{
  'claro': TemaApp.claro,
  'escuro': TemaApp.escuro,
};

/// Confere as três regras na tela já montada.
///
/// Quem chama liga a árvore de semântica antes (`tester.ensureSemantics()`)
/// e a desliga no fim, como nos testes de acessibilidade que já existem.
Future<void> conferirAcessibilidade(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}
