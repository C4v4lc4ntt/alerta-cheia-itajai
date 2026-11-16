// =============================================================================
// faixa_sem_internet.dart — aviso no topo da Início quando a tela mostra a
// última consulta guardada (D21).
//
// ETAPA VERDE (passo 57): código mínimo para os testes passarem.
// A data e a hora da consulta e o caminho para o 199 evitam que um dado
// antigo pareça atual (o app é complemento, CLAUDE.md, seção 7).
// =============================================================================
import 'package:flutter/material.dart';

import '../comum/formatos.dart';

/// Faixa "Sem internet" com a hora da consulta [consultadoEm].
class FaixaSemInternet extends StatelessWidget {
  /// Cria a faixa para a consulta feita em [consultadoEm].
  const FaixaSemInternet({required this.consultadoEm, super.key});

  /// Quando foi feita a consulta que a tela está mostrando.
  final DateTime consultadoEm;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.wifi_off),
        title: Text(
          'Sem internet · dados de ${dataEHoraDeBrasilia(consultadoEm)}',
        ),
        subtitle: const Text(
          'Mostrando a última consulta guardada. Confirme pelo 199.',
        ),
      ),
    );
  }
}
