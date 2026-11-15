// =============================================================================
// ponto_alagamento.dart — ponto de alagamento marcado por um morador (RF03).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Só os campos da D17: posição, altura e data e hora. Sem foto (D06), sem
// texto livre e sem identificador do celular ou do morador (LGPD).
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
    return PontoAlagamento._(
      latitude: latitude,
      longitude: longitude,
      altura: altura,
      criadoEm: agora(),
    );
  }

  final double latitude;
  final double longitude;
  final AlturaAgua altura;

  /// Momento do registro no celular. No Firestore vale o horário do servidor
  /// (D17); isso é tratado no ciclo 16.
  final DateTime criadoEm;
}
