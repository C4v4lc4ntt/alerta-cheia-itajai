// =============================================================================
// verificador_estagio.dart — verificação do estágio do RF02 (D06, D12, D14 e
// D15). É a mesma com o app aberto e, no Android, em segundo plano.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// =============================================================================
import '../../domain/regras/avaliar_leituras.dart';
import '../../domain/regras/deve_notificar.dart';
import '../../domain/regras/mais_critica_primeiro.dart';
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

      final critica = await _buscarMaisCritica();
      if (critica == null) return; // Sem leitura, nunca assume Monitoramento.
      final atual = critica.estagio; // O mais grave entre as estações (D02).

      final anterior = await preferencias.lerUltimoEstagio();
      if (deveNotificar(anterior: anterior, atual: atual)) {
        for (final bairro in bairros) {
          await notificador.notificarMudanca(
            bairro: bairro,
            estacao: critica.estacao,
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

  // Estação mais crítica, a mesma da tela Início (D16); null se nenhuma
  // leitura for reconhecida.
  Future<SituacaoEstacao?> _buscarMaisCritica() async {
    final leituras = await niveis.buscarLeituras();
    final avaliadas = avaliarLeituras(leituras, catalogoEstacoes);
    if (avaliadas.isEmpty) return null;
    return ([...avaliadas]..sort(maisCriticaPrimeiro)).first;
  }
}
