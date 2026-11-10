// =============================================================================
// localizacao_servico_geolocator.dart — leitura da posição atual com o
// pacote geolocator (RF03).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// O GeolocatorPlatform chega pelo construtor: no app é o
// GeolocatorPlatform.instance, nos testes é um mock (injeção por construtor).
// =============================================================================
import 'package:geolocator/geolocator.dart';

import '../../domain/models/leitura_localizacao.dart';
import 'localizacao_servico.dart';

/// Tempo máximo para o GPS achar a posição (decisão de 10/11). Passou disso,
/// o geolocator lança TimeoutException e a leitura vira FalhaNaLeitura, para
/// a tela não ficar presa em "buscando".
const _tempoLimite = Duration(seconds: 30);

/// [LocalizacaoServico] que usa o GPS do celular.
class LocalizacaoServicoGeolocator implements LocalizacaoServico {
  /// Cria o serviço sobre o [_gps] recebido.
  const LocalizacaoServicoGeolocator(this._gps);

  final GeolocatorPlatform _gps;

  /// Confere o GPS e a permissão (pedindo uma vez, se ainda puder) e só
  /// então lê a posição.
  @override
  Future<LeituraLocalizacao> obterAtual() async {
    if (!await _gps.isLocationServiceEnabled()) {
      return const GpsDesligado();
    }

    // Se a permissão ainda não foi dada, pede uma vez; a resposta do pedido
    // decide se segue, se foi negada ou se foi bloqueada.
    var permissao = await _gps.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await _gps.requestPermission();
    }
    if (permissao == LocationPermission.denied) {
      return const PermissaoNegada();
    }
    if (permissao == LocationPermission.deniedForever) {
      return const PermissaoBloqueada();
    }

    return _lerPosicao();
  }

  /// Lê a posição uma vez, com o tempo limite. Qualquer erro do GPS (sem
  /// sinal, tempo esgotado) vira [FalhaNaLeitura].
  Future<LeituraLocalizacao> _lerPosicao() async {
    try {
      final posicao = await _gps.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: _tempoLimite),
      );
      return LocalizacaoObtida(
        latitude: posicao.latitude,
        longitude: posicao.longitude,
        precisaoMetros: posicao.accuracy,
      );
    } on Exception {
      return const FalhaNaLeitura();
    }
  }
}
