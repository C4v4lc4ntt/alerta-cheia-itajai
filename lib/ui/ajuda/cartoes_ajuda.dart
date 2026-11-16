// =============================================================================
// cartoes_ajuda.dart — peças visuais da aba "Ajuda" (RF05, D20).
//
// REFATORAR: separadas do ajuda_view.dart no ciclo 6c2, sem mudar o
// comportamento, para a tela ficar abaixo de ~200 linhas (CLAUDE.md, seção 4).
// São públicas porque, em Dart, o "_" deixa privado só dentro do arquivo.
// =============================================================================
import 'package:flutter/material.dart';

import '../../domain/models/abrigo.dart';
import '../../domain/models/contato_emergencia.dart';
import '../comum/formatos.dart';

/// Título de seção, anunciado como cabeçalho pelo leitor de tela.
class TituloSecao extends StatelessWidget {
  /// Cria o título com o [texto].
  const TituloSecao(this.texto, {super.key});

  /// Texto do título.
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
class CartaoContato extends StatelessWidget {
  /// Cria o cartão do [contato].
  const CartaoContato({
    super.key,
    required this.contato,
    required this.aoLigar,
  });

  /// Contato mostrado no cartão.
  final ContatoEmergencia contato;

  /// Chamado ao tocar no número.
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
class CartaoAbrigo extends StatelessWidget {
  /// Cria o cartão do [abrigo].
  const CartaoAbrigo({super.key, required this.abrigo, required this.aoLigar});

  /// Abrigo mostrado no cartão.
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
class AvisoDiscador extends StatelessWidget {
  /// Cria o aviso com o [numero].
  const AvisoDiscador({super.key, required this.numero});

  /// Número que o discador não conseguiu abrir.
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
