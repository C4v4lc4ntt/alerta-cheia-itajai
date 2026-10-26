// =============================================================================
// leitor_tabua_mare_test.dart — RF01, ciclo 5 (parte a): tábua de marés.
//
// ETAPA VERMELHA: o leitor ainda não existe, então este teste nem compila.
// Fonte: /api/v1/tabuas-mare/atual do portal da Defesa Civil de Itajaí,
// salvo em 26/10/2026 19:15 (D10). A tábua em si é uma imagem: o app só
// guarda o endereço e o mês, nunca lê valores da imagem.
// =============================================================================
import 'dart:io';

import 'package:alerta_cheia_itajai/data/servicos/leitor_tabua_mare.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final conteudo = File('test/fixtures/tabua_mare_atual_2026-10-26.json')
      .readAsStringSync();

  group('lerTabuaMare', () {
    test('lê a tábua de outubro de 2026', () {
      final tabua = lerTabuaMare(conteudo)!;

      expect(tabua.mesReferencia, '2026-10');
      expect(tabua.doMesAtual, isTrue);
      expect(tabua.tipoArquivo, 'image/jpeg');
      expect(
        tabua.endereco,
        Uri.parse(
          'https://monitoramento.defesacivil.itajai.sc.gov.br'
          '/api/v1/tabuas-mare/5/arquivo?v=bbf55fb6ae42',
        ),
      );
    });

    // Ex.: no dia 1º, antes de a Defesa Civil publicar a tábua do mês.
    test('tábua de outro mês → doMesAtual falso', () {
      const json =
          '{"data": {"mes_referencia": "2026-09", '
          '"arquivo": {"url": "https://exemplo.com/t.jpeg", '
          '"mime_type": "image/jpeg"}, '
          '"corresponde_ao_mes_atual": false}}';

      expect(lerTabuaMare(json)!.doMesAtual, isFalse);
    });

    test('sem tábua publicada ("data": null) → null', () {
      expect(lerTabuaMare('{"data": null}'), isNull);
    });
  });
}
