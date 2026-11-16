// =============================================================================
// consulta_guardada.dart — a última consulta ao portal que deu certo (D21).
//
// ETAPA VERDE (passo 57): código mínimo para os testes passarem.
// Fica guardada no celular para a tela Início mostrar quando não há internet.
// =============================================================================
import 'boletim_oficial.dart';
import 'leitura_nivel.dart';

/// Leituras e boletim de uma consulta, com a hora em que ela foi feita.
class ConsultaGuardada {
  /// Cria a consulta com as [leituras], o [boletim] (se houver) e a hora
  /// [consultadoEm].
  ConsultaGuardada({
    required this.leituras,
    required this.consultadoEm,
    this.boletim,
  });

  /// Leituras das estações, uma por estação.
  final List<LeituraNivel> leituras;

  /// Boletim oficial da consulta; null se o portal não trouxe.
  final BoletimOficial? boletim;

  /// Quando o app fez a consulta. A faixa "Sem internet" mostra esta hora.
  final DateTime consultadoEm;
}
