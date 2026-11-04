// =============================================================================
// texto_notificacao_test.dart — RF02 (D11 e CLAUDE.md, seção 7): o texto do
// aviso diz o que mudou, de onde vem o estágio e que não é alerta oficial.
//
// Escrito ANTES do código (etapa vermelha do TDD).
// =============================================================================
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:alerta_cheia_itajai/domain/regras/texto_notificacao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('textoDaNotificacao', () {
    test('título traz o bairro e o novo estágio', () {
      final texto = textoDaNotificacao(
        bairro: 'Murta',
        anterior: EstagioAlerta.monitoramento,
        atual: EstagioAlerta.atencao,
      );

      expect(texto.titulo, 'Murta: estágio mudou para Atenção');
    });

    test('corpo traz a mudança, a origem e os telefones', () {
      final texto = textoDaNotificacao(
        bairro: 'Murta',
        anterior: EstagioAlerta.monitoramento,
        atual: EstagioAlerta.atencao,
      );

      expect(
        texto.corpo,
        'De Monitoramento para Atenção, pelo estágio mais grave entre as '
        'estações. Não é alerta oficial. Emergência: 199, 193 ou 192.',
      );
    });

    // Vale também para quando o estágio desce.
    test('descer de estágio usa o mesmo formato', () {
      final texto = textoDaNotificacao(
        bairro: 'Centro',
        anterior: EstagioAlerta.emergencia,
        atual: EstagioAlerta.alerta,
      );

      expect(texto.titulo, 'Centro: estágio mudou para Alerta');
      expect(texto.corpo, startsWith('De Emergência para Alerta,'));
    });
  });
}
