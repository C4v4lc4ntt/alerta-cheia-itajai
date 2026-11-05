// =============================================================================
// criar_servico_de_nivel.dart — escolhe de onde vêm as leituras do app.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Fica num lugar só para a tela e a tarefa em segundo plano usarem a mesma
// escolha. O APK de release sempre usa o portal, sem exceção.
// =============================================================================
import 'package:http/http.dart' as http;

import 'nivel_rio_servico.dart';
import 'nivel_rio_servico_alternado.dart';
import 'nivel_rio_servico_defesa_civil.dart';

/// Cria o serviço de nível: o portal, ou o alternado no modo de teste.
NivelRioServico criarServicoDeNivel({
  required String modoTeste,
  required bool ehRelease,
  required http.Client cliente,
}) {
  if (!ehRelease && modoTeste == 'alternado') {
    return NivelRioServicoAlternado(agora: DateTime.now);
  }
  return NivelRioServicoDefesaCivil(cliente: cliente);
}
