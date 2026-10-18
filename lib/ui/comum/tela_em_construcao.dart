// =============================================================================
// tela_em_construcao.dart — tela provisória reaproveitada pelas 4 abas
// enquanto cada requisito (RF) não é implementado.
// =============================================================================
import 'package:flutter/material.dart';

/// Tela simples com título e uma descrição do que virá ali.
class TelaEmConstrucao extends StatelessWidget {
  const TelaEmConstrucao({
    super.key,
    required this.titulo,
    required this.descricao,
  });

  /// Texto da barra superior (ex.: "Mapa").
  final String titulo;

  /// Explica qual requisito vai ocupar a tela.
  final String descricao;

  @override
  Widget build(BuildContext context) {
    // Scaffold = "esqueleto" padrão de uma tela: barra superior + corpo.
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            descricao,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
