// =============================================================================
// mapa_view.dart — View da aba "Mapa".
//
// No MVVM a View só DESENHA o que o ViewModel entrega; não tem regra de
// negócio. O mapa em si chega no RF04; por enquanto a aba mostra o texto
// provisório e o botão "Marcar rua alagada" (RF03, D17, item 7).
//
// Ciclo 23 (verde): a aba recebe [criarMarcarPonto]. Quando vem null, o
// Firebase não ligou: o botão fica desativado, com o aviso aprovado em
// 10/11, e a tela de marcar não abre (o Firestore quebraria o app).
// =============================================================================
import 'package:flutter/material.dart';

import '../marcar_ponto/marcar_ponto_view.dart';
import '../marcar_ponto/marcar_ponto_view_model.dart';

/// Tela da aba "Mapa".
class MapaView extends StatelessWidget {
  /// Cria a aba. [criarMarcarPonto] é null quando o Firebase não ligou.
  const MapaView({super.key, this.criarMarcarPonto});

  /// Cria um ViewModel novo a cada abertura da tela de marcar (como um
  /// Supplier do Java). Um ViewModel reaproveitado guardaria o "enviado"
  /// da vez anterior e o botão de enviar ficaria desativado.
  final MarcarPontoViewModel Function()? criarMarcarPonto;

  @override
  Widget build(BuildContext context) {
    final criar = criarMarcarPonto;
    final textos = Theme.of(context).textTheme;

    // A Key fixa permite que os testes encontrem esta tela com find.byKey.
    return Scaffold(
      key: const Key('tela_mapa'),
      appBar: AppBar(title: const Text('Mapa')),
      body: Center(
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
              // onPressed null = botão desativado (o Flutter o desenha
              // apagado e o leitor de tela diz "desativado").
              FilledButton.icon(
                onPressed: criar == null ? null : () => _abrir(context, criar),
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Marcar rua alagada'),
              ),
              // A linha do aviso só aparece com o Firebase desligado.
              if (criar == null) ...[
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
      ),
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
