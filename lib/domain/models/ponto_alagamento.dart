// =============================================================================
// ponto_alagamento.dart — ponto de alagamento marcado por um morador (RF03).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Só os campos da D17: posição, altura e data e hora. Sem foto (D06), sem
// texto livre e sem identificador do celular ou do morador (LGPD).
// Ciclo 2 do RF04: contador de "Já baixou" (padrão 0, nunca negativo).
// Ciclo 4a do RF04: ID do documento do Firestore (null antes de gravar).
// =============================================================================
import 'altura_agua.dart';
import 'area_retangular.dart';

/// Ponto de alagamento já validado.
class PontoAlagamento {
  const PontoAlagamento._({
    required this.latitude,
    required this.longitude,
    required this.altura,
    required this.criadoEm,
    required this.jaBaixou,
    required this.id,
  });

  /// Registra um ponto novo.
  ///
  /// Os valores chegam opcionais porque o GPS pode falhar e o morador pode
  /// não ter escolhido a altura. Lança [ArgumentError] dizendo qual valor
  /// faltou, ou se o ponto ficar fora da [area]. A data e a hora vêm do
  /// relógio injetado ([agora]), para os testes não dependerem da hora real.
  factory PontoAlagamento.registrar({
    required double? latitude,
    required double? longitude,
    required AlturaAgua? altura,
    required AreaRetangular area,
    required DateTime Function() agora,
    int jaBaixou = 0,
    String? id,
  }) {
    if (latitude == null) {
      throw ArgumentError('A latitude não foi informada.');
    }
    if (longitude == null) {
      throw ArgumentError('A longitude não foi informada.');
    }
    if (altura == null) {
      throw ArgumentError('A altura da água não foi informada.');
    }
    if (!area.contem(latitude, longitude)) {
      throw ArgumentError(
        'O ponto ($latitude, $longitude) fica fora da área permitida.',
      );
    }
    // O contador só cresce a partir de 0; negativo indica dado errado.
    if (jaBaixou < 0) {
      throw ArgumentError(
        'O número de "Já baixou" não pode ser negativo: $jaBaixou.',
      );
    }
    return PontoAlagamento._(
      latitude: latitude,
      longitude: longitude,
      altura: altura,
      criadoEm: agora(),
      jaBaixou: jaBaixou,
      id: id,
    );
  }

  final double latitude;
  final double longitude;
  final AlturaAgua altura;

  /// Momento do registro no celular. No Firestore vale o horário do servidor
  /// (D17); isso é tratado no ciclo 16.
  final DateTime criadoEm;

  /// Quantos moradores tocaram em "Já baixou" neste ponto (RF04).
  final int jaBaixou;

  /// ID do documento no Firestore, como o @Id de uma entidade JPA: `null` no
  /// ponto recém-marcado e preenchido na leitura (RF04, adendo da D18).
  final String? id;
}
