// =============================================================================
// ponto_firestore.dart — conversão do ponto de alagamento para o documento do
// Firestore e de volta (RF03, D17).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Fica em data/ (e não em domain/) porque usa tipos do cloud_firestore: as
// regras exigem criadoEm == request.time, então a data vai como
// FieldValue.serverTimestamp() e volta como Timestamp.
// =============================================================================
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/altura_agua.dart';
import '../../domain/models/area_retangular.dart';
import '../../domain/models/ponto_alagamento.dart';

/// Documento a gravar: só os 4 campos da D17. A altura vai pelo nome do enum
/// ("canela", "joelho" ou "cintura"), e a data é preenchida pelo servidor.
Map<String, Object> pontoParaFirestore(PontoAlagamento ponto) => {
  'latitude': ponto.latitude,
  'longitude': ponto.longitude,
  'altura': ponto.altura.name,
  'criadoEm': FieldValue.serverTimestamp(),
};

/// Ponto lido do Firestore, ou `null` se o documento for inválido.
///
/// Documento inválido é ignorado para não derrubar o mapa inteiro. Um caso
/// normal: a marcação recém-enviada chega com criadoEm vazio até o servidor
/// confirmar o horário.
PontoAlagamento? pontoDoFirestore(
  Map<String, dynamic> dados, {
  required AreaRetangular area,
}) {
  // O padrão só casa se os 4 campos existirem e tiverem o tipo certo.
  if (dados case {
    'latitude': final double latitude,
    'longitude': final double longitude,
    'altura': final String nomeAltura,
    'criadoEm': final Timestamp criadoEm,
  }) {
    final altura = AlturaAgua.values.asNameMap()[nomeAltura];
    if (altura == null || !area.contem(latitude, longitude)) {
      return null;
    }
    // Reaproveita a validação do domínio. A data é a do servidor, em UTC,
    // para dar o mesmo resultado no celular (UTC−3) e no CI (UTC).
    return PontoAlagamento.registrar(
      latitude: latitude,
      longitude: longitude,
      altura: altura,
      area: area,
      agora: () => criadoEm.toDate().toUtc(),
    );
  }
  return null;
}
