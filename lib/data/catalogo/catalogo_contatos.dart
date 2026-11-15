// =============================================================================
// catalogo_contatos.dart — contatos de emergência da aba Ajuda (RF05, D20).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Fonte: página "Telefones de emergência" do portal da Defesa Civil de
// Itajaí (https://defesacivil.itajai.sc.gov.br/telefones-de-emergencia),
// acesso em 15/11/2026. Nomes, números e descrições como estão na página.
// =============================================================================
import '../../domain/models/contato_emergencia.dart';

/// Os 3 contatos do RF05, na ordem da página da Defesa Civil.
///
/// `final` e não `const`: o construtor valida os dados, então um número
/// digitado errado aqui quebra os testes na hora.
final List<ContatoEmergencia> catalogoContatos = [
  ContatoEmergencia(
    nome: 'Defesa Civil',
    numero: '199',
    descricao: 'Riscos, alagamentos, deslizamentos e emergências do município.',
  ),
  ContatoEmergencia(
    nome: 'Corpo de Bombeiros',
    numero: '193',
    descricao:
        'Incêndios, salvamentos, acidentes e situações com risco à vida.',
  ),
  ContatoEmergencia(
    nome: 'SAMU',
    numero: '192',
    descricao: 'Urgências e emergências médicas.',
  ),
];
