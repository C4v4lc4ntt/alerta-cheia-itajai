// =============================================================================
// discador_servico_url_launcher.dart — discador com o url_launcher (RF05, D20).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// A função que abre o endereço é injetada: no app é o launchUrl do pacote; nos
// testes, uma versão falsa, para nunca abrir o discador de verdade.
// =============================================================================
import 'package:url_launcher/url_launcher.dart';

import 'discador_servico.dart';

/// [DiscadorServico] que abre o endereço "tel:" pelo url_launcher.
class DiscadorServicoUrlLauncher implements DiscadorServico {
  /// Cria o discador. Sem [abrir], usa o `launchUrl` do url_launcher (passado
  /// como referência, como o `String::length` do Java).
  DiscadorServicoUrlLauncher({this.abrir = launchUrl});

  /// Abre o endereço e devolve se conseguiu.
  final Future<bool> Function(Uri) abrir;

  @override
  Future<bool> ligar(String numero) async {
    try {
      return await abrir(Uri(scheme: 'tel', path: numero));
    } on Exception {
      // Ex.: PlatformException quando não há app de telefone. A tela mostra o
      // número para discar à mão, em vez de quebrar.
      return false;
    }
  }
}
