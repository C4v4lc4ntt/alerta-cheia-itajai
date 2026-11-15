// =============================================================================
// mapa_de_pontos.dart — o mapa de ruas com os pontos de alagamento ativos
// (RF04, D13 e D19).
//
// ETAPA VERDE: código mínimo para os testes passarem (ciclo 6a).
// Só desenha o que o MapaViewModel expõe: o centro (D13) e os pontos ativos.
// Os ladrilhos vêm do OpenStreetMap, com a atribuição que a política de uso
// pede (D19); nos testes ficam desligados, para não acessar a internet.
// =============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  // testes achem cada marcador. 48 × 48 px: alvo de toque acessível.
  List<Marker> _marcadores(BuildContext context) {
    final cor = Theme.of(context).colorScheme.error;
    return [
      for (final ponto in viewModel.pontosAtivos)
        Marker(
          point: LatLng(ponto.latitude, ponto.longitude),
          width: 48,
          height: 48,
          child: Icon(
            Icons.location_on,
            key: ValueKey('marcador_${ponto.id}'),
            color: cor,
            size: 40,
          ),
        ),
    ];
  }
}
