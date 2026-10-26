// =============================================================================
// boletim_servico_defesa_civil.dart — boletim e tábua reais, do portal.
//
// ETAPA VERDE: código mínimo para os testes passarem (D10).
// =============================================================================
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/boletim_oficial.dart';
import '../../domain/models/tabua_mare.dart';
import 'boletim_servico.dart';
import 'leitor_boletim_oficial.dart';
import 'leitor_tabua_mare.dart';
import 'nivel_rio_servico_defesa_civil.dart';

/// Serviço que busca o boletim e a tábua de marés no portal da Defesa Civil.
class BoletimServicoDefesaCivil implements BoletimServico {
  /// Cria o serviço com o [cliente] HTTP injetado (nos testes, MockClient).
  BoletimServicoDefesaCivil({required this.cliente});

  /// Cliente HTTP usado para falar com o portal.
  final http.Client cliente;

  static const _portal = 'https://monitoramento.defesacivil.itajai.sc.gov.br';

  @override
  Future<BoletimOficial?> buscarBoletim() async =>
      lerBoletimOficial(await _baixar('/api/v1/situacao-atual'));

  @override
  Future<TabuaMare?> buscarTabuaMare() async =>
      lerTabuaMare(await _baixar('/api/v1/tabuas-mare/atual'));

  // Mesmo cuidado do serviço de níveis: código HTTP e UTF-8 (D09).
  Future<String> _baixar(String caminho) async {
    final resposta = await cliente.get(Uri.parse('$_portal$caminho'));
    if (resposta.statusCode != 200) {
      throw PortalIndisponivel(resposta.statusCode);
    }
    return utf8.decode(resposta.bodyBytes);
  }
}
