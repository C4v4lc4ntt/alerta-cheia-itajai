// =============================================================================
// leitor_boletim_oficial.dart — lê o boletim de /api/v1/situacao-atual.
//
// ETAPA VERDE: código mínimo para os testes passarem (D10).
// =============================================================================
import 'dart:convert';

import '../../domain/models/boletim_oficial.dart';

/// Lê o [conteudo] de /api/v1/situacao-atual.
///
/// Devolve null se não houver boletim publicado. Lança [FormatException]
/// se o [conteudo] não for JSON.
BoletimOficial? lerBoletimOficial(String conteudo) {
  final json = jsonDecode(conteudo) as Map<String, dynamic>;
  final dados = json['data'] as Map<String, dynamic>?;
  if (dados == null) return null;

  return BoletimOficial(
    codigo: dados['codigo'] as String,
    situacao: dados['flag'] as String,
    // O portal separa as linhas com \r\n; a tela só precisa de \n.
    texto: (dados['conteudo'] as String).replaceAll('\r\n', '\n'),
    atualizadoEm: DateTime.parse(dados['atualizado_em'] as String),
  );
}
