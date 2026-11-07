// =============================================================================
// estagio_do_boletim.dart — regra da D16: o estágio cuja cor o cartão oficial
// da tela Início usa, a partir do nome publicado pela Defesa Civil.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Lê o nome oficial (campo "flag"), não o código, porque o portal só
// confirmou alguns códigos. Nome desconhecido não vira estágio nenhum.
// =============================================================================
import '../models/estagio_alerta.dart';

/// Estágio de mesmo nome da [situacao] do boletim; null se não houver.
///
/// "Normalidade", nome do boletim para o primeiro nível, usa Monitoramento.
EstagioAlerta? estagioDoBoletim(String situacao) {
  return switch (_semAcentos(situacao.trim().toLowerCase())) {
    'normalidade' || 'monitoramento' => EstagioAlerta.monitoramento,
    'atencao' => EstagioAlerta.atencao,
    'alerta' => EstagioAlerta.alerta,
    'emergencia' => EstagioAlerta.emergencia,
    _ => null,
  };
}

// Letras acentuadas do português e a versão sem acento, na mesma posição.
const _comAcento = 'áàâãéêíóôõúüç';
const _semAcento = 'aaaaeeiooouuc';

// Texto sem acentos, para comparar nomes escritos de jeitos diferentes.
String _semAcentos(String texto) {
  var resultado = texto;
  for (var i = 0; i < _comAcento.length; i++) {
    resultado = resultado.replaceAll(_comAcento[i], _semAcento[i]);
  }
  return resultado;
}
