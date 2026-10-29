// =============================================================================
// formatos.dart — textos e cores que a tela mostra para cada dado.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// É apresentação, não regra de negócio: por isso fica em ui/, e não em
// domain/.
// =============================================================================
import 'package:flutter/material.dart';

import '../../core/tema/cores.dart';
import '../../domain/models/estagio_alerta.dart';

/// Nome oficial do [estagio], por extenso e com acento (D01).
String nomeDoEstagio(EstagioAlerta estagio) => switch (estagio) {
  EstagioAlerta.monitoramento => 'Monitoramento',
  EstagioAlerta.atencao => 'Atenção',
  EstagioAlerta.alerta => 'Alerta',
  EstagioAlerta.emergencia => 'Emergência',
};

/// Rótulo da barra de estágios: só o Monitoramento é abreviado (D05).
String rotuloCurtoDoEstagio(EstagioAlerta estagio) =>
    estagio == EstagioAlerta.monitoramento
    ? 'Monitor.'
    : nomeDoEstagio(estagio);

/// Cor do cartão do [estagio], definida no tema do app.
Color corDoEstagio(EstagioAlerta estagio) => switch (estagio) {
  EstagioAlerta.monitoramento => CoresApp.estagioMonitoramento,
  EstagioAlerta.atencao => CoresApp.estagioAtencao,
  EstagioAlerta.alerta => CoresApp.estagioAlerta,
  EstagioAlerta.emergencia => CoresApp.estagioEmergencia,
};

/// Nível em metros no padrão brasileiro, com 2 casas: "1,42 m".
String formatarNivel(double nivel) =>
    '${nivel.toStringAsFixed(2).replaceAll('.', ',')} m';

/// Hora "HH:mm" em Brasília, a partir de qualquer [instante].
///
/// Usa UTC−3 fixo (o Brasil não tem horário de verão desde 2019), para dar
/// o mesmo resultado no celular, no seu PC e no CI.
String horaDeBrasilia(DateTime instante) {
  final emBrasilia = instante.toUtc().subtract(const Duration(hours: 3));
  String doisDigitos(int numero) => numero.toString().padLeft(2, '0');
  return '${doisDigitos(emBrasilia.hour)}:${doisDigitos(emBrasilia.minute)}';
}
