// =============================================================================
// situacao_do_bairro.dart — regra do RF02 (D08): o bairro mostra o estágio da
// cidade e, como complemento, as estações próximas com o estágio de cada uma.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// =============================================================================
import '../models/bairro.dart';
import '../models/estagio_alerta.dart';
import 'estagio_mais_grave.dart';

/// Estação próxima do bairro, com o estágio atual dela.
typedef EstacaoProxima = ({String codigo, EstagioAlerta estagio});

/// O que a tela mostra sobre um bairro.
typedef SituacaoBairro = ({
  EstagioAlerta estagio,
  List<EstacaoProxima> estacoesProximas,
});

/// Monta a situação do [bairro] a partir do estágio de cada estação da cidade.
///
/// O estágio é sempre o mais grave entre TODAS as estações (D02 e D08), então
/// a estimativa nunca reduz o alerta. Lança [ArgumentError] se
/// [estagiosPorEstacao] estiver vazio, porque sem leituras não há estágio.
SituacaoBairro situacaoDoBairro({
  required Bairro bairro,
  required Map<String, EstagioAlerta> estagiosPorEstacao,
}) {
  return (
    estagio: estagioMaisGrave(estagiosPorEstacao.values.toList()),
    estacoesProximas: [
      // "case final estagio?" só entra quando a estação tem leitura.
      for (final codigo in bairro.estacoesProximas)
        if (estagiosPorEstacao[codigo] case final estagio?)
          (codigo: codigo, estagio: estagio),
    ],
  );
}
