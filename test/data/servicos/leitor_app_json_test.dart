// =============================================================================
// leitor_app_json_test.dart — RF01, ciclo 4b (parte a): ler o app.json.
//
// ETAPA VERMELHA: o leitor ainda não existe, então este teste nem compila.
// Fonte: recorte do app.json do portal da Defesa Civil de Itajaí, gerado em
// 26/10/2026 21:42 UTC — só a lista dados.rios, sem as séries de 12 h (D07).
// O teste lê a cópia salva: nunca acessa a internet.
// =============================================================================
import 'dart:io';

import 'package:alerta_cheia_itajai/data/catalogo/catalogo_estacoes.dart';
import 'package:alerta_cheia_itajai/data/servicos/leitor_app_json.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final conteudo = File('test/fixtures/app_json_2026-10-26_rios.json')
      .readAsStringSync();

  group('lerLeiturasDoAppJson', () {
    // O portal também traz Rio do Sul, Brusque e Blumenau.
    test('lê só as 11 estações de Itajaí', () {
      final leituras = lerLeiturasDoAppJson(conteudo);

      expect(
        leituras.map((l) => l.codigoEstacao),
        unorderedEquals(catalogoEstacoes.map((e) => e.codigo)),
      );
    });

    test('DC01: nível 0,80 m medido às 21:31:36 UTC', () {
      final dc01 = lerLeiturasDoAppJson(conteudo)
          .firstWhere((l) => l.codigoEstacao == 'DC01');

      expect(dc01.nivel, 0.80);
      expect(dc01.medidoEm, DateTime.utc(2026, 10, 26, 21, 31, 36, 62));
    });

    // Sensor sem leitura não pode derrubar as outras estações.
    test('ignora estação sem nível', () {
      const json =
          '{"dados": {"rios": [{"codigo": "DC01", '
          '"municipio": "Itajaí", '
          '"medido_em": "2026-10-26T21:31:36+00:00", '
          '"nivel_rio_m": null}]}}';

      expect(lerLeiturasDoAppJson(json), isEmpty);
    });

    // Se o portal devolver uma página de erro em vez do JSON.
    test('conteúdo que não é JSON → FormatException', () {
      expect(
        () => lerLeiturasDoAppJson('<html>erro</html>'),
        throwsFormatException,
      );
    });
  });
}
