// =============================================================================
// agendador_verificacao.dart — contrato de quem liga e desliga a verificação
// em segundo plano (RF02, D14 e D15).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// A implementação real usa o pacote workmanager.
// =============================================================================

/// Nome da tarefa periódica no sistema do celular.
const nomeTarefaVerificacao = 'verificacao_estagio';

/// Liga e desliga a verificação com o app fechado.
abstract interface class AgendadorVerificacao {
  /// Liga a verificação periódica. Se já estiver ligada, nada muda.
  Future<void> ligar();

  /// Desliga a verificação periódica.
  Future<void> desligar();
}
