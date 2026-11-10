// =============================================================================
// pontos_servico_firestore_test.dart — RF03 (D17): envio do ponto de
// alagamento para a coleção "pontos" do Cloud Firestore.
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
}
