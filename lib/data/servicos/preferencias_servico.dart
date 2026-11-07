// =============================================================================
// preferencias_servico.dart — contrato do que o app guarda no celular (RF02).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// A implementação real usará o pacote shared_preferences (D14).
// =============================================================================
import '../../domain/models/estagio_alerta.dart';

/// Dados do morador guardados no celular.
abstract interface class PreferenciasServico {
  /// Nomes dos bairros escolhidos; lista vazia se não houver nenhum.
  Future<List<String>> lerBairrosEscolhidos();

  /// Guarda os [bairros] escolhidos, substituindo a escolha anterior.
  Future<void> salvarBairrosEscolhidos(List<String> bairros);

  /// Último estágio conhecido; null antes da primeira leitura.
  Future<EstagioAlerta?> lerUltimoEstagio();

  /// Guarda o [estagio] como o último conhecido.
  Future<void> salvarUltimoEstagio(EstagioAlerta estagio);

  /// Esquece o último estágio; a próxima leitura volta a ser a primeira (D12).
  Future<void> apagarUltimoEstagio();
}
