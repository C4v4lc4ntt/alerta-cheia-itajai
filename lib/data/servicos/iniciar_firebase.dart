// =============================================================================
// iniciar_firebase.dart — RF03/D17: liga o app ao Firebase sem derrubar o
// resto. Se a inicialização falhar, o app abre do mesmo jeito (o RF01 e o RF02
// não dependem do Firebase) e quem precisar do Firebase consulta o resultado.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// =============================================================================

/// Executa a [inicializar] (no app, `Firebase.initializeApp`) uma vez.
///
/// Devolve `true` se o Firebase ficou pronto e `false` se a inicialização
/// lançou uma exceção. A exceção não é repassada, para não impedir o app de
/// abrir.
Future<bool> iniciarFirebase(Future<void> Function() inicializar) async {
  try {
    await inicializar();
    return true;
  } on Exception {
    // "on Exception" pega as falhas esperadas (FirebaseException e
    // PlatformException são Exception). Um Error, que indica defeito no
    // código, continua aparecendo, como um RuntimeException × Error no Java.
    return false;
  }
}
