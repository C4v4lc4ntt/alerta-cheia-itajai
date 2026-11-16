// =============================================================================
// estado_inicio.dart — os estados que a tela Início pode mostrar (RF01, D21).
//
// Passo 57, REFATORAR: saiu do inicio_view_model.dart, que tinha passado de
// ~200 linhas (CLAUDE.md, seção 4). Só mudou de arquivo: o comportamento e os
// testes são os mesmos. O inicio_view_model.dart reexporta este arquivo, então
// quem importa o ViewModel continua enxergando os estados.
// =============================================================================
import '../../domain/models/boletim_oficial.dart';
import '../../domain/models/estacao.dart';
import '../../domain/models/estagio_alerta.dart';
import '../../domain/models/leitura_nivel.dart';
import '../../domain/models/tabua_mare.dart';
import '../../domain/regras/avaliar_leituras.dart';

/// Bairro escolhido com as estações próximas que têm leitura (D08, D16).
typedef CartaoBairro = ({String nome, List<SituacaoEstacao> estacoes});

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
    required this.estacoes,
    required this.semBairroEscolhido,
    required this.bairros,
    required this.maisCriticaForaDosBairros,
    this.boletim,
    this.tabuaMare,
    this.semInternet = false,
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

  /// Todas as estações reconhecidas, da mais crítica para a menos crítica.
  final List<SituacaoEstacao> estacoes;

  /// Se a tela deve convidar o morador a escolher um bairro (D15).
  final bool semBairroEscolhido;

  /// Um cartão por bairro escolhido, na ordem da escolha (D16).
  final List<CartaoBairro> bairros;

  /// Se a [estacaoMaisCritica] ficou fora de todos os cartões de bairro, e a
  /// tela precisa mostrá-la numa linha menor (D16).
  final bool maisCriticaForaDosBairros;

  /// Boletim oficial; null se não houver ou se o portal falhar (D10).
  final BoletimOficial? boletim;

  /// Tábua de marés do mês; null se não houver ou se o portal falhar (D10).
  final TabuaMare? tabuaMare;

  /// Se a tela mostra a última consulta guardada porque a busca falhou (D21).
  /// Nesse caso, [consultadoEm] é a hora da consulta guardada.
  final bool semInternet;
}
