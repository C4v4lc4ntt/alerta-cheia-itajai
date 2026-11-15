// =============================================================================
// mapa_view_model.dart — ViewModel da aba Mapa (RF04, D06 e adendos da D06 e
// da D18).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Acompanha os pontos do Firestore e expõe só os ativos (regra pontoAtivo).
// Uma revisão a cada minuto tira da tela o ponto que completou 6 h, mesmo
// sem lista nova. A View só desenha o que ele expõe.
// =============================================================================
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/servicos/pontos_servico.dart';
import '../../domain/models/ponto_alagamento.dart';
import '../../domain/regras/ponto_ativo.dart';

/// Estado da aba Mapa.
class MapaViewModel extends ChangeNotifier {
  /// Cria o ViewModel com o serviço e o relógio ([agora]) injetados.
  MapaViewModel({required this.pontos, required this.agora});

  /// De onde vêm os pontos (Firestore no app, falso nos testes).
  final PontosServico pontos;

  /// Relógio injetado, para os testes não dependerem da hora real.
  final DateTime Function() agora;

  /// De quanto em quanto tempo a lista é refiltrada sem lista nova: o ponto
  /// some da tela no máximo 1 minuto depois de completar 6 h.
  static const intervaloDaRevisao = Duration(minutes: 1);

  List<PontoAlagamento> _recebidos = const [];
  List<PontoAlagamento> _ativos = const [];
  StreamSubscription<List<PontoAlagamento>>? _assinatura;
  Timer? _revisao;

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
