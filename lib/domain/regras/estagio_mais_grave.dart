// =============================================================================
// estagio_mais_grave.dart — regra do RF01/D02: entre vários estágios, devolve
// o mais grave. Usada para a cidade (todas as estações) e, no RF02, para o
// bairro (só as estações ligadas a ele).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// =============================================================================
import '../models/estagio_alerta.dart';

/// Devolve o estágio mais grave entre os [estagios] informados.
///
/// Lança [ArgumentError] se a lista estiver vazia, porque sem leituras
/// não dá para afirmar estágio nenhum.
EstagioAlerta estagioMaisGrave(List<EstagioAlerta> estagios) {
  // Proteção: lista vazia é erro, nunca "Monitoramento" por padrão.
  if (estagios.isEmpty) {
    throw ArgumentError(
      'A lista de estágios está vazia: sem leituras não há estágio.',
    );
  }

  // "index" é a posição do valor na declaração do enum:
  // monitoramento = 0, atencao = 1, alerta = 2, emergencia = 3.
  // "reduce" compara os itens dois a dois e fica com o de maior índice,
  // igual ao stream().reduce(...) do Java.
  return estagios.reduce((a, b) => a.index >= b.index ? a : b);
}
