// =============================================================================
// sem_acentos.dart — texto em minúsculas e sem acentos, para comparar nomes
// escritos de jeitos diferentes.
//
// REFATORAÇÃO: a mesma conta estava repetida no estagioDoBoletim (D16) e no
// AjustesViewModel (busca de bairros). Agora os dois usam este código.
// =============================================================================

// Letras acentuadas do português e a versão sem acento, na mesma posição.
const _comAcento = 'áàâãéêíóôõúüç';
const _semAcento = 'aaaaeeiooouuc';

/// O [texto] em minúsculas e sem acentos (ex.: "São João" → "sao joao").
String semAcentos(String texto) {
  var resultado = texto.toLowerCase();
  for (var i = 0; i < _comAcento.length; i++) {
    resultado = resultado.replaceAll(_comAcento[i], _semAcento[i]);
  }
  return resultado;
}
