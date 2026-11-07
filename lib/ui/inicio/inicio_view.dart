// =============================================================================
// inicio_view.dart — View da aba "Início" (RF01).
//
// No MVVM a View só DESENHA o que o ViewModel entrega; não tem regra de
// negócio. Os textos e cores vêm de ui/comum/formatos.dart.
// =============================================================================
import 'package:flutter/material.dart';

import '../comum/formatos.dart';
import 'cartao_bairro.dart';
import 'cartao_oficial.dart';
import 'inicio_view_model.dart';
import 'tabua_mare_view.dart';

/// Tela da aba "Início": estágio da cidade, estação mais crítica, boletim
/// oficial e tábua de marés.
class InicioView extends StatefulWidget {
  /// Cria a tela com o [viewModel] injetado.
  const InicioView({
    super.key,
    required this.viewModel,
    required this.aoEscolherBairro,
  });

  /// Quem busca os dados e decide o que a tela mostra.
  final InicioViewModel viewModel;

  /// Chamado ao tocar em "Escolher bairro"; quem troca de aba é o app.
  final VoidCallback aoEscolherBairro;

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  // Busca de novo quando o app volta do segundo plano: no Android, "fechar"
  // o app costuma só escondê-lo, e a tela não é recriada ao voltar.
  late final AppLifecycleListener _ciclo;

  @override
  void initState() {
    super.initState();
    _ciclo = AppLifecycleListener(onResume: widget.viewModel.carregar);
    // Ao abrir a tela, busca os dados no portal.
    widget.viewModel.carregar();
  }

  @override
  void dispose() {
    // Desliga o "ouvinte" junto com a tela, para não vazar memória.
    _ciclo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A Key fixa permite que os testes encontrem esta tela com find.byKey.
      key: const Key('tela_inicio'),
      body: SafeArea(
        // Redesenha toda vez que o ViewModel chama notifyListeners().
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) => switch (widget.viewModel.estado) {
            InicioCarregando() => const Center(
              child: CircularProgressIndicator(),
            ),
            InicioErro(:final mensagem) => _Erro(
              mensagem: mensagem,
              aoTentarDeNovo: widget.viewModel.carregar,
            ),
            final InicioPronto pronto => _Pronto(
              estado: pronto,
              aoAtualizar: widget.viewModel.carregar,
              aoEscolherBairro: widget.aoEscolherBairro,
            ),
          },
        ),
      ),
    );
  }
}

/// Cartão que convida o morador a escolher um bairro (D15).
class _ConviteBairro extends StatelessWidget {
  const _ConviteBairro({required this.aoEscolherBairro});

  final VoidCallback aoEscolherBairro;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escolha um bairro para receber avisos quando o estágio mudar.',
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: aoEscolherBairro,
              child: const Text('Escolher bairro'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Conteúdo da tela quando os dados chegaram.
class _Pronto extends StatelessWidget {
  const _Pronto({
    required this.estado,
    required this.aoAtualizar,
    required this.aoEscolherBairro,
  });

  final InicioPronto estado;

  /// Chamado ao tocar em "Escolher bairro".
  final VoidCallback aoEscolherBairro;

  /// Chamado quando o morador puxa a tela para baixo.
  final Future<void> Function() aoAtualizar;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final estacao = estado.estacaoMaisCritica;
    final boletim = estado.boletim;
    final tabua = estado.tabuaMare;

    // Puxar para baixo atualiza. "AlwaysScrollable" deixa puxar mesmo
    // quando o conteúdo cabe inteiro na tela.
    return RefreshIndicator(
      onRefresh: aoAtualizar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // D16: a situação oficial em destaque.
          CartaoOficial(boletim: boletim, estagioCidade: estado.estagioCidade),
          const SizedBox(height: 12),
          if (estado.semBairroEscolhido) ...[
            _ConviteBairro(aoEscolherBairro: aoEscolherBairro),
            const SizedBox(height: 12),
          ],
          // Sem bairro, a estação mais crítica tem o cartão dela.
          if (estado.bairros.isEmpty) ...[
            Card(
              child: ListTile(
                title: Text(nomeDaEstacao(estacao)),
                subtitle: const Text('Estação mais perto da cota'),
                trailing: Text(
                  formatarNivel(estado.leituraMaisCritica.nivel),
                  style: texto.headlineSmall,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Com bairro, um cartão por bairro escolhido (D16).
          for (final cartao in estado.bairros) ...[
            CartaoBairroView(cartao: cartao),
            const SizedBox(height: 12),
          ],
          // A estação mais grave nunca fica escondida.
          if (estado.maisCriticaForaDosBairros) ...[
            Text(
              'Estação mais grave da cidade: ${nomeDaEstacao(estacao)} · '
              '${formatarNivel(estado.leituraMaisCritica.nivel)} · '
              '${nomeDoEstagio(estado.estacoes.first.estagio)}',
              style: texto.bodyMedium,
            ),
            const SizedBox(height: 12),
          ],
          Card(
            child: ExpansionTile(
              title: Text('Todas as estações (${estado.estacoes.length})'),
              children: [
                for (final situacao in estado.estacoes)
                  ListTile(
                    dense: true,
                    // A cor nunca é a única informação: o estágio vem escrito.
                    leading: Icon(
                      Icons.circle,
                      size: 14,
                      color: corDoEstagio(situacao.estagio),
                    ),
                    title: Text(nomeDaEstacao(situacao.estacao)),
                    subtitle: Text(nomeDoEstagio(situacao.estagio)),
                    trailing: Text(formatarNivel(situacao.leitura.nivel)),
                  ),
              ],
            ),
          ),
          if (boletim != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A situação já está no cartão grande (D16).
                    Text('Boletim da Defesa Civil', style: texto.labelMedium),
                    const SizedBox(height: 8),
                    Text(boletim.texto),
                  ],
                ),
              ),
            ),
          ],
          if (tabua != null) ...[
            const SizedBox(height: 12),
            // D10: no começo do mês o portal pode devolver a tábua anterior.
            if (!tabua.doMesAtual) ...[
              Text(
                'A tábua deste mês ainda não foi publicada. '
                'Mostrando a de ${tabua.mesReferencia}.',
                style: texto.bodySmall,
              ),
              const SizedBox(height: 4),
            ],
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TabuaMareView(tabua: tabua),
                ),
              ),
              icon: const Icon(Icons.waves),
              label: const Text('Ver tábua de marés'),
            ),
          ],
          const SizedBox(height: 16),
          // Quando o rio foi medido e quando o app consultou o portal.
          Text(
            'Medido às ${horaDeBrasilia(estado.atualizadoEm)} · '
            'consultado às ${horaDeBrasilia(estado.consultadoEm)}',
            style: texto.bodySmall,
            textAlign: TextAlign.center,
          ),
          Text(
            'Dados: Defesa Civil de Itajaí',
            style: texto.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Mensagem de erro com o botão para tentar de novo.
class _Erro extends StatelessWidget {
  const _Erro({required this.mensagem, required this.aoTentarDeNovo});

  final String mensagem;
  final VoidCallback aoTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 16),
            Text(mensagem, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: aoTentarDeNovo,
              child: const Text('Tentar de novo'),
            ),
          ],
        ),
      ),
    );
  }
}
