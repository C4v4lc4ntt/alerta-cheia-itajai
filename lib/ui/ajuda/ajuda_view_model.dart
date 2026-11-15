// =============================================================================
// ajuda_view_model.dart — ViewModel da aba Ajuda (RF05, D20).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// A View chama [AjudaViewModel.ligar] quando o morador toca num número. Se o
// discador não abrir (ex.: tablet sem telefone), a View mostra o número para
// discar à mão, em vez de não fazer nada.
// =============================================================================
import 'package:flutter/foundation.dart';

import '../../data/servicos/discador_servico.dart';

/// Estado da aba Ajuda.
class AjudaViewModel extends ChangeNotifier {
  /// Cria o ViewModel com o discador (real no app, falso nos testes). Quem
  /// chama escreve `discador:`; o `_` só deixa o campo privado.
  AjudaViewModel({required this._discador});

  final DiscadorServico _discador;

  String? _numeroParaDiscarAMao;

  /// Número que o discador não conseguiu abrir; `null` quando não há falha.
  String? get numeroParaDiscarAMao => _numeroParaDiscarAMao;

  /// Abre o discador com [numero]. Se não abrir, guarda o número para a View
  /// mostrar; se abrir, apaga o de uma falha anterior. Avisa a View nos dois
  /// casos.
  Future<void> ligar(String numero) async {
    final abriu = await _discador.ligar(numero);
    _numeroParaDiscarAMao = abriu ? null : numero;
    notifyListeners();
  }
}
