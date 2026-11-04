// =============================================================================
// texto_notificacao.dart — regra do RF02: o que o aviso de mudança diz.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// O texto usa o cálculo descrito na D11 e deixa claro que o app é complemento.
// =============================================================================
import '../models/estagio_alerta.dart';
import 'nome_do_estagio.dart';

/// Título e corpo de uma notificação.
typedef TextoNotificacao = ({String titulo, String corpo});

/// Monta o aviso de que o estágio do [bairro] mudou de [anterior] para [atual].
TextoNotificacao textoDaNotificacao({
  required String bairro,
  required EstagioAlerta anterior,
  required EstagioAlerta atual,
}) {
  final nomeAnterior = nomeDoEstagio(anterior);
  final nomeAtual = nomeDoEstagio(atual);
  return (
    titulo: '$bairro: estágio mudou para $nomeAtual',
    corpo:
        'De $nomeAnterior para $nomeAtual, pelo estágio mais grave entre as '
        'estações. Não é alerta oficial. Emergência: 199, 193 ou 192.',
  );
}
