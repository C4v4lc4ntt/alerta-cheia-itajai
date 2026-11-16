// =============================================================================
// contato_emergencia.dart — contato de emergência da aba Ajuda (RF05, D20).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Os contatos reais ficam no catálogo em data/ (fonte: página "Telefones de
// emergência" da Defesa Civil de Itajaí, acesso em 15/11/2026).
// =============================================================================

/// Contato que o morador liga com um toque (ex.: Defesa Civil, 199).
class ContatoEmergencia {
  /// Cria o contato.
  ///
  /// Lança [ArgumentError] se o [nome] estiver vazio ou só com espaços, ou se
  /// o [numero] não tiver só dígitos (ele vai direto no "tel:" do discador).
  ContatoEmergencia({
    required this.nome,
    required this.numero,
    required this.descricao,
  }) {
    if (nome.trim().isEmpty) {
      throw ArgumentError('O nome do contato não pode ficar vazio.');
    }
    // ^\d+$: um ou mais dígitos do início ao fim, então o vazio também falha.
    if (!RegExp(r'^\d+$').hasMatch(numero)) {
      throw ArgumentError(
        'O número "$numero" do contato "$nome" deve ter só dígitos.',
      );
    }
  }

  /// Nome do serviço (ex.: "Defesa Civil").
  final String nome;

  /// Número só com dígitos (ex.: "199").
  final String numero;

  /// Quando ligar, como na fonte (ex.: "Riscos, alagamentos...").
  final String descricao;
}
