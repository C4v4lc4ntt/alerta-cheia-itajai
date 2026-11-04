// =============================================================================
// preferencias_falsas.dart — versão de PreferenciasServico para os testes.
//
// Guarda tudo em memória, sem tocar no armazenamento do celular. É como uma
// implementação de interface escrita à mão para um teste JUnit.
// =============================================================================
import 'package:alerta_cheia_itajai/data/servicos/preferencias_servico.dart';
import 'package:alerta_cheia_itajai/domain/models/estagio_alerta.dart';

/// Preferências em memória, com valores iniciais escolhidos pelo teste.
class PreferenciasFalsas implements PreferenciasServico {
  /// Cria as preferências com os [bairros] e o [ultimoEstagio] do cenário.
  PreferenciasFalsas({this.bairros = const [], this.ultimoEstagio});

  /// Bairros escolhidos pelo morador.
  List<String> bairros;

  /// Último estágio salvo; null antes da primeira leitura.
  EstagioAlerta? ultimoEstagio;

  @override
  Future<List<String>> lerBairrosEscolhidos() async => bairros;

  @override
  Future<EstagioAlerta?> lerUltimoEstagio() async => ultimoEstagio;

  @override
  Future<void> salvarUltimoEstagio(EstagioAlerta estagio) async {
    ultimoEstagio = estagio;
  }
}
