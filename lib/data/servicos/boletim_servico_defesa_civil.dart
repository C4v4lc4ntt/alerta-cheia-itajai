// =============================================================================
// boletim_servico_defesa_civil.dart — boletim e tábua reais, do portal (D10).
//
// O acesso ao portal fica em portal_defesa_civil.dart (refatoração do
// ciclo 5).
// =============================================================================
import 'package:http/http.dart' as http;

import '../../domain/models/boletim_oficial.dart';
import '../../domain/models/tabua_mare.dart';
import 'boletim_servico.dart';
import 'leitor_boletim_oficial.dart';
import 'leitor_tabua_mare.dart';
import 'portal_defesa_civil.dart';

/// Serviço que busca o boletim e a tábua de marés no portal da Defesa Civil.
class BoletimServicoDefesaCivil implements BoletimServico {
  /// Cria o serviço com o [cliente] HTTP injetado (nos testes, MockClient).
  BoletimServicoDefesaCivil({required this.cliente});

  /// Cliente HTTP usado para falar com o portal.
  final http.Client cliente;

  @override
  Future<BoletimOficial?> buscarBoletim() async => lerBoletimOficial(
    await PortalDefesaCivil(cliente).baixar('/api/v1/situacao-atual'),
  );

  @override
  Future<TabuaMare?> buscarTabuaMare() async => lerTabuaMare(
    await PortalDefesaCivil(cliente).baixar('/api/v1/tabuas-mare/atual'),
  );
}
