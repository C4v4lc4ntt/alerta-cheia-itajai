// =============================================================================
// estacao.dart — uma estação de monitoramento da Defesa Civil de Itajaí.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// =============================================================================
import 'cotas_estacao.dart';

/// Estação de monitoramento: onde fica a régua e quais são as suas cotas.
class Estacao {
  /// Cria a estação.
  ///
  /// Lança [ArgumentError] se o [codigo] estiver vazio ou só com espaços.
  Estacao({
    required this.codigo,
    required this.nome,
    required this.rio,
    required this.cotas,
  }) {
    if (codigo.trim().isEmpty) {
      throw ArgumentError('O código da estação não pode ficar vazio.');
    }
  }

  /// Código do portal, sem hífen (ex.: "DC01"). É a chave que liga
  /// leituras, cotas e bairros (D07).
  final String codigo;

  /// Nome da estação no portal (ex.: "ICMBio/CEPSUL").
  final String nome;

  /// Rio monitorado (ex.: "Rio Itajaí-Açu").
  final String rio;

  /// Cotas de Atenção, Alerta e Emergência desta estação.
  final CotasEstacao cotas;
}
