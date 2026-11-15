// =============================================================================
// main.dart — ponto de entrada do aplicativo (equivale ao "public static void
// main" do Java / à classe com @SpringBootApplication).
//
// Aqui o app é "ligado": criamos os serviços reais do portal da Defesa Civil
// e os ENTREGAMOS (injetamos) ao ViewModel — o mesmo papel da injeção por
// construtor do Spring, só que feita "à mão", sem framework. Os testes não
// passam por aqui: eles montam o app com serviços falsos (ver app_test.dart).
// =============================================================================
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'data/catalogo/catalogo_bairros.dart';
import 'data/repositorios/verificador_estagio.dart';
import 'data/servicos/agendador_verificacao_local.dart';
import 'data/servicos/boletim_servico_defesa_civil.dart';
import 'data/servicos/criar_servico_de_nivel.dart';
import 'data/servicos/iniciar_firebase.dart';
import 'data/servicos/localizacao_servico_geolocator.dart';
import 'data/servicos/notificador_servico_local.dart';
import 'data/servicos/pontos_servico_firestore.dart';
import 'data/servicos/preferencias_servico_local.dart';
import 'firebase_options.dart';
import 'tarefa_verificacao.dart';
import 'ui/ajustes/ajustes_view_model.dart';
import 'ui/inicio/inicio_view_model.dart';
import 'ui/marcar_ponto/marcar_ponto_view_model.dart';

Future<void> main() async {
  // Necessário porque o plugin de notificações é usado antes do runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // RF03/D17: liga o Firebase. Se falhar, o app abre do mesmo jeito e o
  // botão "Marcar rua alagada" aparece desativado (decisão de 10/11).
  final firebaseLigado = await iniciarFirebase(
    () =>
        Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  );

  final notificador = NotificadorServicoLocal(
    plugin: FlutterLocalNotificationsPlugin(),
  );
  await notificador.iniciar();

  // D14: precisa vir antes de qualquer pedido para ligar a tarefa. No iOS a
  // verificação acontece só com o app em uso.
  if (Platform.isAndroid) {
    await Workmanager().initialize(despacharVerificacao);
  }

  // As duas telas leem os bairros escolhidos do mesmo lugar.
  final preferencias = PreferenciasServicoLocal(
    armazem: SharedPreferencesAsync(),
  );

  // Um só cliente HTTP, compartilhado pelos dois serviços (D09).
  final cliente = http.Client();
  final niveis = criarServicoDeNivel(
    modoTeste: modoTeste,
    ehRelease: kReleaseMode,
    cliente: cliente,
  );

  // A mesma verificação do segundo plano, com o app em uso (D14).
  final verificador = VerificadorEstagio(
    niveis: niveis,
    preferencias: preferencias,
    notificador: notificador,
  );

  // runApp recebe o widget raiz e o desenha na tela.
  runApp(
    AlertaCheiaApp(
      inicioViewModel: InicioViewModel(
        niveis: niveis,
        boletins: BoletimServicoDefesaCivil(cliente: cliente),
        preferencias: preferencias,
        verificar: verificador.verificar,
      ),
      ajustesViewModel: AjustesViewModel(
        preferencias: preferencias,
        notificador: notificador,
        agendador: AgendadorVerificacaoLocal(
          workmanager: Workmanager(),
          ehAndroid: Platform.isAndroid,
        ),
        catalogo: catalogoBairros,
      ),
      // RF03 (ciclo 23): cada abertura da tela de marcar ganha um ViewModel
      // novo, com o GPS e o Firestore de verdade. Com o Firebase desligado
      // vai null: chamar FirebaseFirestore.instance quebraria o app.
      criarMarcarPonto: firebaseLigado
          ? () => MarcarPontoViewModel(
              localizacao: LocalizacaoServicoGeolocator(
                GeolocatorPlatform.instance,
              ),
              pontos: PontosServicoFirestore(FirebaseFirestore.instance),
              agora: DateTime.now,
            )
          : null,
    ),
  );
}
