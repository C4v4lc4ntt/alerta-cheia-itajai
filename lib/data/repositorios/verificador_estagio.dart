// =============================================================================
// verificador_estagio.dart — verificação do estágio do RF02 (D06, D12, D14 e
// D15). É a mesma com o app aberto e, no Android, em segundo plano.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// =============================================================================
import '../../domain/models/estagio_alerta.dart';
import '../../domain/regras/classificador_estagio.dart';
import '../../domain/regras/deve_notificar.dart';
import '../../domain/regras/estagio_mais_grave.dart';
import '../catalogo/catalogo_estacoes.dart';
import '../servicos/nivel_rio_servico.dart';
import '../servicos/notificador_servico.dart';
import '../servicos/preferencias_servico.dart';

/// Confere se o estágio mudou e avisa os bairros escolhidos.
class VerificadorEstagio {
  /// Cria o verificador com os serviços injetados.
  VerificadorEstagio({
    required this.niveis,
    required this.preferencias,
    required this.notificador,
  });

  /// De onde vêm as leituras de nível.
  final NivelRioServico niveis;

  /// Onde ficam os bairros escolhidos e o último estágio.
  final PreferenciasServico preferencias;

  /// Quem mostra o aviso ao morador.
  final NotificadorServico notificador;

  /// Faz uma verificação completa.
  ///
  /// Nunca lança erro: uma falha mantém o último estágio salvo, e a próxima
  /// verificação tenta de novo (D14).
  Future<void> verificar() async {
    try {
      final bairros = await preferencias.lerBairrosEscolhidos();
      if (bairros.isEmpty) return; // D15: sem bairro, nem consulta o portal.

      final atual = await _buscarEstagioAtual();
      if (atual == null) return; // Sem leitura, nunca assume Monitoramento.

      final anterior = await preferencias.lerUltimoEstagio();
      if (deveNotificar(anterior: anterior, atual: atual)) {
        for (final bairro in bairros) {
          await notificador.notificarMudanca(
            bairro: bairro,
            anterior: anterior!,
            atual: atual,
          );
        }
      }

      // Salva por último: se o aviso falhar, a mudança continua pendente.
      await preferencias.salvarUltimoEstagio(atual);
    } catch (_) {
      // Segue sem mudar nada. Em segundo plano não há tela para mostrar erro.
    }
  }

  // Estágio mais grave entre as estações do catálogo (D02); null se nenhuma
  // leitura for reconhecida.
  Future<EstagioAlerta?> _buscarEstagioAtual() async {
    final cotasPorCodigo = {
      for (final estacao in catalogoEstacoes) estacao.codigo: estacao.cotas,
    };
    final leituras = await niveis.buscarLeituras();
    final estagios = [
      for (final leitura in leituras)
        if (cotasPorCodigo[leitura.codigoEstacao] case final cotas?)
          classificarEstagio(leitura.nivel, cotas),
    ];
    return estagios.isEmpty ? null : estagioMaisGrave(estagios);
  }
}
