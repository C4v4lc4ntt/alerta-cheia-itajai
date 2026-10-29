// =============================================================================
// nivel_rio_servico_defesa_civil.dart — níveis reais, do portal (D07).
//
// Baixa o app.json público do portal da Defesa Civil de Itajaí (D09) e usa
// o leitor do ciclo 4b (parte a) para criar as leituras. O acesso ao portal
// fica em portal_defesa_civil.dart (refatoração do ciclo 5).
// =============================================================================
import 'package:http/http.dart' as http;

import '../../domain/models/leitura_nivel.dart';
import 'leitor_app_json.dart';
import 'nivel_rio_servico.dart';
import 'portal_defesa_civil.dart';

// Quem já importava PortalIndisponivel daqui continua funcionando.
export 'portal_defesa_civil.dart' show PortalIndisponivel;

/// Serviço de nível que busca os dados reais no portal da Defesa Civil.
class NivelRioServicoDefesaCivil implements NivelRioServico {
  /// Cria o serviço com o [cliente] HTTP injetado (nos testes, MockClient).
  NivelRioServicoDefesaCivil({required this.cliente});

  /// Cliente HTTP usado para falar com o portal.
  final http.Client cliente;

  @override
  Future<List<LeituraNivel>> buscarLeituras() async {
    final conteudo = await PortalDefesaCivil(cliente)
        .baixar('/data/current/app.json');
    return lerLeiturasDoAppJson(conteudo);
  }
}
