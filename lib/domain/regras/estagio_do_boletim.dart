// =============================================================================
// estagio_do_boletim.dart — regra da D16: o estágio cuja cor o cartão oficial
// da tela Início usa, a partir do nome publicado pela Defesa Civil.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Lê o nome oficial (campo "flag"), não o código, porque o portal só
// confirmou alguns códigos. Nome desconhecido não vira estágio nenhum.
// =============================================================================
import '../models/estagio_alerta.dart';
import 'sem_acentos.dart';

/// Estágio de mesmo nome da [situacao] do boletim; null se não houver.
///
/// "Normalidade", nome do boletim para o primeiro nível, usa Monitoramento.
EstagioAlerta? estagioDoBoletim(String situacao) {
  return switch (semAcentos(situacao.trim())) {
    'normalidade' || 'monitoramento' => EstagioAlerta.monitoramento,
    'atencao' => EstagioAlerta.atencao,
    'alerta' => EstagioAlerta.alerta,
    'emergencia' => EstagioAlerta.emergencia,
    _ => null,
  };
}
