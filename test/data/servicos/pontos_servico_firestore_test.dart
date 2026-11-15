// =============================================================================
// pontos_servico_firestore_test.dart — RF03 (D17) e RF04: envio do ponto de
// alagamento para a coleção "pontos" do Cloud Firestore e leitura em tempo
// real dos pontos das últimas 6 h (ciclo 3b), com o ID do documento (4a).
//
// Escrito ANTES do código (etapa vermelha do TDD).
// Sem rede: o FakeFirebaseFirestore guarda tudo em memória (como o H2 num
// teste de Repository do Spring). O relógio do "servidor" é fixo, para o
// teste não depender da hora real.
// =============================================================================
import 'package:alerta_cheia_itajai/data/catalogo/area_itajai.dart';
import 'package:alerta_cheia_itajai/data/servicos/ponto_firestore.dart';
import 'package:alerta_cheia_itajai/data/servicos/pontos_servico_firestore.dart';
import 'package:alerta_cheia_itajai/domain/models/altura_agua.dart';
import 'package:alerta_cheia_itajai/domain/models/ponto_alagamento.dart';
import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Hora do servidor (fixa) e hora do celular (um minuto antes, de propósito):
  // o ponto gravado precisa ficar com a do servidor (D17).
  final horaDoServidor = DateTime.utc(2026, 11, 10, 18, 30);
  final horaDoCelular = DateTime.utc(2026, 11, 10, 18, 29);

  // Ponto qualquer dentro do retângulo, perto do Centro.
  const latitude = -26.9078;
  const longitude = -48.6616;

  late FakeFirebaseFirestore firestore;
  late PontosServicoFirestore servico;

  setUp(() {
    firestore = FakeFirebaseFirestore(clock: Clock.fixed(horaDoServidor));
    servico = PontosServicoFirestore(firestore);
  });

  PontoAlagamento pontoDoMorador() => PontoAlagamento.registrar(
    latitude: latitude,
    longitude: longitude,
    altura: AlturaAgua.canela,
    area: areaItajai,
    agora: () => horaDoCelular,
  );

  test('enviar grava um documento na coleção pontos', () async {
    // Act
    await servico.enviar(pontoDoMorador());

    // Assert
    final consulta = await firestore.collection('pontos').get();
    expect(consulta.docs, hasLength(1));
  });

  test(
    'o ponto gravado volta igual, com o horário do servidor em UTC',
    () async {
      // Act
      await servico.enviar(pontoDoMorador());

      // Assert: lê como o mapa vai ler (pontoDoFirestore + areaItajai).
      final consulta = await firestore.collection('pontos').get();
      final lido = pontoDoFirestore(
        consulta.docs.single.data(),
        area: areaItajai,
      );
      expect(lido, isNotNull);
      expect(lido!.latitude, latitude);
      expect(lido.longitude, longitude);
      expect(lido.altura, AlturaAgua.canela);
      expect(lido.criadoEm, horaDoServidor);
    },
  );

  // RF04 (ciclo 3b): o mapa acompanha os pontos em tempo real e a consulta
  // busca só os das últimas 6 h (a coleção só cresce: apagar é bloqueado).
  group('acompanharPontos', () {
    // Hora do celular ao abrir o mapa (relógio injetado).
    final agora = DateTime.utc(2026, 11, 15, 14, 0);

    // Documento como o Firestore guarda, criado [criadoHa] antes de agora.
    Map<String, Object> documento({required Duration criadoHa}) => {
      'latitude': latitude,
      'longitude': longitude,
      'altura': 'joelho',
      'criadoEm': Timestamp.fromDate(agora.subtract(criadoHa)),
    };

    Future<void> gravar(Map<String, Object> dados) =>
        firestore.collection('pontos').add(dados);

    // Valores-limite em volta das 6 h (D06 e adendo): o filtro segue a regra
    // pontoAtivo, em que a partir de 6 h o ponto sai do mapa.
    const casos = <String, (Duration, int)>{
      'criado há 5 h 59 min 59 s → vem': (
        Duration(hours: 5, minutes: 59, seconds: 59),
        1,
      ),
      'criado há exatamente 6 h → não vem': (Duration(hours: 6), 0),
      'criado há 6 h 0 min 1 s → não vem': (Duration(hours: 6, seconds: 1), 0),
    };

    casos.forEach((nome, caso) {
      final (criadoHa, quantos) = caso;
      test(nome, () async {
        // Arrange
        await gravar(documento(criadoHa: criadoHa));

        // Act: a primeira lista que o mapa recebe.
        final pontos = await servico.acompanharPontos(agora: agora).first;

        // Assert
        expect(pontos, hasLength(quantos));
      });
    });

    test('documento inválido fica de fora, sem derrubar a lista', () async {
      // Arrange: um ponto válido e um com altura inventada.
      await gravar(documento(criadoHa: const Duration(hours: 1)));
      await gravar({
        ...documento(criadoHa: const Duration(hours: 1)),
        'altura': 'tornozelo',
      });

      // Act
      final pontos = await servico.acompanharPontos(agora: agora).first;

      // Assert
      expect(pontos, hasLength(1));
    });

    // Tempo real: outro morador marca um ponto com o mapa já aberto, e a
    // lista nova chega sem reabrir a aba.
    test('ponto novo chega sem reabrir o mapa', () async {
      final tamanhos = <int>[];

      // "await for" percorre o Stream como um for-each que espera cada lista.
      await for (final pontos in servico.acompanharPontos(agora: agora)) {
        tamanhos.add(pontos.length);
        if (tamanhos.length == 2) break;
        // Depois da primeira lista (vazia), outro morador marca um ponto.
        await gravar(documento(criadoHa: const Duration(minutes: 1)));
      }

      expect(tamanhos, [0, 1]);
    });

    // RF04 (ciclo 4a): o botão "Já baixou" precisa saber qual documento
    // atualizar.
    test('cada ponto vem com o id do seu documento', () async {
      // Arrange: o add devolve a referência, com o ID gerado pelo Firestore.
      final referencia = await firestore
          .collection('pontos')
          .add(documento(criadoHa: const Duration(hours: 1)));

      // Act
      final pontos = await servico.acompanharPontos(agora: agora).first;

      // Assert
      expect(pontos.single.id, referencia.id);
    });
  });
}
