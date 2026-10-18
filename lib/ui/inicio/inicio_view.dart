// =============================================================================
// inicio_view.dart — View da aba "Início".
//
// No MVVM a View só DESENHA o que o ViewModel entrega; não tem regra de
// negócio. Por enquanto é uma tela provisória.
// =============================================================================
import 'package:flutter/material.dart';

import '../comum/tela_em_construcao.dart';

/// Tela da aba "Início".
class InicioView extends StatelessWidget {
  const InicioView({super.key});

  @override
  Widget build(BuildContext context) {
    // A Key fixa permite que os testes encontrem esta tela com find.byKey.
    return const TelaEmConstrucao(
      key: Key('tela_inicio'),
      titulo: 'Início',
      descricao: 'Estágio de alerta e nível do rio e da maré (RF01).',
    );
  }
}
