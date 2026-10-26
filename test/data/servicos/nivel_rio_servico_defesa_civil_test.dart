// =============================================================================
// nivel_rio_servico_defesa_civil_test.dart — RF01, ciclo 4b (parte b):
// baixar o app.json do portal da Defesa Civil.
//
// ETAPA VERMELHA: o serviço ainda não existe, então este teste nem compila.
// O MockClient (pacote http, D09) finge o portal: nenhum teste acessa a
// internet. A resposta imita a do portal em 26/10/2026: "application/json"
// SEM charset.
// =============================================================================
import 'dart:convert';
import 'dart:io';

import 'package:alerta_cheia_itajai/data/servicos/nivel_rio_servico.dart';
import 'package:alerta_cheia_itajai/data/servicos/nivel_rio_servico_defesa_civil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final appJson = File('test/fixtures/app_json_2026-10-26_rios.json')
      .readAsStringSync();

  // Resposta com o mesmo cabeçalho que o portal manda.
  http.Response respostaDoPortal(String corpo, int status) =>
      http.Response.bytes(
        utf8.encode(corpo),
        status,
        headers: {'content-type': 'application/json'},
      );

  group('NivelRioServicoDefesaCivil', () {
    test('busca o app.json no endereço do portal', () async {
      Uri? enderecoPedido;
      final NivelRioServico servico = NivelRioServicoDefesaCivil(
        cliente: MockClient((pedido) async {
          enderecoPedido = pedido.url;
          return respostaDoPortal(appJson, 200);
        }),
      );

      await servico.buscarLeituras();

      expect(
        enderecoPedido,
        Uri.parse(
          'https://monitoramento.defesacivil.itajai.sc.gov.br'
          '/data/current/app.json',
        ),
      );
    });

    // Se o corpo for lido como Latin-1, "Itajaí" vira "ItajaÃ­", o filtro de
    // cidade falha e a lista volta vazia.
    test('devolve as 11 leituras de Itajaí (acentos em UTF-8)', () async {
      final servico = NivelRioServicoDefesaCivil(
        cliente: MockClient((_) async => respostaDoPortal(appJson, 200)),
      );

      final leituras = await servico.buscarLeituras();

      expect(leituras, hasLength(11));
    });

    test('portal com falha (HTTP 503) → PortalIndisponivel', () async {
      final servico = NivelRioServicoDefesaCivil(
        cliente: MockClient((_) async => respostaDoPortal('erro', 503)),
      );

      await expectLater(
        servico.buscarLeituras(),
        throwsA(isA<PortalIndisponivel>()),
      );
    });
  });
}
