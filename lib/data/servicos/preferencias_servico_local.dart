// =============================================================================
// preferencias_servico_local.dart — dados do morador guardados no celular com
// o pacote shared_preferences (D14).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// SharedPreferencesAsync lê do armazenamento a cada chamada, sem cache, porque
// a tarefa em segundo plano e a tela rodam separadas.
// Passo 57 (D21), ETAPA VERDE: a última consulta fica guardada como texto
// JSON (a conversão está em consulta_json.dart).
// =============================================================================
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/consulta_guardada.dart';
import '../../domain/models/estagio_alerta.dart';
import 'consulta_json.dart';
import 'preferencias_servico.dart';

/// Implementação real de [PreferenciasServico].
class PreferenciasServicoLocal implements PreferenciasServico {
  /// Cria o serviço com o [armazem] injetado.
  PreferenciasServicoLocal({required this.armazem});

  /// Armazenamento do celular.
  final SharedPreferencesAsync armazem;

  static const _chaveBairros = 'bairros_escolhidos';
  static const _chaveUltimoEstagio = 'ultimo_estagio';
  static const _chaveUltimaConsulta = 'ultima_consulta';

  @override
  Future<List<String>> lerBairrosEscolhidos() async {
    return await armazem.getStringList(_chaveBairros) ?? const [];
  }

  @override
  Future<void> salvarBairrosEscolhidos(List<String> bairros) {
    return armazem.setStringList(_chaveBairros, bairros);
  }

  @override
  Future<EstagioAlerta?> lerUltimoEstagio() async {
    final nome = await armazem.getString(_chaveUltimoEstagio);
    // asNameMap() é o mapa nome → valor do enum; desconhecido vira null.
    return EstagioAlerta.values.asNameMap()[nome];
  }

  @override
  Future<void> salvarUltimoEstagio(EstagioAlerta estagio) {
    return armazem.setString(_chaveUltimoEstagio, estagio.name);
  }

  @override
  Future<void> apagarUltimoEstagio() {
    return armazem.remove(_chaveUltimoEstagio);
  }

  @override
  Future<ConsultaGuardada?> lerUltimaConsulta() async {
    final texto = await armazem.getString(_chaveUltimaConsulta);
    return texto == null ? null : consultaDeJson(texto);
  }

  @override
  Future<void> salvarUltimaConsulta(ConsultaGuardada consulta) {
    return armazem.setString(_chaveUltimaConsulta, consultaParaJson(consulta));
  }
}
