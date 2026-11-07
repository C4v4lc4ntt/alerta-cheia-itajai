// =============================================================================
// texto_notificacao_test.dart — RF02 (D11, D16 e CLAUDE.md, seção 7): o texto
// do aviso diz o que mudou, qual estação pesou e que não é alerta oficial.
//
// Escrito ANTES do código (etapa vermelha do TDD). D16 (07/11/2026): o aviso
// passou a citar a estação, porque DC07 e DC09 ficam no mesmo ribeirão.
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/catalogo_estacoes.dart';
import 'package:alerta_cheia_itajai/domain/models/estacao.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:alerta_cheia_itajai/domain/regras/texto_notificacao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Estacao estacao(String codigo) =>
      catalogoEstacoes.firstWhere((item) => item.codigo == codigo);

  group('textoDaNotificacao', () {
    test('título traz o bairro, a estação e o novo estágio', () {
      final texto = textoDaNotificacao(
        bairro: 'Murta',
        estacao: estacao('DC07'),
        anterior: EstagioAlerta.monitoramento,
        atual: EstagioAlerta.emergencia,
      );

      expect(texto.titulo, 'Murta: estação DC07 (Portal) em Emergência');
    });

    test('corpo traz a estação, a mudança, o aviso e os telefones', () {
      final texto = textoDaNotificacao(
        bairro: 'Murta',
        estacao: estacao('DC07'),
        anterior: EstagioAlerta.monitoramento,
        atual: EstagioAlerta.emergencia,
      );

      expect(
        texto.corpo,
        'DC07 · Portal · Ribeirão da Murta. O estágio mais grave entre as '
        'estações passou de Monitoramento para Emergência. Não é alerta '
        'oficial; confira a Defesa Civil. Emergência: 199, 193 ou 192.',
      );
    });

    // Vale também para quando o estágio desce.
    test('descer de estágio usa o mesmo formato', () {
      final texto = textoDaNotificacao(
        bairro: 'Centro',
        estacao: estacao('DC01'),
        anterior: EstagioAlerta.emergencia,
        atual: EstagioAlerta.alerta,
      );

      expect(texto.titulo, 'Centro: estação DC01 (ICMBio/CEPSUL) em Alerta');
      expect(texto.corpo, contains('passou de Emergência para Alerta.'));
    });
  });
}
