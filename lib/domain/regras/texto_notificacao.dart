// =============================================================================
// texto_notificacao.dart — regra do RF02: o que o aviso de mudança diz.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// O texto usa o cálculo descrito na D11, cita a estação mais crítica (D16) e
// deixa claro que o app é complemento.
// =============================================================================
import '../models/estacao.dart';
import '../models/estagio_alerta.dart';
import 'nome_da_estacao.dart';
import 'nome_do_estagio.dart';

/// Título e corpo de uma notificação.
typedef TextoNotificacao = ({String titulo, String corpo});

/// Monta o aviso de que o estágio do [bairro] mudou de [anterior] para
/// [atual], citando a [estacao] mais crítica.
TextoNotificacao textoDaNotificacao({
  required String bairro,
  required Estacao estacao,
  required EstagioAlerta anterior,
  required EstagioAlerta atual,
}) {
  final nomeAnterior = nomeDoEstagio(anterior);
  final nomeAtual = nomeDoEstagio(atual);
  return (
    // O título do Android é cortado se ficar longo: só código e nome.
    titulo:
        '$bairro: estação ${estacao.codigo} (${estacao.nome}) em $nomeAtual',
    corpo:
        '${nomeDaEstacao(estacao)}. O estágio mais grave entre as estações '
        'passou de $nomeAnterior para $nomeAtual. Não é alerta oficial; '
        'confira a Defesa Civil. Emergência: 199, 193 ou 192.',
  );
}
