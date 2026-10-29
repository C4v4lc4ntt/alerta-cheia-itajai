// =============================================================================
// portal_defesa_civil.dart — acesso ao portal da Defesa Civil de Itajaí.
//
// Extraído na refatoração do ciclo 5: os serviços de nível e de boletim
// baixavam do portal do mesmo jeito. Agora o cuidado com o código HTTP e
// com o UTF-8 (D09) fica num lugar só.
// =============================================================================
import 'dart:convert';

import 'package:http/http.dart' as http;

/// O portal respondeu com erro (por exemplo, fora do ar).
class PortalIndisponivel implements Exception {
  /// Cria o erro com o [codigoHttp] devolvido pelo portal.
  PortalIndisponivel(this.codigoHttp);

  /// Código HTTP da resposta (por exemplo, 503).
  final int codigoHttp;
}

/// Baixa arquivos do portal de monitoramento da Defesa Civil de Itajaí.
class PortalDefesaCivil {
  /// Cria o acesso ao portal com o [cliente] HTTP injetado.
  PortalDefesaCivil(this.cliente);

  /// Cliente HTTP usado para falar com o portal.
  final http.Client cliente;

  static const _endereco = 'https://monitoramento.defesacivil.itajai.sc.gov.br';

  /// Baixa o [caminho] do portal e devolve o texto em UTF-8.
  ///
  /// Lança [PortalIndisponivel] se o portal não responder com HTTP 200.
  Future<String> baixar(String caminho) async {
    final resposta = await cliente.get(Uri.parse('$_endereco$caminho'));
    if (resposta.statusCode != 200) {
      throw PortalIndisponivel(resposta.statusCode);
    }
    // O portal não informa o charset: decodificar como UTF-8 (D09).
    return utf8.decode(resposta.bodyBytes);
  }
}
