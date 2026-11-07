// =============================================================================
// cartao_bairro.dart — cartão de um bairro escolhido na tela Início (D16).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// As estações próximas são uma ESTIMATIVA (D08), e o título diz isso.
// =============================================================================
import 'package:flutter/material.dart';

import '../comum/formatos.dart';
import 'inicio_view_model.dart';

/// Cartão com as estações próximas de um bairro, com nível e estágio.
class CartaoBairroView extends StatelessWidget {
  /// Cria o cartão com os dados montados pelo ViewModel.
  const CartaoBairroView({super.key, required this.cartao});

  /// Nome do bairro e estações com leitura.
  final CartaoBairro cartao;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${cartao.nome} · estações próximas (estimativa)',
                style: texto.titleMedium,
              ),
            ),
            if (cartao.estacoes.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text('Sem leitura das estações próximas agora.'),
              ),
            for (final situacao in cartao.estacoes)
              ListTile(
                dense: true,
                // A cor nunca é a única informação: o estágio vem escrito.
                leading: Icon(
                  Icons.circle,
                  size: 14,
                  color: corDoEstagio(situacao.estagio),
                ),
                title: Text(nomeDaEstacao(situacao.estacao)),
                subtitle: Text(
                  '${formatarNivel(situacao.leitura.nivel)} · '
                  '${nomeDoEstagio(situacao.estagio)}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
