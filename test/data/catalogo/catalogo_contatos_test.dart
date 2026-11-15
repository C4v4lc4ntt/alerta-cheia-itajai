// =============================================================================
// catalogo_contatos_test.dart — RF05 (D20): contatos de emergência da aba
// Ajuda.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// Fonte dos valores: página "Telefones de emergência" do portal da Defesa
// Civil de Itajaí, acesso em 15/11/2026.
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/catalogo_contatos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('catalogoContatos', () {
    // Ordem do RF05 e da página da Defesa Civil.
    test('tem Defesa Civil 199, Corpo de Bombeiros 193 e SAMU 192', () {
      final contatos = catalogoContatos
          .map((c) => '${c.nome} ${c.numero}')
          .toList();

      expect(contatos, [
        'Defesa Civil 199',
        'Corpo de Bombeiros 193',
        'SAMU 192',
      ]);
    });

    test('os números não se repetem', () {
      final numeros = catalogoContatos.map((c) => c.numero).toSet();

      expect(numeros, hasLength(catalogoContatos.length));
    });

    // Tabela de casos: número → descrição como está na fonte.
    const descricoes = {
      '199': 'Riscos, alagamentos, deslizamentos e emergências do município.',
      '193': 'Incêndios, salvamentos, acidentes e situações com risco à vida.',
      '192': 'Urgências e emergências médicas.',
    };
    descricoes.forEach((numero, descricao) {
      test('$numero tem a descrição da página da Defesa Civil', () {
        final contato = catalogoContatos.firstWhere((c) => c.numero == numero);

        expect(contato.descricao, descricao);
      });
    });
  });
}
