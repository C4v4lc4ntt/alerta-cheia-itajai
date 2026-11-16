// =============================================================================
// preferencias_falsas.dart — versão de PreferenciasServico para os testes.
//
// Guarda tudo em memória, sem tocar no armazenamento do celular. É como uma
// implementação de interface escrita à mão para um teste JUnit.
// Passo 57 (D21): também guarda a última consulta, para o uso sem internet.
// =============================================================================
import 'package:alerta_cheia_itajai/data/servicos/preferencias_servico.dart';
import 'package:alerta_cheia_itajai/domain/models/consulta_guardada.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';

/// Preferências em memória, com valores iniciais escolhidos pelo teste.
class PreferenciasFalsas implements PreferenciasServico {
  /// Cria as preferências com os [bairros], o [ultimoEstagio] e a
  /// [ultimaConsulta] do cenário.
  PreferenciasFalsas({
    this.bairros = const [],
    this.ultimoEstagio,
    this.ultimaConsulta,
  });

  /// Bairros escolhidos pelo morador.
  List<String> bairros;

  /// Último estágio salvo; null antes da primeira leitura.
  EstagioAlerta? ultimoEstagio;

  /// Última consulta guardada; null antes da primeira que deu certo (D21).
  ConsultaGuardada? ultimaConsulta;

  @override
  Future<List<String>> lerBairrosEscolhidos() async => bairros;

  @override
  Future<void> salvarBairrosEscolhidos(List<String> bairros) async {
    this.bairros = bairros;
  }

  @override
  Future<EstagioAlerta?> lerUltimoEstagio() async => ultimoEstagio;

  @override
  Future<void> salvarUltimoEstagio(EstagioAlerta estagio) async {
    ultimoEstagio = estagio;
  }

  @override
  Future<void> apagarUltimoEstagio() async {
    ultimoEstagio = null;
  }

  @override
  Future<ConsultaGuardada?> lerUltimaConsulta() async => ultimaConsulta;

  @override
  Future<void> salvarUltimaConsulta(ConsultaGuardada consulta) async {
    ultimaConsulta = consulta;
  }
}
