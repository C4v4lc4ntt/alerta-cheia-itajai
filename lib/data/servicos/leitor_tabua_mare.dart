// =============================================================================
// leitor_tabua_mare.dart — lê os dados de /api/v1/tabuas-mare/atual.
//
// ETAPA VERDE: código mínimo para os testes passarem (D10).
// =============================================================================
import 'dart:convert';

import '../../domain/models/tabua_mare.dart';

/// Lê o [conteudo] de /api/v1/tabuas-mare/atual.
///
/// Devolve null se não houver tábua publicada. Lança [FormatException] se
/// o [conteudo] não for JSON.
TabuaMare? lerTabuaMare(String conteudo) {
  final json = jsonDecode(conteudo) as Map<String, dynamic>;
  final dados = json['data'] as Map<String, dynamic>?;
  if (dados == null) return null;
  final arquivo = dados['arquivo'] as Map<String, dynamic>;

  return TabuaMare(
    mesReferencia: dados['mes_referencia'] as String,
    endereco: Uri.parse(arquivo['url'] as String),
    tipoArquivo: arquivo['mime_type'] as String,
    doMesAtual: dados['corresponde_ao_mes_atual'] as bool,
  );
}
