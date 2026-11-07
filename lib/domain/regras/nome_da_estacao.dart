// =============================================================================
// nome_da_estacao.dart — nome completo de uma estação (D16).
//
// REFATORAÇÃO: saiu de ui/comum/formatos.dart porque a notificação, que não é
// tela, também vai citar a estação. Assim o formato fica num lugar só.
// =============================================================================
import '../models/estacao.dart';

/// Código, nome e rio: "DC07 · Portal · Ribeirão da Murta" (D16).
String nomeDaEstacao(Estacao estacao) =>
    '${estacao.codigo} · ${estacao.nome} · ${estacao.rio}';
