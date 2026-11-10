// =============================================================================
// marcar_ponto_view.dart — View da tela "Marcar rua alagada" (RF03, D17).
//
// ETAPA VERDE (ciclo 22a): código mínimo para os testes da localização.
// No MVVM a View só DESENHA o que o ViewModel entrega e chama os métodos dele
// nos botões; não tem regra de negócio. A altura e o envio entram no 22b.
// =============================================================================
import 'package:flutter/material.dart';

import '../../domain/models/leitura_localizacao.dart';
import 'marcar_ponto_view_model.dart';

/// Tela em que o morador marca onde a rua está alagada.
class MarcarPontoView extends StatefulWidget {
  /// Cria a tela com o [viewModel] injetado.
  const MarcarPontoView({super.key, required this.viewModel});

  /// Quem guarda a localização, a altura e o envio.
  final MarcarPontoViewModel viewModel;

  @override
  State<MarcarPontoView> createState() => _MarcarPontoViewState();
}

class _MarcarPontoViewState extends State<MarcarPontoView> {
  // Busca a posição de novo quando o app volta do segundo plano: é o caso de
  // quem foi às configurações ligar a localização ou liberar a permissão
  // (decisão de 10/11). Sem isso, a mensagem antiga ficaria na tela.
  late final AppLifecycleListener _ciclo;

  @override
  void initState() {
    super.initState();
    _ciclo = AppLifecycleListener(onResume: widget.viewModel.buscarLocalizacao);
    // Ao abrir a tela, lê a posição do celular.
    widget.viewModel.buscarLocalizacao();
  }

  @override
  void dispose() {
    // Desliga o "ouvinte" junto com a tela, para não vazar memória.
    _ciclo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Marcar rua alagada')),
      body: SafeArea(
        // Redesenha toda vez que o ViewModel chama notifyListeners().
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('1. Onde está alagado?', style: texto.titleMedium),
              const SizedBox(height: 8),
              _localizacao(),
              const SizedBox(height: 24),
              // A ação do botão entra no ciclo 22b, junto com a altura; até
              // lá ele fica sempre desativado.
              const FilledButton(
                onPressed: null,
                child: Text('Enviar para o mapa'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Um bloco para cada resultado da leitura. O switch numa classe sealed
  // obriga a tratar todos os casos (o compilador avisa se faltar algum).
  Widget _localizacao() {
    final viewModel = widget.viewModel;
    return switch (viewModel.leitura) {
      null => const _Buscando(),
      LocalizacaoObtida() when viewModel.foraDaArea => const Text(
        'Você está fora de Itajaí. Só é possível marcar pontos dentro do '
        'município.',
      ),
      // A precisão vem com casa decimal; a tela mostra metros inteiros.
      LocalizacaoObtida(:final precisaoMetros) => Text(
        'Sua localização atual · precisão de ${precisaoMetros.round()} m',
      ),
      GpsDesligado() => _SemLocalizacao(
        mensagem:
            'A localização do celular está desligada. Ligue para marcar '
            'onde está alagado.',
        botao: 'Ligar a localização',
        acao: viewModel.ligarLocalizacao,
      ),
      PermissaoNegada() => _SemLocalizacao(
        mensagem:
            'Precisamos da sua localização para marcar onde está alagado.',
        botao: 'Permitir localização',
        acao: viewModel.buscarLocalizacao,
      ),
      PermissaoBloqueada() => _SemLocalizacao(
        mensagem:
            'A localização está bloqueada para o Alerta Cheia. Libere nas '
            'configurações do app.',
        botao: 'Abrir configurações',
        acao: viewModel.abrirConfiguracoes,
      ),
      FalhaNaLeitura() => _SemLocalizacao(
        mensagem:
            'Não foi possível achar sua localização. Se puder, vá para um '
            'lugar aberto e tente de novo.',
        botao: 'Tentar de novo',
        acao: viewModel.buscarLocalizacao,
      ),
    };
  }
}

/// Indicador girando e o texto, enquanto o GPS procura a posição. Sem botão.
class _Buscando extends StatelessWidget {
  const _Buscando();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Expanded(child: Text('Buscando sua localização…')),
      ],
    );
  }
}

/// Mensagem de um caso sem localização e o botão que resolve o caso.
class _SemLocalizacao extends StatelessWidget {
  const _SemLocalizacao({
    required this.mensagem,
    required this.botao,
    required this.acao,
  });

  final String mensagem;
  final String botao;

  /// Método do ViewModel chamado pelo botão.
  final VoidCallback acao;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(mensagem),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: acao, child: Text(botao)),
      ],
    );
  }
}
