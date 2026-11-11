// =============================================================================
// pontos_servico_firestore.dart — envio dos pontos de alagamento para a
// coleção "pontos" do Cloud Firestore (RF03, D17).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// O FirebaseFirestore chega pelo construtor: no app é o real, nos testes é o
// FakeFirebaseFirestore (injeção por construtor, como no Spring).
// =============================================================================
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/ponto_alagamento.dart';
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
}
