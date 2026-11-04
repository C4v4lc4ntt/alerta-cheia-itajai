// =============================================================================
// nome_do_estagio.dart — nome oficial de cada estágio (D01).
//
// REFATORAÇÃO: saiu de ui/comum/formatos.dart porque a notificação, que não é
// tela, também precisa do nome. Assim ele continua escrito num lugar só.
// =============================================================================
import '../models/estagio_alerta.dart';

/// Nome oficial do [estagio], por extenso e com acento (D01).
String nomeDoEstagio(EstagioAlerta estagio) => switch (estagio) {
  EstagioAlerta.monitoramento => 'Monitoramento',
  EstagioAlerta.atencao => 'Atenção',
  EstagioAlerta.alerta => 'Alerta',
  EstagioAlerta.emergencia => 'Emergência',
};
