// =============================================================================
// ajustes_view.dart — View da aba "Ajustes".
//
// No MVVM a View só DESENHA o que o ViewModel entrega; não tem regra de
// negócio. Por enquanto é uma tela provisória.
// =============================================================================
import 'package:flutter/material.dart';

import '../comum/tela_em_construcao.dart';

/// Tela da aba "Ajustes".
class AjustesView extends StatelessWidget {
  const AjustesView({super.key});

  @override
  Widget build(BuildContext context) {
    // A Key fixa permite que os testes encontrem esta tela com find.byKey.
    return const TelaEmConstrucao(
      key: Key('tela_ajustes'),
      titulo: 'Ajustes',
      descricao: 'Bairros acompanhados e avisos (RF02).',
    );
  }
}
