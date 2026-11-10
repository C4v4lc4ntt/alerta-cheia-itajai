// =============================================================================
// localizacao_servico.dart — contrato da leitura da posição atual (RF03).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// A tela conhece só esta interface; a implementação real usa o geolocator, e
// os testes da tela usarão uma versão falsa (ciclo 19).
// =============================================================================
import '../../domain/models/leitura_localizacao.dart';

/// Leitura da posição do celular, uma vez, sem guardar (LGPD).
abstract interface class LocalizacaoServico {
  /// Lê a posição atual. Nunca lança exceção: cada problema vira um caso
  /// de [LeituraLocalizacao].
  Future<LeituraLocalizacao> obterAtual();
}
