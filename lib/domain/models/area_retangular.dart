// =============================================================================
// area_retangular.dart — retângulo de latitude e longitude usado para barrar
// pontos de alagamento fora do município (RF03, D17).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// =============================================================================

/// Retângulo em graus. A borda conta como dentro (D17).
class AreaRetangular {
  /// Cria a área.
  ///
  /// Lança [ArgumentError] se uma mínima for maior que a máxima, porque a
  /// área ficaria vazia e todo ponto seria recusado.
  AreaRetangular({
    required this.latitudeMinima,
    required this.latitudeMaxima,
    required this.longitudeMinima,
    required this.longitudeMaxima,
  }) {
    if (latitudeMinima > latitudeMaxima) {
      throw ArgumentError(
        'A latitude mínima ($latitudeMinima) é maior que a máxima '
        '($latitudeMaxima).',
      );
    }
    if (longitudeMinima > longitudeMaxima) {
      throw ArgumentError(
        'A longitude mínima ($longitudeMinima) é maior que a máxima '
        '($longitudeMaxima).',
      );
    }
  }

  final double latitudeMinima;
  final double latitudeMaxima;
  final double longitudeMinima;
  final double longitudeMaxima;

  /// Diz se o ponto está dentro da área, contando a borda.
  bool contem(double latitude, double longitude) =>
      latitude >= latitudeMinima &&
      latitude <= latitudeMaxima &&
      longitude >= longitudeMinima &&
      longitude <= longitudeMaxima;
}
