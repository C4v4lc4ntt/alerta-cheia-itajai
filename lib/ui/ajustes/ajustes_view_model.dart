// =============================================================================
// ajustes_view_model.dart — ViewModel da tela Bairros e avisos (RF02, D15).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Guarda a busca e os bairros marcados. A View só desenha o que ele expõe.
// =============================================================================
import 'package:flutter/foundation.dart';

import '../../data/catalogo/catalogo_estacoes.dart';
import '../../data/servicos/agendador_verificacao.dart';
import '../../data/servicos/notificador_servico.dart';
import '../../data/servicos/preferencias_servico.dart';
import '../../domain/models/bairro.dart';
import '../../domain/regras/sem_acentos.dart';

/// Estado da escolha de bairros.
class AjustesViewModel extends ChangeNotifier {
  /// Cria o ViewModel com os serviços e o [catalogo] injetados.
  AjustesViewModel({
    required this.preferencias,
    required this.notificador,
    required this.agendador,
    required List<Bairro> catalogo,
  }) : _catalogoOrdenado = [...catalogo]
         ..sort((a, b) => semAcentos(a.nome).compareTo(semAcentos(b.nome)));

  /// Onde os bairros escolhidos ficam guardados.
  final PreferenciasServico preferencias;

  /// Quem pede ao sistema a permissão para notificar.
  final NotificadorServico notificador;

  /// Quem liga e desliga a verificação em segundo plano (D15).
  final AgendadorVerificacao agendador;

  final List<Bairro> _catalogoOrdenado;
  List<String> _escolhidos = const [];
  String _busca = '';
  bool _permissaoNegada = false;

  /// Bairros que combinam com a busca, em ordem alfabética.
  List<Bairro> get bairrosVisiveis => [
    for (final bairro in _catalogoOrdenado)
      if (semAcentos(bairro.nome).contains(_busca)) bairro,
  ];

  /// Diz se o bairro de nome [nome] está marcado.
  bool estaEscolhido(String nome) => _escolhidos.contains(nome);

  /// Estações próximas do [bairro], com o código e o rio de cada uma.
  String estacoesDe(Bairro bairro) => [
    for (final codigo in bairro.estacoesProximas)
      for (final estacao in catalogoEstacoes)
        if (estacao.codigo == codigo) '${estacao.codigo} · ${estacao.rio}',
  ].join(', ');

  /// Diz se há bairro escolhido, mas o sistema não deixa notificar.
  bool get permissaoNegada => _permissaoNegada;

  /// Lê do celular os bairros já escolhidos e confere a permissão, porque o
  /// morador pode tê-la desligado nos ajustes do celular.
  Future<void> carregar() async {
    _escolhidos = await preferencias.lerBairrosEscolhidos();
    notifyListeners();
    if (_escolhidos.isNotEmpty) await _conferirPermissao();
  }

  /// Filtra a lista pelo [texto] digitado.
  void buscar(String texto) {
    _busca = semAcentos(texto.trim());
    notifyListeners();
  }

  /// Marca o bairro de nome [nome], ou desmarca se já estiver marcado.
  Future<void> alternar(String nome) async {
    final marcou = !estaEscolhido(nome);
    final novos = estaEscolhido(nome)
        ? [..._escolhidos.where((escolhido) => escolhido != nome)]
        : [..._escolhidos, nome];

    await preferencias.salvarBairrosEscolhidos(novos);
    // Adendo à D15: sem bairro não há verificação, e o estágio guardado
    // ficaria velho. A próxima leitura volta a ser a primeira (D12).
    if (novos.isEmpty) {
      await preferencias.apagarUltimoEstagio();
      await agendador.desligar();
    } else {
      await agendador.ligar();
    }

    _escolhidos = novos;
    if (novos.isEmpty) _permissaoNegada = false;
    notifyListeners();
    if (marcou) await _conferirPermissao();
  }

  // Pede a permissão e só avisa a tela se a resposta mudar o que ela mostra.
  Future<void> _conferirPermissao() async {
    final negada = !await notificador.pedirPermissao();
    if (negada == _permissaoNegada) return;
    _permissaoNegada = negada;
    notifyListeners();
  }
}
