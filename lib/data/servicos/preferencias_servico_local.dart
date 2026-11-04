// =============================================================================
// preferencias_servico_local.dart — dados do morador guardados no celular com
// o pacote shared_preferences (D14).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// SharedPreferencesAsync lê do armazenamento a cada chamada, sem cache, porque
// a tarefa em segundo plano e a tela rodam separadas.
// =============================================================================
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/estagio_alerta.dart';
import 'preferencias_servico.dart';

/// Implementação real de [PreferenciasServico].
class PreferenciasServicoLocal implements PreferenciasServico {
  /// Cria o serviço com o [armazem] injetado.
  PreferenciasServicoLocal({required this.armazem});

  /// Armazenamento do celular.
  final SharedPreferencesAsync armazem;

  static const _chaveBairros = 'bairros_escolhidos';
  static const _chaveUltimoEstagio = 'ultimo_estagio';

  @override
  Future<List<String>> lerBairrosEscolhidos() async {
    return await armazem.getStringList(_chaveBairros) ?? const [];
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
}
