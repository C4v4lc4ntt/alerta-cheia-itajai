// =============================================================================
// classificador_estagio.dart — regra do RF01: nível do rio → estágio.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// =============================================================================
import '../models/cotas_estacao.dart';
import '../models/estagio_alerta.dart';

/// Devolve o estágio de alerta para um [nivel] (em metros) medido numa
/// estação com as [cotas] informadas.
EstagioAlerta classificarEstagio(double nivel, CotasEstacao cotas) {
  // Testa do mais grave para o menos grave; o primeiro que "bater" vence.
  // ">=" porque ATINGIR a cota já muda o estágio.
  if (nivel >= cotas.emergencia) return EstagioAlerta.emergencia;
  if (nivel >= cotas.alerta) return EstagioAlerta.alerta;
  if (nivel >= cotas.atencao) return EstagioAlerta.atencao;
  return EstagioAlerta.monitoramento;
}
