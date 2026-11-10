// =============================================================================
// localizacao_servico_falso.dart — versão de LocalizacaoServico para os testes.
//
// Não toca no GPS: devolve a leitura escolhida pelo teste e conta as chamadas,
// para o teste conferir o que cada botão da tela pediu.
// =============================================================================
import 'package:alerta_cheia_itajai/data/servicos/localizacao_servico.dart';
import 'package:alerta_cheia_itajai/domain/models/leitura_localizacao.dart';

/// Serviço de localização em memória.
class LocalizacaoServicoFalso implements LocalizacaoServico {
  /// Cria o serviço com a [resposta] que o "GPS" vai dar.
  LocalizacaoServicoFalso({required this.resposta});

  /// Leitura devolvida por [obterAtual]. O teste pode trocá-la no meio.
  LeituraLocalizacao resposta;

  /// Quantas vezes a posição foi lida.
  int leituras = 0;

  /// Quantas vezes a tela de ligar a localização foi aberta.
  int aberturasDaLocalizacao = 0;

  /// Quantas vezes as configurações do app foram abertas.
  int aberturasDoApp = 0;

  @override
  Future<LeituraLocalizacao> obterAtual() async {
    leituras++;
    return resposta;
  }

  @override
  Future<void> abrirConfiguracoesDaLocalizacao() async {
    aberturasDaLocalizacao++;
  }

  @override
  Future<void> abrirConfiguracoesDoApp() async {
    aberturasDoApp++;
  }
}
