// =============================================================================
// discador_falso.dart — versão de DiscadorServico para os testes (RF05).
//
// Não abre nada: anota os números e as páginas pedidas e devolve o que o
// teste escolher, para conferir o que cada toque da tela pediu.
// =============================================================================
import 'package:alerta_cheia_itajai/data/servicos/discador_servico.dart';

/// Discador em memória.
class DiscadorFalso implements DiscadorServico {
  /// Resposta de [ligar]: true = o discador "abriu". O teste pode trocar.
  bool abre = true;

  /// Números pedidos, na ordem.
  final List<String> numeros = [];

  @override
  Future<bool> ligar(String numero) async {
    numeros.add(numero);
    return abre;
  }

  /// Páginas pedidas pelo [abrirSite], na ordem (RF06, ciclo 10).
  final List<Uri> sites = [];

  @override
  Future<bool> abrirSite(Uri endereco) async {
    sites.add(endereco);
    return abre;
  }
}
