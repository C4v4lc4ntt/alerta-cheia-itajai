// =============================================================================
// indicador_estagio.dart — barrinha vertical na cor do estágio, usada ao lado
// das estações na tela Início (passo 56, visual novo).
//
// REFATORAR: só aparência; troca a bolinha colorida. O nome do estágio já
// está no texto ao lado, então a barra é escondida do leitor de tela e a cor
// nunca é a única pista (CLAUDE.md, seção 7).
// =============================================================================
import 'package:flutter/material.dart';

import '../../domain/models/estagio_alerta.dart';
import 'formatos.dart';

/// Barra de 6 × 36 px na cor do [estagio].
class IndicadorEstagio extends StatelessWidget {
  /// Cria a barra do [estagio].
  const IndicadorEstagio(this.estagio, {super.key});

  /// Estágio que define a cor.
  final EstagioAlerta estagio;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 6,
        height: 36,
        decoration: BoxDecoration(
          color: corDoEstagio(estagio),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
