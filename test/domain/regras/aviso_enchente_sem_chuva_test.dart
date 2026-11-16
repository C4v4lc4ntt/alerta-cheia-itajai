// =============================================================================
// aviso_enchente_sem_chuva_test.dart — RF06 (D20): quando o aviso de
// "enchente sem chuva" fica em destaque na aba Ajuda.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// O aviso fica sempre visível; em destaque a partir de Atenção. A fronteira é
// entre Monitoramento e Atenção, e a tabela cobre os 4 estágios oficiais.
// =============================================================================
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:alerta_cheia_itajai/domain/regras/aviso_enchente_sem_chuva.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('avisoEnchenteSemChuvaEmDestaque', () {
    // Tabela de casos: estágio da cidade → aviso em destaque?
    const casos = {
      EstagioAlerta.monitoramento: false, // logo abaixo da fronteira
      EstagioAlerta.atencao: true, // exatamente na fronteira
      EstagioAlerta.alerta: true, // logo acima
      EstagioAlerta.emergencia: true,
    };
    casos.forEach((estagio, emDestaque) {
      test('$estagio → em destaque: $emDestaque', () {
        expect(avisoEnchenteSemChuvaEmDestaque(estagio), emDestaque);
      });
    });
  });
}
