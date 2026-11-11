// =============================================================================
// area_itajai.dart — retângulo do município de Itajaí (RF03, D17).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Fonte: OpenStreetMap, relation 296666 ("Itajaí, Santa Catarina, Região Sul,
// Brasil"), consulta ao Nominatim em 09/11/2026. O retângulo inclui partes de
// Navegantes, de Balneário Camboriú e do mar: serve para barrar pontos
// absurdos, não para traçar a divisa.
// =============================================================================
import '../../domain/models/area_retangular.dart';

/// Área em que um ponto de alagamento é aceito.
final AreaRetangular areaItajai = AreaRetangular(
  latitudeMinima: -27.0960000,
  latitudeMaxima: -26.8378087,
  longitudeMinima: -48.8690000,
  longitudeMaxima: -48.6213454,
);
