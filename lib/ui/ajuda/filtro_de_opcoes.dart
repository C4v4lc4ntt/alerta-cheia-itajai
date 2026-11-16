// =============================================================================
// filtro_de_opcoes.dart — fileira de botões para escolher uma opção de cada vez
// na aba "Ajuda" (passo 56, adendo da D20): a região dos abrigos e a aba das
// orientações.
//
// ETAPA VERDE: código mínimo para os testes passarem. O ChoiceChip já anuncia
// ao leitor de tela qual opção está escolhida e tem alvo de toque de 48 px.
// =============================================================================
import 'package:flutter/material.dart';

/// Botões lado a lado (quebrando a linha quando falta espaço), com uma opção
/// escolhida por vez.
class FiltroDeOpcoes extends StatelessWidget {
  /// Cria o filtro com as [opcoes], a [escolhida] e o aviso [aoEscolher].
  const FiltroDeOpcoes({
    super.key,
    required this.opcoes,
    required this.escolhida,
    required this.aoEscolher,
  });

  /// Rótulos das opções, na ordem em que aparecem.
  final List<String> opcoes;

  /// Opção marcada agora.
  final String escolhida;

  /// Chamado com o rótulo da opção tocada.
  final ValueChanged<String> aoEscolher;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final opcao in opcoes)
          ChoiceChip(
            label: Text(opcao),
            selected: opcao == escolhida,
            onSelected: (_) => aoEscolher(opcao),
          ),
      ],
    );
  }
}
