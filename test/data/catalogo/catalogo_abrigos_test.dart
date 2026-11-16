// =============================================================================
// catalogo_abrigos_test.dart — RF05 (D20): abrigos da aba Ajuda.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// Fonte dos valores: camada abrigos_itajai_final_2026 do geoportal da
// Prefeitura (painel "Abrigos de Itajaí"), lida em 15/11/2026, com as
// escolhas da D20 (3 códigos fora, animais à parte, digitação corrigida,
// DDD 47 acrescentado).
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/catalogo_abrigos.dart';
import 'package:alerta_cheia_itajai/domain/models/abrigo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Todos os abrigos (pessoas e animais), para os testes que olham o conjunto.
  final todos = <Abrigo>[
    ...catalogoAbrigos.values.expand((lista) => lista),
    ...catalogoAbrigosAnimais,
  ];

  group('catalogoAbrigos', () {
    test('tem as 5 regiões (CRAS) na ordem da fonte', () {
      expect(catalogoAbrigos.keys.toList(), [
        'CRAS Espinheiros',
        'CRAS Imaruí',
        'CRAS Itaipava',
        'CRAS Nossa Senhora das Graças',
        'CRAS Promorar',
      ]);
    });

    test('tem 32 abrigos de pessoas no total', () {
      final total = catalogoAbrigos.values.fold<int>(
        0,
        (soma, lista) => soma + lista.length,
      );

      expect(total, 32);
    });

    // Tabela de casos: região → quantos abrigos ela tem na fonte.
    const porRegiao = {
      'CRAS Espinheiros': 2,
      'CRAS Imaruí': 8,
      'CRAS Itaipava': 5,
      'CRAS Nossa Senhora das Graças': 12,
      'CRAS Promorar': 5,
    };
    porRegiao.forEach((regiao, quantidade) {
      test('$regiao tem $quantidade abrigos', () {
        expect(catalogoAbrigos[regiao], hasLength(quantidade));
      });
    });

    // Ordem de prioridade de abertura da fonte, sem o "1." no nome.
    test('a prioridade do CRAS Imaruí começa pela Paróquia São Cristóvão', () {
      expect(
        catalogoAbrigos['CRAS Imaruí']!.first.nome,
        'Paróquia São Cristóvão',
      );
    });
  });

  group('catalogoAbrigosAnimais', () {
    test('tem os 2 abrigos de animais da fonte', () {
      expect(catalogoAbrigosAnimais, hasLength(2));
    });
  });

  group('escolhas da D20', () {
    test('os erros de digitação da fonte estão corrigidos', () {
      for (final abrigo in todos) {
        expect(abrigo.endereco, isNot(contains('Cordieros')));
        expect(abrigo.endereco, isNot(contains('Alferedo')));
        expect(abrigo.endereco, isNot(contains(', fazenda')));
      }
    });

    // Os códigos x1 AA, x2 E e x3 CA ficam nesse endereço e não são abrigos.
    test('nenhum abrigo no endereço da Defesa Civil (Adolfo Konder, 1811)', () {
      for (final abrigo in todos) {
        expect(abrigo.endereco, isNot(contains('Adolfo Konder, 1811')));
      }
    });

    // Tabela de casos: abrigo → telefone só com dígitos e DDD 47.
    const telefones = {
      'Paróquia São Cristóvão': '4733411408', // fonte: 3341-1408
      'Clube Tiradentes': '47984020009', // fonte: 47 98402-0009
    };
    telefones.forEach((nome, telefone) {
      test('$nome tem o telefone $telefone', () {
        final abrigo = todos.firstWhere((a) => a.nome == nome);

        expect(abrigo.telefone, telefone);
      });
    });
  });
}
