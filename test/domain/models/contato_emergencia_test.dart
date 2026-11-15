// =============================================================================
// contato_emergencia_test.dart — RF05 (D20): contato de emergência que o
// morador liga com um toque na aba Ajuda.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// Dados reais: página "Telefones de emergência" do portal da Defesa Civil de
// Itajaí, acesso em 15/11/2026.
// =============================================================================
import 'package:alerta_cheia_itajai/domain/models/contato_emergencia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContatoEmergencia', () {
    // Um nome em branco apareceria como um botão sem rótulo na aba Ajuda.
    test('nome só com espaços → ArgumentError', () {
      expect(
        () => ContatoEmergencia(
          nome: '   ',
          numero: '199',
          descricao: 'Riscos, alagamentos e deslizamentos.',
        ),
        throwsArgumentError,
      );
    });

    // O número vai direto no "tel:" do discador, então só pode ter dígitos.
    // Tabela de casos, como um @ParameterizedTest do JUnit.
    const numerosInvalidos = {
      'vazio': '',
      'com letra': '19A',
      'com símbolos e espaço': '(47) 3228-7700',
    };
    numerosInvalidos.forEach((caso, numero) {
      test('número $caso ("$numero") → ArgumentError', () {
        expect(
          () => ContatoEmergencia(
            nome: 'Defesa Civil',
            numero: numero,
            descricao: 'Riscos, alagamentos e deslizamentos.',
          ),
          throwsArgumentError,
        );
      });
    });

    test('contato válido (Defesa Civil, 199) guarda os dados', () {
      // Arrange e Act: dados reais da página da Defesa Civil (15/11/2026).
      final contato = ContatoEmergencia(
        nome: 'Defesa Civil',
        numero: '199',
        descricao:
            'Riscos, alagamentos, deslizamentos e emergências do município.',
      );

      // Assert
      expect(contato.nome, 'Defesa Civil');
      expect(contato.numero, '199');
      expect(
        contato.descricao,
        'Riscos, alagamentos, deslizamentos e emergências do município.',
      );
    });
  });
}
