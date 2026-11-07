// =============================================================================
// tarefa_verificacao.dart — a verificação com o app fechado, no Android (D14).
//
// INFRAESTRUTURA: como o main.dart, só liga as peças, que já têm testes. Se a
// tarefa roda de verdade é conferido no celular, no passo 49.
// O Android chama esta função num ambiente separado da tela: nada do main.dart
// existe aqui, então tudo é criado de novo, inclusive o notificador.
// =============================================================================
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'data/repositorios/verificador_estagio.dart';
import 'data/servicos/criar_servico_de_nivel.dart';
import 'data/servicos/notificador_servico_local.dart';
import 'data/servicos/preferencias_servico_local.dart';

/// Modo de teste, definido ao compilar com --dart-define=MODO_TESTE=alternado.
const modoTeste = String.fromEnvironment('MODO_TESTE');

/// Ponto de entrada da tarefa em segundo plano.
///
/// O @pragma impede que a compilação de release remova esta função, porque
/// nenhum código do app a chama diretamente: quem chama é o Android.
@pragma('vm:entry-point')
void despacharVerificacao() {
  Workmanager().executeTask((_, _) async {
    // Liga os pacotes neste ambiente separado.
    DartPluginRegistrant.ensureInitialized();

    final notificador = NotificadorServicoLocal(
      plugin: FlutterLocalNotificationsPlugin(),
    );
    await notificador.iniciar();

    final cliente = http.Client();
    await VerificadorEstagio(
      niveis: criarServicoDeNivel(
        modoTeste: modoTeste,
        ehRelease: kReleaseMode,
        cliente: cliente,
      ),
      preferencias: PreferenciasServicoLocal(armazem: SharedPreferencesAsync()),
      notificador: notificador,
    ).verificar();
    cliente.close();

    // A verificação nunca lança erro; a próxima tenta de novo (D14).
    return true;
  });
}
