// =============================================================================
// ajustes_view_model.dart — ViewModel da tela Bairros e avisos (RF02, D15).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Guarda a busca e os bairros marcados. A View só desenha o que ele expõe.
// =============================================================================
import 'package:flutter/foundation.dart';

import '../../data/servicos/preferencias_servico.dart';
import '../../domain/models/bairro.dart';

/// Estado da escolha de bairros.
class AjustesViewModel extends ChangeNotifier {
  /// Cria o ViewModel com as [preferencias] e o [catalogo] injetados.
  AjustesViewModel({required this.preferencias, required List<Bairro> catalogo})
    : _catalogoOrdenado = [...catalogo]
        ..sort((a, b) => _semAcentos(a.nome).compareTo(_semAcentos(b.nome)));

  /// Onde os bairros escolhidos ficam guardados.
  final PreferenciasServico preferencias;

  final List<Bairro> _catalogoOrdenado;
  List<String> _escolhidos = const [];
  String _busca = '';

  /// Bairros que combinam com a busca, em ordem alfabética.
  List<Bairro> get bairrosVisiveis => [
    for (final bairro in _catalogoOrdenado)
      if (_semAcentos(bairro.nome).contains(_busca)) bairro,
  ];

  /// Diz se o bairro de nome [nome] está marcado.
  bool estaEscolhido(String nome) => _escolhidos.contains(nome);

  /// Lê do celular os bairros já escolhidos.
  Future<void> carregar() async {
    _escolhidos = await preferencias.lerBairrosEscolhidos();
    notifyListeners();
  }

  /// Filtra a lista pelo [texto] digitado.
  void buscar(String texto) {
    _busca = _semAcentos(texto.trim());
    notifyListeners();
  }

  /// Marca o bairro de nome [nome], ou desmarca se já estiver marcado.
  Future<void> alternar(String nome) async {
    final novos = estaEscolhido(nome)
        ? [..._escolhidos.where((escolhido) => escolhido != nome)]
        : [..._escolhidos, nome];

    await preferencias.salvarBairrosEscolhidos(novos);
    // Adendo à D15: sem bairro não há verificação, e o estágio guardado
    // ficaria velho. A próxima leitura volta a ser a primeira (D12).
    if (novos.isEmpty) await preferencias.apagarUltimoEstagio();

    _escolhidos = novos;
    notifyListeners();
  }

  // Letras acentuadas do português e a versão sem acento, na mesma posição.
  static const _comAcento = 'áàâãéêíóôõúüç';
  static const _semAcento = 'aaaaeeiooouuc';

  // Texto em minúsculas e sem acentos, para comparar e buscar.
  static String _semAcentos(String texto) {
    var resultado = texto.toLowerCase();
    for (var i = 0; i < _comAcento.length; i++) {
      resultado = resultado.replaceAll(_comAcento[i], _semAcento[i]);
    }
    return resultado;
  }
}
