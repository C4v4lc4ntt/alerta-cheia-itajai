// =============================================================================
// mapa_view.dart — View da aba "Mapa".
//
// No MVVM a View só DESENHA o que o ViewModel entrega; não tem regra de
// negócio. A aba tem o botão "Marcar rua alagada" (RF03, D17, item 7) e, no
// RF04, o mapa dos pontos ativos (MapaDePontos).
//
// Ciclo 23 (verde): a aba recebe [criarMarcarPonto]. Quando vem null, o
// Firebase não ligou: o botão fica desativado, com o aviso aprovado em
// 10/11, e a tela de marcar não abre (o Firestore quebraria o app).
// Ciclo 6c do RF04 (verde): a aba recebe [criarMapa] e cria o MapaViewModel
// ao abrir, descartando-o ao sair (para de ler o Firestore). Sem Firebase
// (null) não há mapa: um mapa vazio pareceria "nenhuma rua alagada"
// (decisão de 15/11).
// Passo 56 (REFATORAR, visual novo): cabeçalho azul e, embaixo do mapa, um
// painel com o lembrete de que os pontos vêm da comunidade e o botão
// "Marcar rua alagada" na largura toda. O comportamento não muda.
// =============================================================================
import 'dart:async';

import 'package:flutter/material.dart';

import '../comum/cabecalho_app.dart';
import '../marcar_ponto/marcar_ponto_view.dart';
import '../marcar_ponto/marcar_ponto_view_model.dart';
import 'mapa_de_pontos.dart';
import 'mapa_view_model.dart';

/// Tela da aba "Mapa".
class MapaView extends StatefulWidget {
  /// Cria a aba. [criarMarcarPonto] e [criarMapa] são null quando o Firebase
  /// não ligou. [mostrarLadrilhos] é false só nos testes (sem internet).
  const MapaView({
    super.key,
    this.criarMarcarPonto,
    this.criarMapa,
    this.mostrarLadrilhos = true,
  });

  /// Cria um ViewModel novo a cada abertura da tela de marcar (como um
  /// Supplier do Java). Um ViewModel reaproveitado guardaria o "enviado"
  /// da vez anterior e o botão de enviar ficaria desativado.
  final MarcarPontoViewModel Function()? criarMarcarPonto;

  /// Cria o ViewModel do mapa, uma vez por abertura da aba (RF04).
  final MapaViewModel Function()? criarMapa;

  /// Liga os ladrilhos do OpenStreetMap (D19).
  final bool mostrarLadrilhos;

  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> {
  // ViewModel do mapa; null quando o Firebase não ligou.
  MapaViewModel? _mapa;

  // Ao abrir a aba: começa a acompanhar os pontos e lê o GPS uma vez (D13).
  @override
  void initState() {
    super.initState();
    final criar = widget.criarMapa;
    if (criar != null) {
      final mapa = criar()..iniciar();
      unawaited(mapa.buscarCentro());
      _mapa = mapa;
    }
  }

  // Ao sair da aba: para de ouvir o Firestore e desliga a revisão.
  @override
  void dispose() {
    _mapa?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapa = _mapa;
    // A Key fixa permite que os testes encontrem esta tela com find.byKey.
    return Scaffold(
      key: const Key('tela_mapa'),
      appBar: const CabecalhoApp('Mapa'),
      body: mapa == null ? _semMapa(context) : _comMapa(mapa),
    );
  }

  // RF04: o mapa ocupa a tela e o botão de marcar fica embaixo.
  Widget _comMapa(MapaViewModel mapa) => Column(
    children: [
      Expanded(
        child: MapaDePontos(
          viewModel: mapa,
          mostrarLadrilhos: widget.mostrarLadrilhos,
        ),
      ),
      _PainelDoMapa(botao: _botaoMarcar(context)),
    ],
  );

  // Sem Firebase: a aba fica como no RF03 (texto, botão e aviso).
  Widget _semMapa(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pontos de alagamento marcados pela comunidade (RF03 e RF04).',
              textAlign: TextAlign.center,
              style: textos.bodyLarge,
            ),
            const SizedBox(height: 24),
            _botaoMarcar(context),
            // A linha do aviso só aparece com o Firebase desligado.
            if (widget.criarMarcarPonto == null) ...[
              const SizedBox(height: 12),
              Text(
                'Não foi possível ligar o envio de marcações. '
                'Feche e abra o app de novo.',
                textAlign: TextAlign.center,
                style: textos.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // onPressed null = botão desativado (o Flutter o desenha apagado e o
  // leitor de tela diz "desativado").
  Widget _botaoMarcar(BuildContext context) {
    final criar = widget.criarMarcarPonto;
    return FilledButton.icon(
      onPressed: criar == null ? null : () => _abrir(context, criar),
      icon: const Icon(Icons.add_location_alt_outlined),
      label: const Text('Marcar rua alagada'),
    );
  }

  // Abre a tela de marcar por cima da aba. O ViewModel é criado ANTES do
  // push: o builder da rota pode rodar mais de uma vez, e cada chamada
  // criaria um ViewModel diferente.
  void _abrir(BuildContext context, MarcarPontoViewModel Function() criar) {
    final viewModel = criar();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MarcarPontoView(viewModel: viewModel),
      ),
    );
  }
}

/// Painel embaixo do mapa: lembrete de que os pontos são da comunidade e o
/// botão de marcar na largura toda.
class _PainelDoMapa extends StatelessWidget {
  const _PainelDoMapa({required this.botao});

  final Widget botao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        // Mesma cor dos cartões; o "??" cobre um tema sem cardTheme.
        color: tema.cardTheme.color ?? tema.colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: tema.colorScheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pontos das últimas 6 h, marcados pela comunidade. '
              'Não é informação oficial.',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            botao,
          ],
        ),
      ),
    );
  }
}
