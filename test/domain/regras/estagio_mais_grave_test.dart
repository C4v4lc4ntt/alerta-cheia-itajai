// =============================================================================
// estagio_mais_grave_test.dart — RF01 (e D02): o estágio da cidade é o mais
// grave entre as estações. A mesma regra vale para o bairro (RF02).
//
// Escrito ANTES do código (etapa vermelha do TDD).
// =============================================================================
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:alerta_cheia_itajai/domain/regras/estagio_mais_grave.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('estagioMaisGrave', () {
    // Caso mais simples: com uma estação só, o estágio é o dela.
    test('uma estação em Atenção → atenção', () {
      expect(estagioMaisGrave([EstagioAlerta.atencao]), EstagioAlerta.atencao);
    });

    // Todas tranquilas: a cidade também fica em Monitoramento.
    test('todas em Monitoramento → monitoramento', () {
      expect(
        estagioMaisGrave([
          EstagioAlerta.monitoramento,
          EstagioAlerta.monitoramento,
        ]),
        EstagioAlerta.monitoramento,
      );
    });

    // Basta UMA estação grave para a cidade inteira subir de estágio.
    test('uma estação em Emergência entre várias tranquilas → emergência', () {
      expect(
        estagioMaisGrave([
          EstagioAlerta.monitoramento,
          EstagioAlerta.emergencia,
          EstagioAlerta.atencao,
        ]),
        EstagioAlerta.emergencia,
      );
    });

    // A ordem da lista não pode mudar o resultado.
    test('a ordem das estações não importa', () {
      expect(
        estagioMaisGrave([EstagioAlerta.alerta, EstagioAlerta.atencao]),
        EstagioAlerta.alerta,
      );
      expect(
        estagioMaisGrave([EstagioAlerta.atencao, EstagioAlerta.alerta]),
        EstagioAlerta.alerta,
      );
    });

    // Sem leituras NÃO é "está tudo bem": devolver Monitoramento seria
    // tranquilizar a pessoa sem base. Por isso é um erro.
    test('lista vazia → ArgumentError', () {
      expect(() => estagioMaisGrave([]), throwsArgumentError);
    });
  });
}
