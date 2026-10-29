// =============================================================================
// inicio_view.dart — View da aba "Início" (RF01).
//
// No MVVM a View só DESENHA o que o ViewModel entrega; não tem regra de
// negócio. Os textos e cores vêm de ui/comum/formatos.dart.
// =============================================================================
import 'package:flutter/material.dart';

import '../../domain/models/estagio_alerta.dart';
import '../comum/formatos.dart';
import 'inicio_view_model.dart';
import 'tabua_mare_view.dart';

/// Tela da aba "Início": estágio da cidade, estação mais crítica, boletim
/// oficial e tábua de marés.
class InicioView extends StatefulWidget {
  /// Cria a tela com o [viewModel] injetado.
  const InicioView({super.key, required this.viewModel});

  /// Quem busca os dados e decide o que a tela mostra.
  final InicioViewModel viewModel;

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
            ),
          },
        ),
      ),
    );
  }
}

/// Conteúdo da tela quando os dados chegaram.
class _Pronto extends StatelessWidget {
  const _Pronto({required this.estado, required this.aoAtualizar});

  final InicioPronto estado;

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
          _CartaoEstagio(estagio: estado.estagioCidade),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: Text('${estacao.codigo} · ${estacao.rio}'),
              subtitle: const Text('Estação mais perto da cota'),
              trailing: Text(
                formatarNivel(estado.leituraMaisCritica.nivel),
                style: texto.headlineSmall,
              ),
            ),
          ),
          const SizedBox(height: 12),
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
                    title: Text(
                      '${situacao.estacao.codigo} · ${situacao.estacao.rio}',
                    ),
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
                    Text('Boletim da Defesa Civil', style: texto.labelMedium),
                    const SizedBox(height: 4),
                    Text(boletim.situacao, style: texto.titleMedium),
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

/// Cartão grande com o estágio da cidade e a barra dos 4 estágios.
class _CartaoEstagio extends StatelessWidget {
  const _CartaoEstagio({required this.estagio});

  final EstagioAlerta estagio;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    // O leitor de tela lê uma frase só, em vez do título e da barra soltos.
    return Semantics(
      container: true,
      label: 'Estágio mais grave entre as estações: ${nomeDoEstagio(estagio)}',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: corDoEstagio(estagio),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // D11: diz o que o app calcula; não é declaração oficial.
                'Estágio mais grave entre as estações',
                style: texto.labelMedium?.copyWith(
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                nomeDoEstagio(estagio),
                style: texto.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (final etapa in EstagioAlerta.values)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: etapa.index <= estagio.index
                                    ? Colors.white
                                    : Colors.white38,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              rotuloCurtoDoEstagio(etapa),
                              style: texto.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: etapa == estagio
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
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
