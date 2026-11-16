// =============================================================================
// ajuda_view.dart — View da aba "Ajuda" (RF05, D20).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// No MVVM a View só DESENHA o que recebe e repassa os toques ao ViewModel.
// Mostra os contatos de emergência; tocar no número abre o discador. Se o
// discador não abrir, um aviso no topo mostra o número para discar à mão.
// =============================================================================
import 'package:flutter/material.dart';

import '../../domain/models/contato_emergencia.dart';
import 'ajuda_view_model.dart';

/// Tela da aba "Ajuda".
class AjudaView extends StatelessWidget {
  /// Cria a tela com o [viewModel] e os [contatos] do catálogo.
  const AjudaView({super.key, required this.viewModel, required this.contatos});

  /// Liga para o número tocado e guarda o número quando o discador falha.
  final AjudaViewModel viewModel;

  /// Contatos de emergência, na ordem em que aparecem.
  final List<ContatoEmergencia> contatos;

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
              if (numero != null) _AvisoDiscador(numero: numero),
              for (final contato in contatos)
                _CartaoContato(
                  contato: contato,
                  aoLigar: () => viewModel.ligar(contato.numero),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Cartão de um contato: nome, descrição e o botão com o número.
class _CartaoContato extends StatelessWidget {
  const _CartaoContato({required this.contato, required this.aoLigar});

  final ContatoEmergencia contato;
  final VoidCallback aoLigar;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contato.nome, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(contato.descricao),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: aoLigar,
              icon: const Icon(Icons.phone),
              // O leitor de tela anuncia "Ligar para Defesa Civil, 199".
              label: Text(
                contato.numero,
                semanticsLabel: 'Ligar para ${contato.nome}, ${contato.numero}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Aviso quando o discador não abriu (ex.: tablet sem telefone).
class _AvisoDiscador extends StatelessWidget {
  const _AvisoDiscador({required this.numero});

  final String numero;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Card(
      color: cores.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Não foi possível abrir o discador. Disque $numero.',
          style: TextStyle(color: cores.onErrorContainer),
        ),
      ),
    );
  }
}
