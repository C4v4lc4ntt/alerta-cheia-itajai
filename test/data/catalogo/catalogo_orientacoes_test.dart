// =============================================================================
// catalogo_orientacoes_test.dart — RF06 (D20): orientações da aba Ajuda.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// Fontes, com o texto fiel: Antes, Durante e Depois da página "Como agir em
// enchentes" do portal da Defesa Civil de Itajaí; Veículos e ruas alagadas da
// "Cartilha de Prevenção" do site do Ministério das Cidades (gov.br), sem
// título, autor ou ano no documento. Ambas lidas em 15/11/2026.
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/catalogo_orientacoes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('catalogoOrientacoes', () {
    test('tem as 4 seções na ordem', () {
      expect(catalogoOrientacoes.keys.toList(), [
        'Antes',
        'Durante',
        'Depois',
        'Veículos e ruas alagadas',
      ]);
    });

    // Tabela de casos: seção → quantos itens ela tem na fonte.
    const quantidades = {
      'Antes': 6,
      'Durante': 4,
      'Depois': 4,
      'Veículos e ruas alagadas': 6,
    };
    quantidades.forEach((secao, quantidade) {
      test('$secao tem $quantidade itens', () {
        expect(catalogoOrientacoes[secao], hasLength(quantidade));
      });
    });

    // Tabela de casos: um item real de cada seção, com o texto da fonte.
    const exemplos = {
      'Antes': 'Não deixe animais de estimação acorrentados.',
      'Durante': 'Desligue a energia e o gás se precisar deixar o imóvel.',
      'Depois': 'Limpe e desinfete a caixa-d’água antes de voltar a usá-la.',
      'Veículos e ruas alagadas': 'Se o carro enguiçar, abandone-o.',
    };
    exemplos.forEach((secao, item) {
      test('$secao inclui "$item"', () {
        expect(catalogoOrientacoes[secao], contains(item));
      });
    });

    test('nenhum item está em branco', () {
      for (final itens in catalogoOrientacoes.values) {
        for (final item in itens) {
          expect(item.trim(), isNotEmpty);
        }
      }
    });
  });
}
