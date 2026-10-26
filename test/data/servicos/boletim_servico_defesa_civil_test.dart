// =============================================================================
// boletim_servico_defesa_civil_test.dart — RF01, ciclo 5 (parte b): baixar o
// boletim oficial e a tábua de marés do portal da Defesa Civil.
//
// ETAPA VERMELHA: o serviço ainda não existe, então este teste nem compila.
// O MockClient faz o papel do portal, respondendo com as cópias salvas em
// 26/10/2026 (D10): nenhum teste acessa a internet.
// =============================================================================
import 'dart:convert';
import 'dart:io';

import 'package:alerta_cheia_itajai/data/servicos/boletim_servico.dart';
import 'package:alerta_cheia_itajai/data/servicos/boletim_servico_defesa_civil.dart';
import 'package:alerta_cheia_itajai/data/servicos/nivel_rio_servico_defesa_civil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final situacao = File('test/fixtures/situacao_atual_2026-10-26.json')
      .readAsStringSync();
  final tabua = File('test/fixtures/tabua_mare_atual_2026-10-26.json')
      .readAsStringSync();

  // Resposta com o mesmo cabeçalho que o portal manda (sem charset).
  http.Response respostaDoPortal(String corpo, int status) =>
      http.Response.bytes(
        utf8.encode(corpo),
        status,
        headers: {'content-type': 'application/json'},
      );

  // Portal falso: cada endereço devolve a sua cópia; o resto, 404.
  MockClient portalFalso() => MockClient(
    (pedido) async => switch (pedido.url.path) {
      '/api/v1/situacao-atual' => respostaDoPortal(situacao, 200),
      '/api/v1/tabuas-mare/atual' => respostaDoPortal(tabua, 200),
      _ => respostaDoPortal('não encontrado', 404),
    },
  );

  group('BoletimServicoDefesaCivil', () {
    test('busca o boletim oficial (acentos em UTF-8)', () async {
      final BoletimServico servico = BoletimServicoDefesaCivil(
        cliente: portalFalso(),
      );

      final boletim = await servico.buscarBoletim();

      expect(boletim!.situacao, 'Normalidade');
      expect(boletim.texto, contains('maré astronômica'));
    });

    test('busca a tábua de marés do mês', () async {
      final servico = BoletimServicoDefesaCivil(cliente: portalFalso());

      final tabuaMare = await servico.buscarTabuaMare();

      expect(tabuaMare!.mesReferencia, '2026-10');
    });

    test('portal com falha (HTTP 503) → PortalIndisponivel', () async {
      final servico = BoletimServicoDefesaCivil(
        cliente: MockClient((_) async => respostaDoPortal('erro', 503)),
      );

      await expectLater(
        servico.buscarBoletim(),
        throwsA(isA<PortalIndisponivel>()),
      );
    });
  });
}
