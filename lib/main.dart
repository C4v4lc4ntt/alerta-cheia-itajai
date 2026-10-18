// =============================================================================
// main.dart — ponto de entrada do aplicativo (equivale ao "public static void
// main" do Java / à classe com @SpringBootApplication).
//
// Aqui só "ligamos" o app. Toda a configuração visual e a navegação ficam em
// app.dart, para que os testes consigam montar o app sem passar por aqui.
// =============================================================================
import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  // runApp recebe o widget raiz e o desenha na tela.
  //
  // Mais adiante (RF01/RF02) é aqui que vamos CRIAR o serviço simulado de
  // nível do rio e ENTREGAR (injetar) para os ViewModels — o mesmo papel da
  // injeção por construtor do Spring, só que feita "à mão", sem framework.
  runApp(const AlertaCheiaApp());
}
