// =============================================================================
// ajuda_view.dart — View da aba "Ajuda".
//
// No MVVM a View só DESENHA o que o ViewModel entrega; não tem regra de
// negócio. Por enquanto é uma tela provisória.
// =============================================================================
import 'package:flutter/material.dart';

import '../comum/tela_em_construcao.dart';

/// Tela da aba "Ajuda".
class AjudaView extends StatelessWidget {
  const AjudaView({super.key});

  @override
  Widget build(BuildContext context) {
    // A Key fixa permite que os testes encontrem esta tela com find.byKey.
    return const TelaEmConstrucao(
      key: Key('tela_ajuda'),
      titulo: 'Ajuda',
      descricao: 'Abrigos, contatos de emergência e orientações (RF05 e RF06).',
    );
  }
}
