// =============================================================================
// mapa_view_model.dart — ViewModel da aba Mapa (RF04, D06 e adendos da D06 e
// da D18).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Acompanha os pontos do Firestore e expõe só os ativos (regra pontoAtivo).
// Uma revisão a cada minuto tira da tela o ponto que completou 6 h, mesmo
// sem lista nova. Ciclo 5b: "Já baixou" uma vez por ponto enquanto o app
// estiver aberto (adendo da D18). Ciclo 5c: o GPS é lido uma vez, só para
// centralizar o mapa; sem posição ou fora da área, o mapa abre em Itajaí
// (D13). A View só desenha o que ele expõe.
// =============================================================================
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/catalogo/area_itajai.dart';
import '../../data/servicos/localizacao_servico.dart';
import '../../data/servicos/pontos_servico.dart';
import '../../domain/models/leitura_localizacao.dart';
import '../../domain/models/ponto_alagamento.dart';
import '../../domain/regras/ponto_ativo.dart';

/// Estado da aba Mapa.
class MapaViewModel extends ChangeNotifier {
  /// Cria o ViewModel com o serviço e o relógio ([agora]) injetados.
  MapaViewModel({
    required this.pontos,
    required this.localizacao,
    required this.agora,
  });

  /// De onde vêm os pontos (Firestore no app, falso nos testes).
  final PontosServico pontos;

  /// Quem lê a posição do celular, uma vez, sem guardar (D13, LGPD).
  final LocalizacaoServico localizacao;

  /// Relógio injetado, para os testes não dependerem da hora real.
  final DateTime Function() agora;

  /// De quanto em quanto tempo a lista é refiltrada sem lista nova: o ponto
  /// some da tela no máximo 1 minuto depois de completar 6 h.
  static const intervaloDaRevisao = Duration(minutes: 1);

  List<PontoAlagamento> _recebidos = const [];
  List<PontoAlagamento> _ativos = const [];
  StreamSubscription<List<PontoAlagamento>>? _assinatura;
  Timer? _revisao;

  /// IDs que este celular já confirmou, só em memória (nada vai para o
  /// disco nem sai do celular, LGPD).
  final Set<String> _confirmados = {};

  ({double latitude, double longitude})? _centro;

  /// Onde o mapa fica centralizado; null enquanto a posição é buscada.
  ({double latitude, double longitude})? get centro => _centro;

  /// Pontos que a tela deve desenhar.
  List<PontoAlagamento> get pontosAtivos => _ativos;

  /// Começa a acompanhar os pontos e liga a revisão de cada minuto.
  void iniciar() {
    // Como um listener no Java: cada lista nova do Firestore chega aqui.
    _assinatura = pontos.acompanharPontos(agora: agora()).listen((lista) {
      _recebidos = lista;
      _filtrar();
    });
    _revisao = Timer.periodic(intervaloDaRevisao, (_) => _filtrar());
  }

  /// Lê a posição uma vez e escolhe o centro do mapa. A posição só vale se
  /// estiver dentro de Itajaí, onde ficam os pontos; nos outros casos
  /// (sem permissão, GPS desligado, falha ou fora da área) o mapa abre em
  /// Itajaí (D13).
  Future<void> buscarCentro() async {
    final leitura = await localizacao.obterAtual();
    _centro = switch (leitura) {
      LocalizacaoObtida(:final latitude, :final longitude)
          when areaItajai.contem(latitude, longitude) =>
        (latitude: latitude, longitude: longitude),
      _ => centroItajai,
    };
    notifyListeners();
  }

  /// Diz se o botão "Já baixou" do ponto [id] ainda funciona.
  bool podeConfirmar(String id) => !_confirmados.contains(id);

  /// Envia o "Já baixou" do ponto [id]. O botão é bloqueado na hora, sem
  /// esperar o servidor (sem internet, o +1 fica na fila do Firestore); se o
  /// servidor recusar, o botão volta a funcionar.
  Future<void> confirmarJaBaixou(String id) async {
    _confirmados.add(id);
    notifyListeners();
    try {
      await pontos.confirmarJaBaixou(id);
    } catch (_) {
      _confirmados.remove(id);
      notifyListeners();
    }
  }

  /// Guarda só os pontos ativos no momento atual e avisa a tela.
  void _filtrar() {
    final momento = agora();
    _ativos = [
      for (final ponto in _recebidos)
        if (pontoAtivo(ponto: ponto, agora: momento)) ponto,
    ];
    notifyListeners();
  }

  /// Para de ouvir o Firestore e desliga a revisão (como o @PreDestroy do
  /// Spring): o mapa fechado não gasta leituras nem memória.
  @override
  void dispose() {
    _assinatura?.cancel();
    _revisao?.cancel();
    super.dispose();
  }
}
