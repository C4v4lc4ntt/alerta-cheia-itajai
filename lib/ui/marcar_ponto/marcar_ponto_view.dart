// =============================================================================
// marcar_ponto_view.dart — View da tela "Marcar rua alagada" (RF03, D17).
//
// ETAPA VERDE: código mínimo para os testes passarem. Ciclo 22a: a
// localização. Ciclo 22b: a altura da água, o envio, a nota e o rodapé.
// No MVVM a View só DESENHA o que o ViewModel entrega e chama os métodos dele
// nos botões; não tem regra de negócio.
// =============================================================================
import 'package:flutter/material.dart';

import '../../domain/models/altura_agua.dart';
import '../../domain/models/leitura_localizacao.dart';
import 'estado_envio.dart';
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
    final viewModel = widget.viewModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Marcar rua alagada')),
      // Fora da lista, para o caminho do 199, do 193 e do 192 ficar sempre
      // visível, sem rolar a tela (CLAUDE.md §7).
      bottomNavigationBar: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Em perigo? Ligue 199, 193 ou 192.'),
        ),
      ),
      body: SafeArea(
        // Redesenha toda vez que o ViewModel chama notifyListeners().
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('1. Onde está alagado?', style: texto.titleMedium),
              const SizedBox(height: 8),
              _localizacao(),
              const SizedBox(height: 24),
              Text('2. Qual a altura da água?', style: texto.titleMedium),
              const SizedBox(height: 8),
              _alturas(),
              const SizedBox(height: 24),
              const Text(
                'Não pedimos seu nome. A marcação fica no mapa por 6 horas. '
                'Se 3 moradores disserem que a água baixou, ela some antes.',
              ),
              const SizedBox(height: 16),
              // Desativado (onPressed null) quando o ViewModel não deixa
              // enviar: sem posição válida, sem altura, ou durante e depois
              // do envio (D17 e decisão de 10/11).
              FilledButton(
                onPressed: viewModel.podeEnviar ? viewModel.enviar : null,
                child: Text(
                  viewModel.envio == EstadoEnvio.enviando
                      ? 'Enviando…'
                      : 'Enviar para o mapa',
                ),
              ),
              const SizedBox(height: 8),
              ..._resultadoDoEnvio(),
            ],
          ),
        ),
      ),
    );
  }

  // Uma opção por altura. O ChoiceChip já diz "selecionado" ao leitor de
  // tela e tem área de toque de 48 px.
  Widget _alturas() {
    final viewModel = widget.viewModel;
    return Wrap(
      spacing: 8,
      children: [
        for (final altura in AlturaAgua.values)
          ChoiceChip(
            label: Text(_rotuloDaAltura(altura)),
            selected: viewModel.altura == altura,
            onSelected: (_) => viewModel.escolherAltura(altura),
          ),
      ],
    );
  }

  // Mensagem depois do envio; nada antes de enviar nem durante o envio.
  List<Widget> _resultadoDoEnvio() => switch (widget.viewModel.envio) {
    EstadoEnvio.enviado => const [
      Text('Pronto! A marcação foi enviada para o mapa.'),
    ],
    EstadoEnvio.erro => const [
      Text(
        'Não foi possível enviar agora. Confira a internet e tente de novo.',
      ),
    ],
    EstadoEnvio.nenhum || EstadoEnvio.enviando => const [],
  };

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

/// Texto de cada opção de altura (aprovado em 09/11).
String _rotuloDaAltura(AlturaAgua altura) => switch (altura) {
  AlturaAgua.canela => 'Canela · até 20 cm',
  AlturaAgua.joelho => 'Joelho · 20 a 50 cm',
  AlturaAgua.cintura => 'Cintura · mais de 50 cm',
};

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
