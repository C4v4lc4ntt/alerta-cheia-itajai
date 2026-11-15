// =============================================================================
// discador_servico.dart — contrato para ligar com um toque (RF05, D20).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// A tela conhece só esta interface; a implementação real usa o url_launcher, e
// os testes da tela usarão uma versão falsa.
// =============================================================================

/// Abre o discador do celular com o número já digitado.
abstract interface class DiscadorServico {
  /// Abre o discador com [numero] (só dígitos) e devolve se conseguiu.
  ///
  /// Nunca lança exceção: quando não abre, devolve `false` e a tela mostra o
  /// número para discar à mão. O app não faz a ligação sozinho.
  Future<bool> ligar(String numero);
}
