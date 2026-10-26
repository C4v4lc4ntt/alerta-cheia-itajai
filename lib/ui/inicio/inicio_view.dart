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
  @override
  void initState() {
    super.initState();
    // Ao abrir a tela, busca os dados no portal.
    widget.viewModel.carregar();
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
            final InicioPronto pronto => _Pronto(estado: pronto),
          },
        ),
      ),
    );
  }
}

/// Conteúdo da tela quando os dados chegaram.
class _Pronto extends StatelessWidget {
  const _Pronto({required this.estado});

  final InicioPronto estado;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final estacao = estado.estacaoMaisCritica;
    final boletim = estado.boletim;
    final tabua = estado.tabuaMare;

    return ListView(
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
        Text(
          'Atualizado às ${horaDeBrasilia(estado.atualizadoEm)} · '
          'Dados: Defesa Civil de Itajaí',
          style: texto.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
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
      label: 'Estágio em Itajaí: ${nomeDoEstagio(estagio)}',
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
                'ESTÁGIO EM ITAJAÍ',
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
