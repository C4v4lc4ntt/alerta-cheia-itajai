// =============================================================================
// agendador_verificacao_local.dart — verificação em segundo plano com o pacote
// workmanager (D14 e D15).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Só age no Android: no iOS a verificação acontece com o app em uso (D14).
// =============================================================================
import 'package:workmanager/workmanager.dart';

import 'agendador_verificacao.dart';

/// Implementação real de [AgendadorVerificacao].
class AgendadorVerificacaoLocal implements AgendadorVerificacao {
  /// Cria o agendador com o [workmanager] e o sistema injetados.
  AgendadorVerificacaoLocal({
    required this.workmanager,
    required this.ehAndroid,
  });

  /// Pacote que fala com o agendador do sistema.
  final Workmanager workmanager;

  /// Se o app está rodando no Android.
  final bool ehAndroid;

  @override
  Future<void> ligar() async {
    if (!ehAndroid) return;
    await workmanager.registerPeriodicTask(
      nomeTarefaVerificacao,
      nomeTarefaVerificacao,
      frequency: const Duration(minutes: 15), // mínimo do Android (D14)
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  @override
  Future<void> desligar() async {
    if (!ehAndroid) return;
    await workmanager.cancelByUniqueName(nomeTarefaVerificacao);
  }
}
