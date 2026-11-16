// =============================================================================
// cabecalho_app.dart — cabeçalho azul das 4 abas (passo 56, visual novo).
//
// REFATORAR: só aparência. Mostra o nome do app, o título da aba e uma linha
// lembrando que o app é complemento e que a emergência é o 199 (CLAUDE.md,
// seção 7: o caminho para o 199, o 193 e o 192 fica sempre visível).
// As cores vêm do appBarTheme (lib/core/tema/tema_app.dart).
// =============================================================================
import 'package:flutter/material.dart';

import '../../core/tema/cores.dart';

/// Texto da linha de baixo do cabeçalho, igual em todas as abas.
const String textoComplemento =
    'Complemento aos alertas oficiais · Emergência 199';

/// AppBar das abas com o nome do app, o [titulo] e a linha de complemento.
///
/// `implements PreferredSizeWidget` é o "contrato" que o Scaffold pede para
/// aceitar o widget como appBar (como implementar uma interface no Java).
class CabecalhoApp extends StatelessWidget implements PreferredSizeWidget {
  /// Cria o cabeçalho da aba [titulo].
  const CabecalhoApp(this.titulo, {super.key});

  /// Nome da aba, em destaque.
  final String titulo;

  // Altura com espaço para as três linhas.
  static const double _altura = 88;

  @override
  Size get preferredSize => const Size.fromHeight(_altura);

  @override
  Widget build(BuildContext context) {
    const claro = TextStyle(color: CoresApp.cabecalhoSecundario);
    return AppBar(
      toolbarHeight: _altura,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Alerta Cheia Itajaí',
            style: claro.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          // header: o leitor de tela anuncia o título como cabeçalho.
          Semantics(header: true, child: Text(titulo)),
          Text(
            textoComplemento,
            style: claro.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
