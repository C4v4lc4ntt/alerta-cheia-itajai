// =============================================================================
// cartao_oficial.dart — cartão grande da tela Início (D16, revisa a D11).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Mostra a situação OFICIAL da Defesa Civil. Sem boletim, mostra o estágio
// mais grave entre as estações e deixa escrito que é isso.
// =============================================================================
import 'package:flutter/material.dart';

import '../../core/tema/cores.dart';
import '../../domain/models/boletim_oficial.dart';
import '../../domain/models/estagio_alerta.dart';
import '../../domain/regras/estagio_do_boletim.dart';
import '../comum/formatos.dart';

/// Cartão grande com a situação oficial e a barra dos 4 estágios.
class CartaoOficial extends StatelessWidget {
  /// Cria o cartão com o [boletim] (null se não veio) e o [estagioCidade].
  const CartaoOficial({
    super.key,
    required this.boletim,
    required this.estagioCidade,
  });

  /// Boletim da Defesa Civil; null se o portal não o entregou.
  final BoletimOficial? boletim;

  /// Estágio mais grave entre as estações, usado só sem boletim.
  final EstagioAlerta estagioCidade;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    const branco = TextStyle(color: Colors.white);
    final boletim = this.boletim;

    // Com boletim: o estágio de mesmo nome, ou null se o nome for novo.
    final estagio = boletim == null
        ? estagioCidade
        : estagioDoBoletim(boletim.situacao);
    final rotulo = boletim == null
        ? 'Boletim oficial indisponível'
        : 'Situação oficial da Defesa Civil';
    final principal = boletim == null
        ? 'Estágio mais grave entre as estações: '
              '${nomeDoEstagio(estagioCidade)}'
        : boletim.situacao;

    // O leitor de tela lê uma frase só, em vez das partes soltas.
    return Semantics(
      container: true,
      label: boletim == null ? '$rotulo. $principal' : '$rotulo: $principal',
      child: ExcludeSemantics(
        child: Container(
          key: const Key('cartao_oficial'),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: estagio == null ? CoresApp.principal : corDoEstagio(estagio),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rotulo,
                style: texto.labelMedium
                    ?.merge(branco)
                    .copyWith(letterSpacing: 1.2),
              ),
              Text(
                principal,
                style: (boletim == null ? texto.titleLarge : texto.displaySmall)
                    ?.merge(branco)
                    .copyWith(fontWeight: FontWeight.w800),
              ),
              if (boletim != null)
                Text(
                  'Boletim de ${dataEHoraDeBrasilia(boletim.atualizadoEm)}',
                  style: texto.bodySmall?.merge(branco),
                ),
              // Nome desconhecido: sem barra, porque não há estágio certo.
              if (estagio != null) ...[
                const SizedBox(height: 16),
                _BarraDeEstagios(estagio: estagio),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra com os 4 estágios, destacando o atual (D05).
class _BarraDeEstagios extends StatelessWidget {
  const _BarraDeEstagios({required this.estagio});

  final EstagioAlerta estagio;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Row(
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
    );
  }
}
