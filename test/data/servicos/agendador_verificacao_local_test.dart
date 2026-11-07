// =============================================================================
// agendador_verificacao_local_test.dart — RF02 (D14 e D15): ligar e desligar a
// verificação em segundo plano com o pacote workmanager.
//
// Escrito ANTES do código (etapa vermelha do TDD). O pacote é trocado por uma
// versão falsa, porque é uma borda do app; se a tarefa roda de verdade com o
// app fechado é conferido no celular, no passo 49.
// =============================================================================
import 'package:alerta_cheia_itajai/data/servicos/agendador_verificacao.dart';
import 'package:alerta_cheia_itajai/data/servicos/agendador_verificacao_local.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workmanager/workmanager.dart';

// Só os métodos usados são escritos; qualquer outro falha no teste.
class _WorkmanagerFalso extends Fake implements Workmanager {
  String? nomeRegistrado;
  Duration? frequencia;
  Constraints? restricoes;
  ExistingPeriodicWorkPolicy? politica;
  String? nomeCancelado;

  @override
  Future<void> registerPeriodicTask(
    String uniqueName,
    String taskName, {
    Duration? frequency,
    Duration? flexInterval,
    Map<String, dynamic>? inputData,
    Duration? initialDelay,
    Constraints? constraints,
    ExistingPeriodicWorkPolicy? existingWorkPolicy,
    BackoffPolicy? backoffPolicy,
    Duration? backoffPolicyDelay,
    String? tag,
    ForegroundServiceConfig? foregroundServiceConfig,
  }) async {
    nomeRegistrado = uniqueName;
    frequencia = frequency;
    restricoes = constraints;
    politica = existingWorkPolicy;
  }

  @override
  Future<void> cancelByUniqueName(String uniqueName) async {
    nomeCancelado = uniqueName;
  }
}

void main() {
  late _WorkmanagerFalso workmanager;

  AgendadorVerificacao criar({required bool ehAndroid}) {
    return AgendadorVerificacaoLocal(
      workmanager: workmanager,
      ehAndroid: ehAndroid,
    );
  }

  setUp(() => workmanager = _WorkmanagerFalso());

  group('no Android', () {
    // 15 minutos é o menor intervalo que o Android aceita (D14).
    test('ligar agenda a tarefa a cada 15 minutos', () async {
      await criar(ehAndroid: true).ligar();

      expect(workmanager.nomeRegistrado, nomeTarefaVerificacao);
      expect(workmanager.frequencia, const Duration(minutes: 15));
    });

    // Sem internet a verificação não tem o que consultar.
    test('ligar exige internet', () async {
      await criar(ehAndroid: true).ligar();

      expect(workmanager.restricoes?.networkType, NetworkType.connected);
    });

    // Marcar outro bairro não pode empurrar a próxima verificação para frente.
    test('ligar de novo mantém o agendamento que já existe', () async {
      await criar(ehAndroid: true).ligar();

      expect(workmanager.politica, ExistingPeriodicWorkPolicy.keep);
    });

    test('desligar cancela a tarefa', () async {
      await criar(ehAndroid: true).desligar();

      expect(workmanager.nomeCancelado, nomeTarefaVerificacao);
    });
  });

  // D14: no iOS a verificação acontece só com o app em uso.
  group('fora do Android', () {
    test('ligar não agenda nada', () async {
      await criar(ehAndroid: false).ligar();

      expect(workmanager.nomeRegistrado, isNull);
    });

    test('desligar não cancela nada', () async {
      await criar(ehAndroid: false).desligar();

      expect(workmanager.nomeCancelado, isNull);
    });
  });
}
