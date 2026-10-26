// =============================================================================
// nivel_rio_servico_defesa_civil.dart — níveis reais, do portal (D07).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Baixa o app.json público do portal da Defesa Civil de Itajaí com o pacote
// http (D09) e usa o leitor do ciclo 4b (parte a) para criar as leituras.
// =============================================================================
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/leitura_nivel.dart';
import 'leitor_app_json.dart';
import 'nivel_rio_servico.dart';

/// O portal respondeu com erro (por exemplo, fora do ar).
class PortalIndisponivel implements Exception {
  /// Cria o erro com o [codigoHttp] devolvido pelo portal.
  PortalIndisponivel(this.codigoHttp);

  /// Código HTTP da resposta (por exemplo, 503).
  final int codigoHttp;
}

/// Serviço de nível que busca os dados reais no portal da Defesa Civil.
class NivelRioServicoDefesaCivil implements NivelRioServico {
  /// Cria o serviço com o [cliente] HTTP injetado (nos testes, MockClient).
  NivelRioServicoDefesaCivil({required this.cliente});

  static final _endereco = Uri.parse(
    'https://monitoramento.defesacivil.itajai.sc.gov.br'
    '/data/current/app.json',
  );

  /// Cliente HTTP usado para falar com o portal.
  final http.Client cliente;

  @override
  Future<List<LeituraNivel>> buscarLeituras() async {
    final resposta = await cliente.get(_endereco);
    if (resposta.statusCode != 200) {
      throw PortalIndisponivel(resposta.statusCode);
    }
    // O portal não informa o charset: decodificar como UTF-8 (D09).
    return lerLeiturasDoAppJson(utf8.decode(resposta.bodyBytes));
  }
}
