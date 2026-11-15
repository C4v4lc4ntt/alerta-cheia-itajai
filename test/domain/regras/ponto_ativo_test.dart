// =============================================================================
// ponto_ativo_test.dart — RF04 (D06 e adendo de 15/11/2026): o ponto de
// alagamento fica no mapa até 6 h depois de criado.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// Teste planejado na Etapa 1 (Tabela 5): um ponto com mais de 6 horas deixa
// de aparecer no mapa. O adendo da D06 fixou o limite: a partir de 6 h o
// ponto fica inativo, como nas cotas (D02: atingir o limite já conta).
// Ciclo 2: com 3 "Já baixou" o ponto fica inativo mesmo dentro das 6 h.
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/area_itajai.dart';
import 'package:alerta_cheia_itajai/domain/models/altura_agua.dart';
import 'package:alerta_cheia_itajai/domain/models/ponto_alagamento.dart';
import 'package:alerta_cheia_itajai/domain/regras/ponto_ativo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Arrange comum: ponto criado num horário fixo (relógio injetado),
  // perto do Centro, dentro da área de Itajaí.
  final criadoEm = DateTime.utc(2026, 11, 15, 10);
  final ponto = PontoAlagamento.registrar(
    latitude: -26.9078,
    longitude: -48.6616,
    altura: AlturaAgua.joelho,
    area: areaItajai,
    agora: () => criadoEm,
  );

  // Tabela de casos (como o @ParameterizedTest do JUnit): tempo desde a
  // criação → se o ponto ainda deve aparecer. Valores-limite em volta das 6 h.
  final casos = <Duration, bool>{
    Duration.zero: true,
    const Duration(hours: 5, minutes: 59, seconds: 59): true,
    const Duration(hours: 6): false,
    const Duration(hours: 6, seconds: 1): false,
  };

  casos.forEach((tempoDesdeCriacao, esperado) {
    test('ponto criado há $tempoDesdeCriacao → ativo: $esperado', () {
      // Act
      final ativo = pontoAtivo(
        ponto: ponto,
        agora: criadoEm.add(tempoDesdeCriacao),
      );

      // Assert
      expect(ativo, esperado);
    });
  });

  // Ciclo 2 (RF04, D06): com 3 "Já baixou" o ponto sai do mapa mesmo
  // dentro das 6 h. Valores-limite em volta de 3: 2, 3 e 4.
  group('"Já baixou" dentro do prazo', () {
    // Uma hora depois da criação, longe do limite das 6 h, para o
    // resultado depender só da contagem.
    final umaHoraDepois = criadoEm.add(const Duration(hours: 1));

    // Tabela de casos: quantos "Já baixou" → se o ponto continua ativo.
    final casosJaBaixou = <int, bool>{2: true, 3: false, 4: false};

    casosJaBaixou.forEach((jaBaixou, esperado) {
      test('$jaBaixou "Já baixou" → ativo: $esperado', () {
        // Arrange
        final pontoConfirmado = PontoAlagamento.registrar(
          latitude: -26.9078,
          longitude: -48.6616,
          altura: AlturaAgua.joelho,
          area: areaItajai,
          agora: () => criadoEm,
          jaBaixou: jaBaixou,
        );

        // Act
        final ativo = pontoAtivo(ponto: pontoConfirmado, agora: umaHoraDepois);

        // Assert
        expect(ativo, esperado);
      });
    });
  });
}
