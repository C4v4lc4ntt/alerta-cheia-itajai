// =============================================================================
// ponto_firestore_test.dart — RF03 (D17): conversão do ponto de alagamento
// para o documento do Firestore e de volta.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// Sem rede e sem iniciar o Firebase: FieldValue e Timestamp são objetos comuns.
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/area_itajai.dart';
import 'package:alerta_cheia_itajai/data/servicos/ponto_firestore.dart';
import 'package:alerta_cheia_itajai/domain/models/altura_agua.dart';
import 'package:alerta_cheia_itajai/domain/models/ponto_alagamento.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final momento = DateTime.utc(2026, 11, 9, 23, 15);

  // Ponto qualquer dentro do retângulo, perto do Centro.
  const latitude = -26.9078;
  const longitude = -48.6616;

  group('pontoParaFirestore', () {
    final ponto = PontoAlagamento.registrar(
      latitude: latitude,
      longitude: longitude,
      altura: AlturaAgua.joelho,
      area: areaItajai,
      agora: () => momento,
    );

    test('grava a posição e a altura pelo nome', () {
      final mapa = pontoParaFirestore(ponto);

      expect(mapa['latitude'], latitude);
      expect(mapa['longitude'], longitude);
      expect(mapa['altura'], 'joelho');
    });

    // As regras exigem criadoEm == request.time: a hora do celular seria
    // recusada (D17).
    test('criadoEm vai como horário do servidor, não do celular', () {
      expect(
        pontoParaFirestore(ponto)['criadoEm'],
        FieldValue.serverTimestamp(),
      );
    });

    // As regras recusam campo a mais (D17).
    test('só os 4 campos da D17', () {
      expect(
        pontoParaFirestore(ponto).keys,
        unorderedEquals(['latitude', 'longitude', 'altura', 'criadoEm']),
      );
    });
  });

  group('pontoDoFirestore', () {
    // Documento como o Firestore devolve depois de gravar.
    Map<String, dynamic> documento() => {
      'latitude': latitude,
      'longitude': longitude,
      'altura': 'cintura',
      'criadoEm': Timestamp.fromDate(momento),
    };

    test('documento válido → ponto com o horário do servidor em UTC', () {
      // Act
      final ponto = pontoDoFirestore(documento(), area: areaItajai);

      // Assert
      expect(ponto, isNotNull);
      expect(ponto!.latitude, latitude);
      expect(ponto.longitude, longitude);
      expect(ponto.altura, AlturaAgua.cintura);
      expect(ponto.criadoEm, momento);
    });

    final invalidos = <String, Map<String, dynamic>>{
      'sem latitude → ignorado': {...documento()}..remove('latitude'),
      'altura inventada → ignorado': {...documento(), 'altura': 'tornozelo'},
      // A própria marcação chega assim até o servidor confirmar o horário.
      'criadoEm ainda vazio → ignorado': {...documento(), 'criadoEm': null},
      'fora da área → ignorado': {...documento(), 'longitude': -49.0},
      'latitude como texto → ignorado': {...documento(), 'latitude': '-26.9'},
    };

    invalidos.forEach((nome, dados) {
      test(nome, () {
        expect(pontoDoFirestore(dados, area: areaItajai), isNull);
      });
    });
  });
}
