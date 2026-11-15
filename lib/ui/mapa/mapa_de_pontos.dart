// =============================================================================
// mapa_de_pontos.dart — o mapa de ruas com os pontos de alagamento ativos
// (RF04, D13 e D19).
//
// ETAPA VERDE: código mínimo para os testes passarem (ciclo 6a).
// Só desenha o que o MapaViewModel expõe: o centro (D13) e os pontos ativos.
// Os ladrilhos vêm do OpenStreetMap, com a atribuição que a política de uso
// pede (D19); nos testes ficam desligados, para não acessar a internet.
// Ciclo 6b: tocar no marcador abre um painel com a altura, a hora da
// marcação e o botão "Já baixou" (uma vez por ponto, adendos da D18 e D13).
// =============================================================================
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/models/ponto_alagamento.dart';
import '../comum/formatos.dart';
import 'mapa_view_model.dart';

/// Mapa com um marcador por ponto de alagamento ativo.
class MapaDePontos extends StatelessWidget {
  /// Cria o mapa do [viewModel]. [mostrarLadrilhos] é false só nos testes.
  const MapaDePontos({
    super.key,
    required this.viewModel,
    this.mostrarLadrilhos = true,
  });

  /// De onde vêm o centro e os pontos ativos.
  final MapaViewModel viewModel;

  /// Liga a camada de ladrilhos (imagens do mapa baixadas da internet).
  final bool mostrarLadrilhos;

  /// Aproximação inicial: nível de bairro, com as ruas visíveis.
  static const zoomInicial = 15.0;

  /// Endereço dos ladrilhos do OpenStreetMap (D19).
  static const enderecoLadrilhos =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  @override
  Widget build(BuildContext context) {
    // Redesenha a cada notifyListeners do ViewModel (como um observer).
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final centro = viewModel.centro;
        // Enquanto o GPS é lido, ainda não se sabe onde centralizar.
        if (centro == null) {
          return const Center(child: Text('Buscando sua localização…'));
        }
        return FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(centro.latitude, centro.longitude),
            initialZoom: zoomInicial,
          ),
          children: [
            if (mostrarLadrilhos)
              TileLayer(
                urlTemplate: enderecoLadrilhos,
                // A política do OpenStreetMap pede que o app se identifique.
                userAgentPackageName: 'br.univali.ads.alerta_cheia_itajai',
              ),
            MarkerLayer(markers: _marcadores(context)),
            const SimpleAttributionWidget(source: Text('© OpenStreetMap')),
          ],
        );
      },
    );
  }

  // Um marcador por ponto ativo. A Key com o ID do ponto permite que os
  // testes achem cada marcador. 48 × 48 px: alvo de toque acessível, com
  // rótulo para o leitor de tela (CLAUDE.md, acessibilidade).
  List<Marker> _marcadores(BuildContext context) {
    final cor = Theme.of(context).colorScheme.error;
    return [
      for (final ponto in viewModel.pontosAtivos)
        Marker(
          point: LatLng(ponto.latitude, ponto.longitude),
          width: 48,
          height: 48,
          // container: true dá a cada marcador o seu próprio nó para o
          // leitor de tela; sem isso o rótulo se junta ao do mapa em volta.
          child: Semantics(
            container: true,
            label: 'Ponto de alagamento: ${rotuloDaAltura(ponto.altura)}',
            button: true,
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => _abrirPainel(context, ponto),
              child: Icon(
                Icons.location_on,
                key: ValueKey('marcador_${ponto.id}'),
                color: cor,
                size: 40,
              ),
            ),
          ),
        ),
    ];
  }

  // Painel de baixo com os dados do ponto e o botão "Já baixou". Ouve o
  // ViewModel, para o botão mudar para "Você já avisou" logo depois do toque.
  void _abrirPainel(BuildContext context, PontoAlagamento ponto) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => _PainelDoPonto(
          ponto: ponto,
          podeConfirmar: _podeConfirmar(ponto),
          aoConfirmar: () => _confirmar(ponto),
        ),
      ),
    );
  }

  // Sem ID (ponto que não veio do Firestore) não há o que confirmar.
  bool _podeConfirmar(PontoAlagamento ponto) {
    final id = ponto.id;
    return id != null && viewModel.podeConfirmar(id);
  }

  // O botão é marcado na hora; o envio segue sem a tela esperar (adendo da
  // D13), por isso o unawaited.
  void _confirmar(PontoAlagamento ponto) {
    final id = ponto.id;
    if (id != null) unawaited(viewModel.confirmarJaBaixou(id));
  }
}

/// Conteúdo do painel de um ponto: altura, hora da marcação e o botão.
class _PainelDoPonto extends StatelessWidget {
  const _PainelDoPonto({
    required this.ponto,
    required this.podeConfirmar,
    required this.aoConfirmar,
  });

  final PontoAlagamento ponto;
  final bool podeConfirmar;
  final VoidCallback aoConfirmar;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(rotuloDaAltura(ponto.altura), style: textos.titleMedium),
          const SizedBox(height: 4),
          Text('Marcado às ${horaDeBrasilia(ponto.criadoEm)}'),
          const SizedBox(height: 16),
          // onPressed null = botão desativado (o leitor de tela diz
          // "desativado").
          FilledButton(
            onPressed: podeConfirmar ? aoConfirmar : null,
            child: Text(podeConfirmar ? 'Já baixou' : 'Você já avisou'),
          ),
        ],
      ),
    );
  }
}
