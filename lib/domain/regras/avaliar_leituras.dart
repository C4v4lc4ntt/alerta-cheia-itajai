// =============================================================================
// avaliar_leituras.dart — regra do RF01 usada também no RF02: junta cada
// leitura à estação dela e calcula o estágio.
//
// REFATORAÇÃO: o cálculo estava repetido no InicioViewModel e no
// VerificadorEstagio. Agora a tela e a notificação usam o mesmo código.
// =============================================================================
import '../models/estacao.dart';
import '../models/estagio_alerta.dart';
import '../models/leitura_nivel.dart';
import 'classificador_estagio.dart';

/// Uma estação com a leitura e o estágio calculado dela.
typedef SituacaoEstacao = ({
  Estacao estacao,
  LeituraNivel leitura,
  EstagioAlerta estagio,
});

/// Avalia as [leituras] com as cotas das [estacoes] conhecidas.
///
/// Leitura de estação desconhecida fica de fora.
List<SituacaoEstacao> avaliarLeituras(
  List<LeituraNivel> leituras,
  List<Estacao> estacoes,
) {
  final estacoesPorCodigo = {
    for (final estacao in estacoes) estacao.codigo: estacao,
  };
  return [
    for (final leitura in leituras)
      if (estacoesPorCodigo[leitura.codigoEstacao] case final estacao?)
        (
          estacao: estacao,
          leitura: leitura,
          estagio: classificarEstagio(leitura.nivel, estacao.cotas),
        ),
  ];
}
