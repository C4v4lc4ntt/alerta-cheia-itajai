// =============================================================================
// cartoes_orientacoes.dart — peças visuais do RF06 na aba "Ajuda" (D20).
//
// REFATORAR: separadas do cartoes_ajuda.dart depois dos ciclos 9 e 10, sem
// mudar o comportamento, para cada arquivo ficar abaixo de ~200 linhas
// (CLAUDE.md, seção 4).
// =============================================================================
import 'package:flutter/material.dart';

import '../../data/catalogo/catalogo_orientacoes.dart';

/// Itens de uma seção das orientações, um por linha (RF06).
class CartaoOrientacoes extends StatelessWidget {
  /// Cria o cartão com os [itens] da seção.
  const CartaoOrientacoes({super.key, required this.itens});

  /// Textos da seção, como estão na fonte.
  final List<String> itens;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final item in itens)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // O marcador é só visual; o leitor de tela lê o item.
                    const ExcludeSemantics(child: Text('•  ')),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Aviso de "enchente sem chuva" (RF06, D20). Em destaque, usa a cor de erro
/// do tema e um ícone; fora dele, um cartão comum.
class AvisoEnchenteSemChuva extends StatelessWidget {
  /// Cria o aviso; [emDestaque] vem da regra do domínio.
  const AvisoEnchenteSemChuva({super.key, required this.emDestaque});

  /// true a partir de Atenção.
  final bool emDestaque;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Card(
      color: emDestaque ? cores.errorContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: emDestaque ? cores.onErrorContainer : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                textoAvisoEnchenteSemChuva,
                style: TextStyle(
                  color: emDestaque ? cores.onErrorContainer : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
