// =============================================================================
// cartao_mais_grave.dart — linha da estação mais grave da cidade na tela
// Início (D16), em forma de cartão com ícone (passo 56, REFATORAR).
//
// Antes era um Text solto no inicio_view.dart; virou cartão no visual novo e
// foi para um arquivo próprio para a tela ficar menor. O texto não muda.
// =============================================================================
import 'package:flutter/material.dart';

import '../comum/formatos.dart';
import 'inicio_view_model.dart';

/// Cartão com a estação mais grave da cidade quando ela não está entre as
/// estações dos bairros escolhidos (D16). O ícone é só visual.
class CartaoMaisGrave extends StatelessWidget {
  /// Cria o cartão a partir do [estado] pronto da tela Início.
  const CartaoMaisGrave({super.key, required this.estado});

  /// Estado da tela Início com as estações já ordenadas (mais grave antes).
  final InicioPronto estado;

  @override
  Widget build(BuildContext context) {
    final estagio = estado.estacoes.first.estagio;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Estação mais grave da cidade: '
                '${nomeDaEstacao(estado.estacaoMaisCritica)} · '
                '${formatarNivel(estado.leituraMaisCritica.nivel)} · '
                '${nomeDoEstagio(estagio)}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
