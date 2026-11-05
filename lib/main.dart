// =============================================================================
// main.dart — ponto de entrada do aplicativo (equivale ao "public static void
// main" do Java / à classe com @SpringBootApplication).
//
// Aqui o app é "ligado": criamos os serviços reais do portal da Defesa Civil
// e os ENTREGAMOS (injetamos) ao ViewModel — o mesmo papel da injeção por
// construtor do Spring, só que feita "à mão", sem framework. Os testes não
// passam por aqui: eles montam o app com serviços falsos (ver app_test.dart).
// =============================================================================
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/catalogo/catalogo_bairros.dart';
import 'data/servicos/boletim_servico_defesa_civil.dart';
import 'data/servicos/nivel_rio_servico_defesa_civil.dart';
import 'data/servicos/notificador_servico_local.dart';
import 'data/servicos/preferencias_servico_local.dart';
import 'ui/ajustes/ajustes_view_model.dart';
import 'ui/inicio/inicio_view_model.dart';

Future<void> main() async {
  // Necessário porque o plugin de notificações é usado antes do runApp.
  WidgetsFlutterBinding.ensureInitialized();

  final notificador = NotificadorServicoLocal(
    plugin: FlutterLocalNotificationsPlugin(),
  );
  await notificador.iniciar();

  // As duas telas leem os bairros escolhidos do mesmo lugar.
  final preferencias = PreferenciasServicoLocal(
    armazem: SharedPreferencesAsync(),
  );

  // Um só cliente HTTP, compartilhado pelos dois serviços (D09).
  final cliente = http.Client();

  // runApp recebe o widget raiz e o desenha na tela.
  runApp(
    AlertaCheiaApp(
      inicioViewModel: InicioViewModel(
        niveis: NivelRioServicoDefesaCivil(cliente: cliente),
        boletins: BoletimServicoDefesaCivil(cliente: cliente),
        preferencias: preferencias,
      ),
      ajustesViewModel: AjustesViewModel(
        preferencias: preferencias,
        notificador: notificador,
        catalogo: catalogoBairros,
      ),
    ),
  );
}
