// =============================================================================
// mapa_view.dart — View da aba "Mapa".
//
// No MVVM a View só DESENHA o que o ViewModel entrega; não tem regra de
// negócio. Por enquanto é uma tela provisória.
// =============================================================================
import 'package:flutter/material.dart';

import '../comum/tela_em_construcao.dart';

/// Tela da aba "Mapa".
class MapaView extends StatelessWidget {
  const MapaView({super.key});

  @override
  Widget build(BuildContext context) {
    // A Key fixa permite que os testes encontrem esta tela com find.byKey.
    return const TelaEmConstrucao(
      key: Key('tela_mapa'),
      titulo: 'Mapa',
      descricao: 'Pontos de alagamento marcados pela comunidade (RF03 e RF04).',
    );
  }
}
