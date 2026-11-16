// =============================================================================
// ajuda_view.dart — View da aba "Ajuda" (RF05, D20).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// No MVVM a View só DESENHA o que recebe e repassa os toques ao ViewModel.
// Mostra os contatos de emergência e os abrigos; tocar num número abre o
// discador. Se o discador não abrir, um aviso no topo mostra o número para
// discar à mão.
// =============================================================================
import 'package:flutter/material.dart';

import '../../domain/models/abrigo.dart';
import '../../domain/models/contato_emergencia.dart';
import 'ajuda_view_model.dart';
import 'cartoes_ajuda.dart';

/// Tela da aba "Ajuda".
class AjudaView extends StatelessWidget {
  /// Cria a tela com o [viewModel] e os dados dos catálogos.
  const AjudaView({
    super.key,
    required this.viewModel,
    required this.contatos,
    this.abrigos = const {},
    this.abrigosAnimais = const [],
  });

  /// Liga para o número tocado e guarda o número quando o discador falha.
  final AjudaViewModel viewModel;

  /// Contatos de emergência, na ordem em que aparecem.
  final List<ContatoEmergencia> contatos;

  /// Abrigos de pessoas por região (CRAS), na ordem de prioridade.
  final Map<String, List<Abrigo>> abrigos;

  /// Abrigos para animais domésticos.
  final List<Abrigo> abrigosAnimais;

  @override
  Widget build(BuildContext context) {
    // A Key fixa permite que os testes encontrem esta tela com find.byKey.
    return Scaffold(
      key: const Key('tela_ajuda'),
      appBar: AppBar(title: const Text('Ajuda')),
      // ListenableBuilder redesenha a lista quando o ViewModel avisa.
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final numero = viewModel.numeroParaDiscarAMao;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (numero != null) AvisoDiscador(numero: numero),
              for (final contato in contatos)
                CartaoContato(
                  contato: contato,
                  aoLigar: () => viewModel.ligar(contato.numero),
                ),
              // A fonte não diz quais abrigos estão abertos (D20).
              const TituloSecao('Abrigos da Defesa Civil'),
              const Text(
                'Os abrigos abrem conforme a necessidade. '
                'Confirme pelo 199 antes de ir.',
              ),
              for (final regiao in abrigos.entries) ...[
                TituloSecao(regiao.key),
                for (final abrigo in regiao.value) _cartaoAbrigo(abrigo),
              ],
              const TituloSecao('Abrigos para animais'),
              for (final abrigo in abrigosAnimais) _cartaoAbrigo(abrigo),
            ],
          );
        },
      ),
    );
  }

  // Cartão do abrigo; o botão de ligar só existe quando há telefone.
  Widget _cartaoAbrigo(Abrigo abrigo) {
    final telefone = abrigo.telefone;
    return CartaoAbrigo(
      abrigo: abrigo,
      aoLigar: telefone == null ? null : () => viewModel.ligar(telefone),
    );
  }
}
