// =============================================================================
// boletim_servico.dart — contrato de quem fornece o boletim e a tábua.
//
// ETAPA VERDE: código mínimo para os testes passarem (D10).
// =============================================================================
import '../../domain/models/boletim_oficial.dart';
import '../../domain/models/tabua_mare.dart';

/// Fonte das informações oficiais publicadas pela Defesa Civil.
abstract interface class BoletimServico {
  /// Busca o boletim mais recente (null se não houver).
  Future<BoletimOficial?> buscarBoletim();

  /// Busca a tábua de marés do mês (null se não houver).
  Future<TabuaMare?> buscarTabuaMare();
}
