// =============================================================================
// ajuda_view.dart — View da aba "Ajuda" (RF05 e RF06, D20).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// No MVVM a View só DESENHA o que recebe e repassa os toques ao ViewModel.
// Mostra os contatos de emergência, os abrigos e as orientações; tocar num
// número abre o discador. Se o discador não abrir, um aviso no topo mostra o
// número para discar à mão. O aviso de "enchente sem chuva" sobe para o topo
// a partir de Atenção.
// Passo 56 (adendo da D20), ETAPA VERDE: os abrigos ganham um filtro por região
// (mais "Animais") e as orientações ganham abas; cada um começa na primeira
// opção. A escolha é só da tela, por isso fica no State e não no ViewModel.
// =============================================================================
import 'package:flutter/material.dart';

import '../../domain/models/abrigo.dart';
import '../../domain/models/contato_emergencia.dart';
import '../../domain/models/estagio_alerta.dart';
import '../../domain/regras/aviso_enchente_sem_chuva.dart';
import 'ajuda_view_model.dart';
import 'cartoes_ajuda.dart';
import 'cartoes_orientacoes.dart';
import 'filtro_de_opcoes.dart';

/// Tela da aba "Ajuda".
class AjudaView extends StatefulWidget {
  /// Cria a tela com o [viewModel] e os dados dos catálogos.
  const AjudaView({
    super.key,
    required this.viewModel,
    required this.contatos,
    this.abrigos = const {},
    this.abrigosAnimais = const [],
    this.orientacoes = const {},
    this.estagioCidade,
  });

  /// Liga para o número tocado e guarda o número quando o discador falha.
  final AjudaViewModel viewModel;

  /// Contatos de emergência, na ordem em que aparecem.
  final List<ContatoEmergencia> contatos;

  /// Abrigos de pessoas por região (CRAS), na ordem de prioridade.
  final Map<String, List<Abrigo>> abrigos;

  /// Abrigos para animais domésticos.
  final List<Abrigo> abrigosAnimais;

  /// Orientações por seção (RF06), na ordem em que aparecem.
  final Map<String, List<String>> orientacoes;

  /// Estágio mais grave entre as estações; null enquanto a tela Início não
  /// tem leituras (carregando ou com erro): aí o aviso fica sem destaque.
  final EstagioAlerta? estagioCidade;

  @override
  State<AjudaView> createState() => _AjudaViewState();
}

/// Rótulo do filtro que mostra os abrigos para animais.
const String _animais = 'Animais';

class _AjudaViewState extends State<AjudaView> {
  // Opções escolhidas no filtro e nas abas; null = a primeira de cada lista.
  String? _regiaoEscolhida;
  String? _secaoEscolhida;

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final regioes = [...widget.abrigos.keys, _animais];
    final regiao = _regiaoEscolhida ?? regioes.first;
    final secoes = widget.orientacoes.keys.toList();
    final secao = _secaoEscolhida ?? (secoes.isEmpty ? null : secoes.first);
    // A Key fixa permite que os testes encontrem esta tela com find.byKey.
    return Scaffold(
      key: const Key('tela_ajuda'),
      appBar: AppBar(title: const Text('Ajuda')),
      // ListenableBuilder redesenha a lista quando o ViewModel avisa.
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final numero = viewModel.numeroParaDiscarAMao;
          final estagio = widget.estagioCidade;
          final destaque =
              estagio != null && avisoEnchenteSemChuvaEmDestaque(estagio);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (numero != null) AvisoDiscador(numero: numero),
              // RF06 (D20): a partir de Atenção, o aviso sobe para o topo.
              if (destaque)
                const AvisoEnchenteSemChuva(
                  key: Key('aviso_em_destaque'),
                  emDestaque: true,
                ),
              for (final contato in widget.contatos)
                CartaoContato(
                  contato: contato,
                  aoLigar: () => viewModel.ligar(contato.numero),
                ),
              // A fonte não diz quais abrigos estão abertos (D20).
              const TituloSecao('Abrigos da Defesa Civil'),
              const Text(
                'Os abrigos abrem conforme a necessidade. '
                'Confirme pelo 199 antes de ir.',
              ),
              // Filtro por região: só os abrigos da opção escolhida.
              FiltroDeOpcoes(
                opcoes: regioes,
                escolhida: regiao,
                aoEscolher: (opcao) => setState(() => _regiaoEscolhida = opcao),
              ),
              for (final abrigo
                  in regiao == _animais
                      ? widget.abrigosAnimais
                      : widget.abrigos[regiao]!)
                _cartaoAbrigo(abrigo),
              // RF06: orientações das fontes oficiais (D20), uma aba por vez.
              if (secao != null) ...[
                FiltroDeOpcoes(
                  opcoes: secoes,
                  escolhida: secao,
                  aoEscolher: (opcao) =>
                      setState(() => _secaoEscolhida = opcao),
                ),
                CartaoOrientacoes(itens: widget.orientacoes[secao]!),
              ],
              if (!destaque) const AvisoEnchenteSemChuva(emDestaque: false),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: viewModel.abrirMapaDeVias,
                icon: const Icon(Icons.map_outlined),
                label: const Text(
                  'Ver as vias com risco de alagar no mapa da Defesa Civil',
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Cartão do abrigo; o botão de ligar só existe quando há telefone.
  Widget _cartaoAbrigo(Abrigo abrigo) {
    final telefone = abrigo.telefone;
    return CartaoAbrigo(
      abrigo: abrigo,
      aoLigar: telefone == null ? null : () => widget.viewModel.ligar(telefone),
    );
  }
}
