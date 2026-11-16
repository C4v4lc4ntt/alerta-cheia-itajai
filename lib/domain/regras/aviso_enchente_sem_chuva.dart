// =============================================================================
// aviso_enchente_sem_chuva.dart — regra do RF06 (D20): quando o aviso de
// "enchente sem chuva" fica em destaque na aba Ajuda.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// =============================================================================
import '../models/estagio_alerta.dart';

/// Devolve `true` quando o [estagio] da cidade é Atenção ou mais grave.
///
/// O aviso fica sempre visível; a partir de Atenção ele ganha destaque. Usa a
/// ordem do enum, do menos ao mais grave (`index` é como o `ordinal()` do
/// Java).
bool avisoEnchenteSemChuvaEmDestaque(EstagioAlerta estagio) =>
    estagio.index >= EstagioAlerta.atencao.index;
