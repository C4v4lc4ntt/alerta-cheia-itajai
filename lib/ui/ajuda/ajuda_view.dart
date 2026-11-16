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
import '../comum/formatos.dart';
import 'ajuda_view_model.dart';

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
              if (numero != null) _AvisoDiscador(numero: numero),
              for (final contato in contatos)
                _CartaoContato(
                  contato: contato,
                  aoLigar: () => viewModel.ligar(contato.numero),
                ),
              // A fonte não diz quais abrigos estão abertos (D20).
              const _Titulo('Abrigos da Defesa Civil'),
              const Text(
                'Os abrigos abrem conforme a necessidade. '
                'Confirme pelo 199 antes de ir.',
              ),
              for (final regiao in abrigos.entries) ...[
                _Titulo(regiao.key),
                for (final abrigo in regiao.value) _cartaoAbrigo(abrigo),
              ],
              const _Titulo('Abrigos para animais'),
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
    return _CartaoAbrigo(
      abrigo: abrigo,
      aoLigar: telefone == null ? null : () => viewModel.ligar(telefone),
    );
  }
}

/// Título de seção, anunciado como cabeçalho pelo leitor de tela.
class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Semantics(
        header: true,
        child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
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

/// Cartão de um abrigo: nome, endereço e, se houver telefone, o botão.
class _CartaoAbrigo extends StatelessWidget {
  const _CartaoAbrigo({required this.abrigo, required this.aoLigar});

  final Abrigo abrigo;

  /// Nulo quando o abrigo não tem telefone: aí não há botão.
  final VoidCallback? aoLigar;

  @override
  Widget build(BuildContext context) {
    final telefone = abrigo.telefone;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(abrigo.nome, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(abrigo.endereco),
            if (telefone != null) ...[
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: aoLigar,
                icon: const Icon(Icons.phone),
                label: Text(
                  formatarTelefone(telefone),
                  semanticsLabel:
                      'Ligar para ${abrigo.nome}, '
                      '${formatarTelefone(telefone)}',
                ),
              ),
            ],
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
