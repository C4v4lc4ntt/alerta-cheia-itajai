// =============================================================================
// classificador_estagio_test.dart — RF01: "dado um nível, retorna o estágio
// correto, incluindo os valores-limite".
//
// Teste escrito ANTES do código: ciclo vermelho → verde → refatorar do PR #1
// (commits test(rf01) → feat(rf01) → refactor(rf01)).
//
// Cotas usadas: catálogo oficial da Defesa Civil de Itajaí (consulta em
// 16/10/2026), estações DC-01 e DC-07.
// =============================================================================
import 'package:alerta_cheia_itajai/domain/models/cotas_estacao.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:alerta_cheia_itajai/domain/regras/classificador_estagio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Cotas reais da DC-01 (Rio Itajaí-Açu - ICMBio/CEPSUL).
  final cotasDc01 = CotasEstacao(atencao: 1.21, alerta: 1.61, emergencia: 1.75);

  // Cotas reais da DC-07 (Ribeirão da Murta - Portal).
  final cotasDc07 = CotasEstacao(atencao: 1.00, alerta: 1.40, emergencia: 1.50);

  group('classificarEstagio — DC-01', () {
    // Tabela de casos: nível → estágio esperado.
    // É o equivalente ao @ParameterizedTest do JUnit: um teste por linha.
    // Regra combinada: ATINGIR a cota já muda o estágio (comparação "≥").
    final casos = <double, EstagioAlerta>{
      // Abaixo da Atenção → Monitoramento
      -0.20: EstagioAlerta
          .monitoramento, // nível negativo existe em algumas réguas
      0.90: EstagioAlerta.monitoramento, // leitura real de 16/10/2026 08:00
      1.20: EstagioAlerta.monitoramento, // 1 cm abaixo da cota de Atenção
      // Limite da Atenção (1,21 m)
      1.21: EstagioAlerta.atencao, // exatamente na cota
      1.22: EstagioAlerta.atencao, // 1 cm acima
      // Limite do Alerta (1,61 m)
      1.60: EstagioAlerta.atencao,
      1.61: EstagioAlerta.alerta,
      1.62: EstagioAlerta.alerta,
      // Limite da Emergência (1,75 m)
      1.74: EstagioAlerta.alerta,
      1.75: EstagioAlerta.emergencia,
      3.00: EstagioAlerta.emergencia, // bem acima de tudo
    };

    // Gera um teste para cada linha da tabela.
    casos.forEach((nivel, esperado) {
      test('nível $nivel m → ${esperado.name}', () {
        expect(classificarEstagio(nivel, cotasDc01), esperado);
      });
    });
  });

  group('classificarEstagio — cada estação tem suas cotas', () {
    test('o mesmo nível (1,45 m) dá estágios diferentes em DC-01 e DC-07', () {
      expect(classificarEstagio(1.45, cotasDc01), EstagioAlerta.atencao);
      expect(classificarEstagio(1.45, cotasDc07), EstagioAlerta.alerta);
    });
  });

  group('CotasEstacao — validação', () {
    test('rejeita cotas fora de ordem (Alerta abaixo da Atenção)', () {
      expect(
        () => CotasEstacao(atencao: 1.60, alerta: 1.20, emergencia: 2.00),
        throwsArgumentError,
      );
    });

    test('rejeita cotas iguais (Alerta igual à Emergência)', () {
      expect(
        () => CotasEstacao(atencao: 1.00, alerta: 1.50, emergencia: 1.50),
        throwsArgumentError,
      );
    });
  });

  // Teste do toString(), que entrou na refatoração sem teste e deixou a
  // cobertura da lógica em 78,9% (abaixo dos 80% exigidos pelo CI).
  // Ele garante que as cotas aparecem de forma legível em logs e mensagens.
  group('CotasEstacao — toString', () {
    test('mostra as três cotas de forma legível', () {
      expect(
        cotasDc01.toString(),
        'CotasEstacao(atenção: 1.21, alerta: 1.61, emergência: 1.75)',
      );
    });
  });
}
