// =============================================================================
// tabua_mare.dart — a tábua de marés do mês, publicada pela Defesa Civil.
//
// ETAPA VERDE: código mínimo para os testes passarem (D10).
// A tábua é um arquivo (imagem ou PDF): o app só guarda onde ela está.
// =============================================================================

/// Tábua de marés mensal de Itajaí.
class TabuaMare {
  /// Cria a tábua com os dados do portal.
  TabuaMare({
    required this.mesReferencia,
    required this.endereco,
    required this.tipoArquivo,
    required this.doMesAtual,
  });

  /// Mês da tábua, no formato "AAAA-MM" (ex.: "2026-10").
  final String mesReferencia;

  /// Endereço do arquivo da tábua no portal.
  final Uri endereco;

  /// Tipo do arquivo (ex.: "image/jpeg" ou "application/pdf").
  final String tipoArquivo;

  /// Falso quando a tábua do mês atual ainda não foi publicada.
  final bool doMesAtual;
}
