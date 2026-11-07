// =============================================================================
// ajustes_view.dart — View da aba "Ajustes": tela Bairros e avisos (RF02, D08,
// D14 e D15).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// No MVVM a View só DESENHA o que o ViewModel entrega; não tem regra de
// negócio.
// =============================================================================
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/models/bairro.dart';
import 'ajustes_view_model.dart';

/// Tela da aba "Ajustes".
class AjustesView extends StatefulWidget {
  /// Cria a tela com o [viewModel] injetado.
  const AjustesView({super.key, required this.viewModel});

  /// Quem guarda a busca e os bairros marcados.
  final AjustesViewModel viewModel;

  @override
  State<AjustesView> createState() => _AjustesViewState();
}

class _AjustesViewState extends State<AjustesView> {
  // Fica aqui, fora do campo: ao rolar a lista, o campo sai da memória e o
  // texto digitado se perderia.
  final _busca = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Trocar de aba recria a tela com o campo vazio; a lista acompanha.
    widget.viewModel.buscar('');
    widget.viewModel.carregar();
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final texto = Theme.of(context).textTheme;

    return Scaffold(
      // A Key fixa permite que os testes encontrem esta tela com find.byKey.
      key: const Key('tela_ajustes'),
      body: SafeArea(
        // Redesenha toda vez que o ViewModel chama notifyListeners().
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            final bairros = viewModel.bairrosVisiveis;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Bairros e avisos', style: texto.headlineSmall),
                const SizedBox(height: 8),
                const Text(
                  'Escolha os bairros que você quer acompanhar. '
                  'O app avisa quando o estágio mudar.',
                ),
                const SizedBox(height: 12),
                const _Aviso(
                  'O aviso pode atrasar e não substitui os canais oficiais. '
                  'Emergência: 199, 193 ou 192.',
                ),
                // D14: no iOS não há verificação com o app fechado.
                if (defaultTargetPlatform == TargetPlatform.iOS)
                  const _Aviso('No iPhone, o app só verifica com ele em uso.'),
                if (viewModel.permissaoNegada)
                  const _Aviso(
                    'Sem permissão, o app não consegue avisar. '
                    'Ative as notificações nos ajustes do celular.',
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: _busca,
                  onChanged: viewModel.buscar,
                  decoration: const InputDecoration(
                    labelText: 'Buscar bairro',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                if (bairros.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Nenhum bairro encontrado.'),
                  ),
                for (final bairro in bairros)
                  _LinhaBairro(bairro: bairro, viewModel: viewModel),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Cartão com uma informação importante para o morador.
class _Aviso extends StatelessWidget {
  const _Aviso(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(texto),
      ),
    );
  }
}

/// Linha de um bairro com a caixa de marcação.
class _LinhaBairro extends StatelessWidget {
  const _LinhaBairro({required this.bairro, required this.viewModel});

  final Bairro bairro;
  final AjustesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final escolhido = viewModel.estaEscolhido(bairro.nome);
    return CheckboxListTile(
      value: escolhido,
      onChanged: (_) => viewModel.alternar(bairro.nome),
      title: Text(bairro.nome),
      // D08: a proximidade é estimada e a tela precisa dizer isso.
      subtitle: escolhido
          ? Text(
              'Estações próximas (estimativa, não é dado oficial): '
              '${viewModel.estacoesDe(bairro)}',
            )
          : null,
    );
  }
}
