// =============================================================================
// pontos_servico_firestore.dart — envio dos pontos de alagamento para a
// coleção "pontos" do Cloud Firestore (RF03, D17) e leitura em tempo real
// dos pontos das últimas 6 h (RF04, ciclo 3b), com o ID de cada documento
// (ciclo 4a). Ciclo 4b: o "Já baixou" soma 1 no documento.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// O FirebaseFirestore chega pelo construtor: no app é o real, nos testes é o
// FakeFirebaseFirestore (injeção por construtor, como no Spring).
// =============================================================================
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/ponto_alagamento.dart';
import '../../domain/regras/ponto_ativo.dart';
import '../catalogo/area_itajai.dart';
import 'ponto_firestore.dart';
import 'pontos_servico.dart';

/// [PontosServico] que grava no Cloud Firestore.
class PontosServicoFirestore implements PontosServico {
  /// Cria o serviço sobre o [_firestore] recebido.
  const PontosServicoFirestore(this._firestore);

  final FirebaseFirestore _firestore;

  /// Grava o [ponto] como um documento novo, com id gerado pelo Firestore.
  /// O documento leva só os 4 campos da D17 (ver pontoParaFirestore).
  @override
  Future<void> enviar(PontoAlagamento ponto) async {
    await _firestore.collection('pontos').add(pontoParaFirestore(ponto));
  }

  /// Acompanha os pontos criados depois de [agora] − 6 h.
  @override
  Stream<List<PontoAlagamento>> acompanharPontos({required DateTime agora}) {
    // Com exatamente 6 h o ponto já sai (adendo da D06), por isso
    // "isGreaterThan" (>) e não ">=".
    final limite = Timestamp.fromDate(agora.subtract(prazoDoPonto));
    return _firestore
        .collection('pontos')
        .where('criadoEm', isGreaterThan: limite)
        .snapshots()
        // Cada mudança traz a consulta inteira de novo. Documento inválido
        // vira null, e o whereType tira os nulls (como o
        // filter(Objects::nonNull) do Java).
        .map(
          (consulta) => consulta.docs
              .map(
                (documento) => pontoDoFirestore(
                  documento.data(),
                  area: areaItajai,
                  id: documento.id,
                ),
              )
              .whereType<PontoAlagamento>()
              .toList(),
        );
  }

  /// Soma 1 ao "Já baixou" do documento [id]. O increment soma no servidor
  /// (campo ausente conta como 0), sem ler antes: dois moradores tocando ao
  /// mesmo tempo dão +2, sem um apagar o outro.
  @override
  Future<void> confirmarJaBaixou(String id) async {
    await _firestore.collection('pontos').doc(id).update({
      'jaBaixou': FieldValue.increment(1),
    });
  }
}
