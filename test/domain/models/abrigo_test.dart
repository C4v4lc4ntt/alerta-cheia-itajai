// =============================================================================
// abrigo_test.dart — RF05 (D20): abrigo da Defesa Civil listado na aba Ajuda.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// Dados reais: camada abrigos_itajai_final_2026 do geoportal da Prefeitura
// (painel "Abrigos de Itajaí"), lida em 15/11/2026.
// =============================================================================
import 'package:alerta_cheia_itajai/domain/models/abrigo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Abrigo', () {
    // Um nome em branco apareceria como uma linha vazia na lista.
    test('nome só com espaços → ArgumentError', () {
      expect(
        () => Abrigo(nome: '   ', endereco: 'R. Odílio Garcia, 445, Cordeiros'),
        throwsArgumentError,
      );
    });

    // Sem endereço o morador não sabe para onde ir.
    test('endereço só com espaços → ArgumentError', () {
      expect(
        () => Abrigo(nome: 'Paróquia São Cristóvão', endereco: '   '),
        throwsArgumentError,
      );
    });

    // O telefone vai no "tel:" com DDD (D20): 10 dígitos (fixo) ou 11
    // (celular). Valores-limite: 9 e 12 dígitos ficam de fora.
    const telefonesInvalidos = {
      '9 dígitos': '473341140',
      '12 dígitos': '473341140800',
      'com hífen': '3341-1408',
      'vazio': '',
    };
    telefonesInvalidos.forEach((caso, telefone) {
      test('telefone $caso ("$telefone") → ArgumentError', () {
        expect(
          () => Abrigo(
            nome: 'Paróquia São Cristóvão',
            endereco: 'R. Odílio Garcia, 445, Cordeiros',
            telefone: telefone,
          ),
          throwsArgumentError,
        );
      });
    });

    test('telefone fixo com DDD (10 dígitos) é aceito', () {
      final abrigo = Abrigo(
        nome: 'Paróquia São Cristóvão',
        endereco: 'R. Odílio Garcia, 445, Cordeiros',
        telefone: '4733411408',
      );

      expect(abrigo.telefone, '4733411408');
    });

    test('celular com DDD (11 dígitos) é aceito', () {
      final abrigo = Abrigo(
        nome: 'Igreja Reviver',
        endereco: 'Rua Benjamin Franklin Pereira, 458 - São João',
        telefone: '47996951115',
      );

      expect(abrigo.telefone, '47996951115');
    });

    // Vários abrigos da fonte não têm telefone.
    test('sem telefone é aceito e guarda nome e endereço', () {
      final abrigo = Abrigo(
        nome: 'Capela Santo Antônio',
        endereco: 'R. Fermino Vieira Cordeiro, 915, Espinheiros',
      );

      expect(abrigo.nome, 'Capela Santo Antônio');
      expect(abrigo.endereco, 'R. Fermino Vieira Cordeiro, 915, Espinheiros');
      expect(abrigo.telefone, isNull);
    });
  });
}
