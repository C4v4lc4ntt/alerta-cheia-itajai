// =============================================================================
// leitura_localizacao.dart — resultado da leitura da posição atual (RF03).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// É uma classe "sealed" (como uma sealed interface do Java 17): o switch da
// tela é obrigado a tratar todos os casos. Cada caso de "sem localização"
// leva a uma ação diferente na tela (decisão de 10/11):
//   GpsDesligado       → ligar a localização do celular;
//   PermissaoNegada    → pedir a permissão de novo;
//   PermissaoBloqueada → abrir as configurações do app ("não perguntar
//                        novamente": o app não pode mais pedir);
//   FalhaNaLeitura     → tentar de novo (sem sinal ou tempo esgotado).
// =============================================================================

/// Resultado de uma leitura da posição do celular.
sealed class LeituraLocalizacao {
  const LeituraLocalizacao();
}

/// A posição foi lida. A [precisaoMetros] é o raio de incerteza do GPS,
/// mostrado na tela ("precisão de N m").
final class LocalizacaoObtida extends LeituraLocalizacao {
  const LocalizacaoObtida({
    required this.latitude,
    required this.longitude,
    required this.precisaoMetros,
  });

  final double latitude;
  final double longitude;
  final double precisaoMetros;
}

/// A localização do celular está desligada.
final class GpsDesligado extends LeituraLocalizacao {
  const GpsDesligado();
}

/// O morador não permitiu o uso da localização (o app ainda pode pedir).
final class PermissaoNegada extends LeituraLocalizacao {
  const PermissaoNegada();
}

/// A permissão foi bloqueada ("não perguntar novamente"): só nas
/// configurações do app.
final class PermissaoBloqueada extends LeituraLocalizacao {
  const PermissaoBloqueada();
}

/// O GPS não conseguiu ler a posição (sem sinal ou tempo esgotado).
final class FalhaNaLeitura extends LeituraLocalizacao {
  const FalhaNaLeitura();
}
