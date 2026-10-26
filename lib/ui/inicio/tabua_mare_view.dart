// =============================================================================
// tabua_mare_view.dart — mostra a tábua de marés do mês (D10).
//
// A tábua é uma imagem publicada pela Defesa Civil: o app só a exibe, com
// zoom, e nunca tenta ler os valores dela.
// =============================================================================
import 'package:flutter/material.dart';

import '../../domain/models/tabua_mare.dart';

/// Tela com a imagem da tábua de marés.
class TabuaMareView extends StatelessWidget {
  /// Cria a tela para a [tabua] informada.
  const TabuaMareView({super.key, required this.tabua});

  /// Tábua a exibir.
  final TabuaMare tabua;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('tela_tabua_mare'),
      appBar: AppBar(title: const Text('Tábua de marés')),
      // InteractiveViewer permite aproximar a imagem com dois dedos.
      body: InteractiveViewer(
        maxScale: 5,
        child: Center(
          child: Image.network(
            tabua.endereco.toString(),
            semanticLabel:
                'Tábua de marés ${tabua.mesReferencia}, '
                'publicada pela Defesa Civil de Itajaí',
            errorBuilder: (context, erro, pilha) => const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Não foi possível abrir a tábua de marés. '
                'Verifique a internet e tente de novo.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
