// =============================================================================
// ponto_ativo.dart — regra do RF04 (D06 e adendo de 15/11/2026): o ponto de
// alagamento fica no mapa até 6 h depois de criado.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// A partir de 6 h o ponto fica inativo, como nas cotas (D02: atingir o
// limite já conta). A regra dos 3 "Já baixou" entra no ciclo 2.
// =============================================================================
import '../models/ponto_alagamento.dart';

/// Tempo que um ponto fica no mapa depois de criado (D06).
const prazoDoPonto = Duration(hours: 6);

/// Diz se o [ponto] ainda deve aparecer no mapa no momento [agora].
///
/// O [agora] vem de fora (relógio injetado), para os testes não
/// dependerem da hora real.
bool pontoAtivo({required PontoAlagamento ponto, required DateTime agora}) {
  // "difference" devolve o tempo entre as duas datas, como o
  // Duration.between(criadoEm, agora) do Java.
  final tempoDesdeCriacao = agora.difference(ponto.criadoEm);
  return tempoDesdeCriacao < prazoDoPonto;
}
