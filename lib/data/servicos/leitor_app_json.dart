// =============================================================================
// leitor_app_json.dart — transforma o app.json do portal em leituras.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Formato do portal (D07): dados.rios é uma lista; cada item tem codigo,
// municipio, medido_em (ISO 8601, UTC) e nivel_rio_m (metros).
// =============================================================================
import 'dart:convert';

import '../../domain/models/leitura_nivel.dart';

/// Lê o [conteudo] do app.json e devolve as leituras das estações de Itajaí.
///
/// Estações sem nível são ignoradas. Lança [FormatException] se o
/// [conteudo] não for JSON.
List<LeituraNivel> lerLeiturasDoAppJson(String conteudo) {
  final json = jsonDecode(conteudo) as Map<String, dynamic>;
  final dados = json['dados'] as Map<String, dynamic>;
  final rios = dados['rios'] as List<dynamic>;

  return [
    for (final rio in rios.cast<Map<String, dynamic>>())
      if (rio['municipio'] == 'Itajaí' && rio['nivel_rio_m'] != null)
        LeituraNivel(
          codigoEstacao: rio['codigo'] as String,
          // "num" porque o JSON pode trazer 3 (inteiro) em vez de 3.0.
          nivel: (rio['nivel_rio_m'] as num).toDouble(),
          medidoEm: DateTime.parse(rio['medido_em'] as String),
        ),
  ];
}
