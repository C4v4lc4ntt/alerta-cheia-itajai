// =============================================================================
// marcar_ponto_view_model.dart — ViewModel da tela "Marcar rua alagada"
// (RF03, D17).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Guarda a leitura da localização, a altura escolhida e o estado do envio.
// A View só desenha o que ele expõe e chama os métodos nos botões.
// =============================================================================
import 'package:flutter/foundation.dart';

import '../../data/catalogo/area_itajai.dart';
import '../../data/servicos/localizacao_servico.dart';
import '../../data/servicos/pontos_servico.dart';
import '../../domain/models/altura_agua.dart';
import '../../domain/models/leitura_localizacao.dart';
import '../../domain/models/ponto_alagamento.dart';
import 'estado_envio.dart';

/// Estado da marcação de um ponto de alagamento.
class MarcarPontoViewModel extends ChangeNotifier {
  /// Cria o ViewModel com os serviços e o relógio ([agora]) injetados.
  MarcarPontoViewModel({
    required this.localizacao,
    required this.pontos,
    required this.agora,
  });

  /// Quem lê a posição do celular.
  final LocalizacaoServico localizacao;

  /// Quem envia o ponto para o mapa.
  final PontosServico pontos;

  /// Relógio injetado, para os testes não dependerem da hora real.
  final DateTime Function() agora;

  /// Quanto o envio pode demorar antes de virar erro na tela (decisão de
  /// 10/11). A gravação pode seguir na fila do Firestore e chegar depois.
  static const tempoLimiteEnvio = Duration(seconds: 15);

  LeituraLocalizacao? _leitura;
  AlturaAgua? _altura;
  EstadoEnvio _envio = EstadoEnvio.nenhum;

  /// Leitura da posição; null enquanto busca.
  LeituraLocalizacao? get leitura => _leitura;

  /// Altura escolhida pelo morador; null antes de escolher.
  AlturaAgua? get altura => _altura;

  /// Em que pé está o envio.
  EstadoEnvio get envio => _envio;

  /// Diz se a posição foi lida, mas fica fora de Itajaí (decisão de 10/11).
  bool get foraDaArea => switch (_leitura) {
    LocalizacaoObtida(:final latitude, :final longitude) => !areaItajai.contem(
      latitude,
      longitude,
    ),
    _ => false,
  };

  /// O botão "Enviar para o mapa" só funciona com a posição dentro de
  /// Itajaí e a altura escolhida, e nunca durante nem depois do envio, para
  /// um segundo toque não duplicar a marcação.
  bool get podeEnviar =>
      _leitura is LocalizacaoObtida &&
      !foraDaArea &&
      _altura != null &&
      _envio != EstadoEnvio.enviando &&
      _envio != EstadoEnvio.enviado;

  /// Lê a posição. Serve para a abertura da tela e para os botões
  /// "Permitir localização" e "Tentar de novo": volta para "buscando" antes.
  Future<void> buscarLocalizacao() async {
    _leitura = null;
    notifyListeners();
    _leitura = await localizacao.obterAtual();
    notifyListeners();
  }

  /// Guarda a [altura] tocada pelo morador.
  void escolherAltura(AlturaAgua altura) {
    _altura = altura;
    notifyListeners();
  }

  /// Botão "Ligar a localização".
  Future<void> ligarLocalizacao() =>
      localizacao.abrirConfiguracoesDaLocalizacao();

  /// Botão "Abrir configurações".
  Future<void> abrirConfiguracoes() => localizacao.abrirConfiguracoesDoApp();

  /// Envia o ponto. Sem poder enviar, não faz nada.
  Future<void> enviar() async {
    if (!podeEnviar) return;
    final posicao = _leitura as LocalizacaoObtida;
    _envio = EstadoEnvio.enviando;
    notifyListeners();
    try {
      await pontos
          .enviar(
            PontoAlagamento.registrar(
              latitude: posicao.latitude,
              longitude: posicao.longitude,
              altura: _altura,
              area: areaItajai,
              agora: agora,
            ),
          )
          .timeout(tempoLimiteEnvio);
      _envio = EstadoEnvio.enviado;
    } on Exception {
      // Falha do serviço (Firestore recusou) ou tempo limite esgotado
      // (TimeoutException também é Exception): a tela mostra o erro e o
      // botão volta a funcionar.
      _envio = EstadoEnvio.erro;
    }
    notifyListeners();
  }
}
