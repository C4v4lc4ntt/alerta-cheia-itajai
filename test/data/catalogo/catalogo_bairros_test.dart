// =============================================================================
// catalogo_bairros_test.dart — RF02 (D08): tabela pronta bairro → estações.
// A lista vem do Plano de Contingência de 22/12/2025 (p. 12), e a estimativa
// está explicada em docs/catalogo-bairros.md.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/catalogo_bairros.dart';
import 'package:alerta_cheia_itajai/data/catalogo/catalogo_estacoes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('catalogoBairros', () {
    test('tem os 43 nomes do Plano de Contingência', () {
      expect(catalogoBairros.length, 43);
    });

    test('nenhum nome se repete', () {
      final nomes = catalogoBairros.map((bairro) => bairro.nome).toSet();

      expect(nomes.length, catalogoBairros.length);
    });

    test('cada nome tem no máximo 2 estações', () {
      for (final bairro in catalogoBairros) {
        expect(
          bairro.estacoesProximas.length,
          lessThanOrEqualTo(2),
          reason: bairro.nome,
        );
      }
    });

    test('todas as estações existem no catálogo de estações', () {
      final codigos = catalogoEstacoes.map((estacao) => estacao.codigo).toSet();

      for (final bairro in catalogoBairros) {
        expect(
          codigos.containsAll(bairro.estacoesProximas),
          isTrue,
          reason: bairro.nome,
        );
      }
    });

    // Referências da Tabela 11 do Plano de Contingência (p. 23), que situa
    // estas estações nos locais abaixo. A de Volta de Cima segue o Plano,
    // embora o cálculo por distância colocasse a DC02 à frente.
    final referenciasDoPlano = {
      'Limoeiro': 'DC10',
      'Rio do Meio': 'DC08',
      'Santa Regina': 'DC11',
      'Volta de Cima': 'DC11',
      'Portal I e II': 'DC07',
    };

    referenciasDoPlano.forEach((nome, codigo) {
      test('$nome → primeira estação $codigo', () {
        final bairro = catalogoBairros.firstWhere((item) => item.nome == nome);

        expect(bairro.estacoesProximas.first, codigo);
      });
    });

    test('Murta → inclui a DC09 (Tabela 11 do Plano)', () {
      final bairro = catalogoBairros.firstWhere((item) => item.nome == 'Murta');

      expect(bairro.estacoesProximas, contains('DC09'));
    });
  });
}
