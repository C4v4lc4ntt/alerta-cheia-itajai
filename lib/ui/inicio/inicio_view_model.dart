// =============================================================================
// inicio_view_model.dart — ViewModel da tela Início (RF01).
//
// Junta níveis, boletim e tábua de marés, calcula o estágio da cidade com as
// regras do domínio e escolhe a estação mais crítica para a tela mostrar.
// A View só desenha o estado que ele expõe.
// =============================================================================
import 'package:flutter/foundation.dart';

import '../../data/catalogo/catalogo_estacoes.dart';
import '../../data/servicos/boletim_servico.dart';
import '../../data/servicos/nivel_rio_servico.dart';
import '../../domain/models/boletim_oficial.dart';
import '../../domain/models/estacao.dart';
import '../../domain/models/estagio_alerta.dart';
import '../../domain/models/leitura_nivel.dart';
import '../../domain/models/tabua_mare.dart';
import '../../domain/regras/classificador_estagio.dart';
import '../../domain/regras/estagio_mais_grave.dart';

/// O que a tela Início está mostrando.
sealed class EstadoInicio {}

/// Buscando os dados no portal.
final class InicioCarregando extends EstadoInicio {}

/// Não foi possível obter os níveis.
final class InicioErro extends EstadoInicio {
  /// Cria o estado de erro com a [mensagem] para o morador.
  InicioErro(this.mensagem);

  /// Texto explicando o problema, para exibir na tela.
  final String mensagem;
}

/// Dados prontos para exibir.
final class InicioPronto extends EstadoInicio {
  /// Cria o estado com tudo o que a tela Início mostra.
  InicioPronto({
    required this.estagioCidade,
    required this.leituras,
    required this.atualizadoEm,
    required this.consultadoEm,
    required this.estacaoMaisCritica,
    required this.leituraMaisCritica,
    this.boletim,
    this.tabuaMare,
  });

  /// Estágio mais grave entre as estações (D02).
  final EstagioAlerta estagioCidade;

  /// Leituras usadas no cálculo, uma por estação.
  final List<LeituraNivel> leituras;

  /// Horário da leitura mais antiga entre as usadas.
  final DateTime atualizadoEm;

  /// Quando o app consultou o portal.
  final DateTime consultadoEm;

  /// Estação que mais pesa no estágio da cidade.
  final Estacao estacaoMaisCritica;

  /// Leitura da [estacaoMaisCritica].
  final LeituraNivel leituraMaisCritica;

  /// Boletim oficial; null se não houver ou se o portal falhar (D10).
  final BoletimOficial? boletim;

  /// Tábua de marés do mês; null se não houver ou se o portal falhar (D10).
  final TabuaMare? tabuaMare;
}

// Uma leitura reconhecida, com a estação e o estágio dela.
typedef _Avaliada = ({
  Estacao estacao,
  LeituraNivel leitura,
  EstagioAlerta estagio,
});

/// ViewModel da tela Início: busca os dados e calcula o estágio da cidade.
class InicioViewModel extends ChangeNotifier {
  /// Cria o ViewModel com os serviços injetados (nos testes, mocks).
  /// [agora] diz que horas são; no app, o relógio do celular.
  InicioViewModel({
    required this.niveis,
    required this.boletins,
    DateTime Function()? agora,
  }) : agora = agora ?? DateTime.now;

  /// Relógio usado para registrar a hora da consulta.
  final DateTime Function() agora;

  /// De onde vêm as leituras de nível.
  final NivelRioServico niveis;

  /// De onde vêm o boletim oficial e a tábua de marés.
  final BoletimServico boletins;

  EstadoInicio _estado = InicioCarregando();

  /// Estado atual da tela.
  EstadoInicio get estado => _estado;

  /// Busca tudo de novo e avisa a tela quando terminar.
  Future<void> carregar() async {
    _estado = InicioCarregando();
    notifyListeners();

    try {
      final consultadoEm = agora();
      final leituras = await niveis.buscarLeituras();
      final estacoesPorCodigo = {
        for (final estacao in catalogoEstacoes) estacao.codigo: estacao,
      };
      final avaliadas = <_Avaliada>[
        for (final leitura in leituras)
          // Estação fora do catálogo é ignorada.
          if (estacoesPorCodigo[leitura.codigoEstacao] case final estacao?)
            (
              estacao: estacao,
              leitura: leitura,
              estagio: classificarEstagio(leitura.nivel, estacao.cotas),
            ),
      ];

      // Sem nenhuma estação reconhecida não há base para dizer o estágio.
      if (avaliadas.isEmpty) {
        _estado = InicioErro(_mensagemErro);
      } else {
        final critica = avaliadas.reduce(_maisCritica);
        _estado = InicioPronto(
          estagioCidade: estagioMaisGrave([
            for (final avaliada in avaliadas) avaliada.estagio,
          ]),
          leituras: leituras,
          atualizadoEm: leituras
              .map((l) => l.medidoEm)
              .reduce((a, b) => a.isBefore(b) ? a : b),
          consultadoEm: consultadoEm,
          estacaoMaisCritica: critica.estacao,
          leituraMaisCritica: critica.leitura,
          boletim: await _semFalhar(boletins.buscarBoletim),
          tabuaMare: await _semFalhar(boletins.buscarTabuaMare),
        );
      }
    } catch (_) {
      _estado = InicioErro(_mensagemErro);
    }
    notifyListeners();
  }

  static const _mensagemErro =
      'Não foi possível obter os níveis da Defesa Civil. '
      'Tente de novo em instantes.';

  // Maior estágio; no empate, a mais perto da cota de Atenção (em proporção).
  static _Avaliada _maisCritica(_Avaliada a, _Avaliada b) {
    if (a.estagio != b.estagio) {
      return a.estagio.index > b.estagio.index ? a : b;
    }
    final proporcaoA = a.leitura.nivel / a.estacao.cotas.atencao;
    final proporcaoB = b.leitura.nivel / b.estacao.cotas.atencao;
    return proporcaoA >= proporcaoB ? a : b;
  }

  // Boletim e tábua são complemento: se falharem, a tela segue sem eles.
  Future<T?> _semFalhar<T>(Future<T?> Function() buscar) async {
    try {
      return await buscar();
    } catch (_) {
      return null;
    }
  }
}
