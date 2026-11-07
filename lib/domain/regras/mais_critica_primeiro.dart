// =============================================================================
// mais_critica_primeiro.dart — ordem das estações da mais crítica para a
// menos crítica (RF01, usada também no RF02).
//
// REFATORAÇÃO: saiu do InicioViewModel porque a notificação também vai citar
// a estação mais crítica. A tela e o aviso precisam escolher a mesma.
// =============================================================================
import 'avaliar_leituras.dart';

/// Comparador para `sort`: maior estágio primeiro e, no empate, a estação
/// mais perto da cota de Atenção (em proporção).
int maisCriticaPrimeiro(SituacaoEstacao a, SituacaoEstacao b) {
  final porEstagio = b.estagio.index.compareTo(a.estagio.index);
  if (porEstagio != 0) return porEstagio;
  return _proporcaoDaCota(b).compareTo(_proporcaoDaCota(a));
}

// Quanto da cota de Atenção o nível já alcançou (1,0 = na cota).
double _proporcaoDaCota(SituacaoEstacao situacao) =>
    situacao.leitura.nivel / situacao.estacao.cotas.atencao;
