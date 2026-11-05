// =============================================================================
// agendador_falso.dart — versão de AgendadorVerificacao para os testes.
//
// Em vez de falar com o sistema do celular, só lembra se está ligada.
// =============================================================================
import 'package:alerta_cheia_itajai/data/servicos/agendador_verificacao.dart';

/// Agendador que só guarda o estado.
class AgendadorFalso implements AgendadorVerificacao {
  /// Se a verificação em segundo plano está ligada.
  bool ligada = false;

  @override
  Future<void> ligar() async => ligada = true;

  @override
  Future<void> desligar() async => ligada = false;
}
