// =============================================================================
// bloco_localizacao.dart — seção "1. Onde está alagado?" da tela "Marcar rua
// alagada" (RF03, D17).
//
// REFATORAÇÃO (ciclo 22b): saiu de marcar_ponto_view.dart sem mudar o
// comportamento; os testes de marcar_ponto_view_test.dart continuam os mesmos.
// Mostra um bloco para cada resultado da leitura da posição (decisões de
// 10/11) e liga cada botão ao método certo do ViewModel.
// =============================================================================
import 'package:flutter/material.dart';

import '../../domain/models/leitura_localizacao.dart';
import 'marcar_ponto_view_model.dart';

/// O que a tela diz sobre a localização do morador.
class BlocoLocalizacao extends StatelessWidget {
  /// Cria o bloco com o [viewModel] da tela.
  const BlocoLocalizacao({super.key, required this.viewModel});

  /// Quem guarda a leitura da posição e as ações dos botões.
  final MarcarPontoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Um bloco para cada resultado da leitura. O switch numa classe sealed
    // obriga a tratar todos os casos (o compilador avisa se faltar algum).
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
