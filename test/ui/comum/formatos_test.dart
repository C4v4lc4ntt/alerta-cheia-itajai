// =============================================================================
// formatos_test.dart — RF01, ciclo 7 (parte a): textos e cores da tela.
//
// ETAPA VERMELHA: os formatadores ainda não existem, então este teste nem
// compila. Nomes dos estágios: D01 (oficiais) e D05 (rótulo curto da barra).
// =============================================================================
import 'package:alerta_cheia_itajai/core/tema/cores.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';
import 'package:alerta_cheia_itajai/ui/comum/formatos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nomeDoEstagio (D01, por extenso, com acento)', () {
    const esperados = {
      EstagioAlerta.monitoramento: 'Monitoramento',
      EstagioAlerta.atencao: 'Atenção',
      EstagioAlerta.alerta: 'Alerta',
      EstagioAlerta.emergencia: 'Emergência',
    };
    esperados.forEach((estagio, nome) {
      test('$estagio → $nome', () {
        expect(nomeDoEstagio(estagio), nome);
      });
    });
  });

  // D05: só na barra, "Monitoramento" vira "Monitor." para caber.
  test('rotuloCurtoDoEstagio abrevia só o Monitoramento', () {
    expect(rotuloCurtoDoEstagio(EstagioAlerta.monitoramento), 'Monitor.');
    expect(rotuloCurtoDoEstagio(EstagioAlerta.emergencia), 'Emergência');
  });

  group('corDoEstagio', () {
    const esperadas = {
      EstagioAlerta.monitoramento: CoresApp.estagioMonitoramento,
      EstagioAlerta.atencao: CoresApp.estagioAtencao,
      EstagioAlerta.alerta: CoresApp.estagioAlerta,
      EstagioAlerta.emergencia: CoresApp.estagioEmergencia,
    };
    esperadas.forEach((estagio, cor) {
      test('$estagio → cor do tema', () {
        expect(corDoEstagio(estagio), cor);
      });
    });
  });

  group('formatarNivel (vírgula e 2 casas, padrão brasileiro)', () {
    // "final" e não "const": o Dart não aceita double como chave constante.
    final esperados = {1.42: '1,42 m', 0.8: '0,80 m', 10.0: '10,00 m'};
    esperados.forEach((nivel, texto) {
      test('$nivel → $texto', () {
        expect(formatarNivel(nivel), texto);
      });
    });
  });

  // O CI roda em UTC e o seu PC em Brasília: o teste não pode depender do
  // fuso da máquina. O Brasil não tem horário de verão desde 2019 (UTC−3).
  group('horaDeBrasilia', () {
    test('21:31 UTC → 18:31', () {
      expect(horaDeBrasilia(DateTime.utc(2026, 10, 26, 21, 31)), '18:31');
    });

    test('02:05 UTC → 23:05 (volta para o dia anterior)', () {
      expect(horaDeBrasilia(DateTime.utc(2026, 10, 27, 2, 5)), '23:05');
    });
  });
}
