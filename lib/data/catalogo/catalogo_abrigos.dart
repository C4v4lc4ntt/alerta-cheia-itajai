// =============================================================================
// catalogo_abrigos.dart — abrigos da Defesa Civil para a aba Ajuda (RF05, D20).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Fonte: camada abrigos_itajai_final_2026 do geoportal da Prefeitura (painel
// público "Abrigos de Itajaí", ligado no item "Situação dos abrigos" do portal
// da Defesa Civil), lida em 15/11/2026. Escolhas da D20: os 3 códigos no
// endereço da Defesa Civil ficam fora; animais numa lista à parte; "Cordieros",
// "Alferedo", "fazenda" e "Naútico" corrigidos; telefones só com dígitos e
// DDD 47.
// A fonte não diz quais abrigos estão abertos: a tela manda confirmar no 199.
// =============================================================================
import '../../domain/models/abrigo.dart';

/// Abrigos de pessoas por região (CRAS), na ordem da fonte. Dentro de cada
/// região, a ordem é a de prioridade de abertura da fonte.
///
/// `final` e não `const`: o construtor do [Abrigo] valida os dados.
final Map<String, List<Abrigo>> catalogoAbrigos = {
  'CRAS Espinheiros': [
    Abrigo(
      nome: 'Capela Santo Antônio',
      endereco: 'R. Fermino Vieira Cordeiro, 915, Espinheiros',
    ),
    Abrigo(
      nome: 'Igreja Santa Paulina',
      endereco: 'R. Antônio Notari, Espinheiros',
    ),
  ],
  'CRAS Imaruí': [
    Abrigo(
      nome: 'Paróquia São Cristóvão',
      endereco: 'R. Odílio Garcia, 445, Cordeiros',
      telefone: '4733411408',
    ),
    Abrigo(
      nome: 'Igreja Reviver',
      endereco: 'Rua Benjamin Franklin Pereira, 458 - São João',
      telefone: '47996951115',
    ),
    Abrigo(
      nome: 'Clube Tiradentes',
      endereco: 'R. José Pereira Liberato, 437, São João',
      telefone: '47984020009',
    ),
    Abrigo(
      nome: 'Salão Paroquial da Igreja São João Batista',
      endereco: 'R. Dr. Pedro Rangel, 154, São João',
      telefone: '47996770450',
    ),
    Abrigo(
      nome: 'Primeira Igreja Batista',
      endereco: 'Rua Benjamin Franklin Pereira, 435 - São João',
      telefone: '4733446406',
    ),
    Abrigo(
      nome: 'Centro de Múltiplo Uso Cordeiros',
      endereco: 'R. Sergipe',
      telefone: '4733463804',
    ),
    Abrigo(
      nome: 'Centro de Arte e Lazer - CAL Cordeiros',
      endereco: 'R. Alfredo Esser, 143, Cordeiros',
      telefone: '4733463581',
    ),
    Abrigo(
      nome: 'Capela Cristo Ressuscitado',
      endereco: 'R. Travessa Marcos Castelain, 154, Localidade Nova Brasília',
    ),
  ],
  'CRAS Itaipava': [
    Abrigo(
      nome: 'Centro Comunitário da Capela Santo Antônio',
      endereco: 'R. Rodolfo Giradi, 4374, Brilhante II',
    ),
    Abrigo(
      nome: 'Centro Comunitário da Igreja São Sebastião',
      endereco: 'R. Edmundo Leopoldo Merizio, Limoeiro',
    ),
    Abrigo(
      nome: 'Paróquia da Igreja Nossa Senhora de Aparecida',
      endereco: 'R. Bento Custódio Vieira,388, Paciência',
    ),
    Abrigo(nome: 'Paróquia São José', endereco: 'Vergílio Cadore, Campeche'),
    Abrigo(
      nome: 'Pavilhão de Exposição',
      endereco: 'Rua Mansueto Felizardo Vieira, 557, Baía',
      telefone: '4733465500',
    ),
  ],
  'CRAS Nossa Senhora das Graças': [
    Abrigo(
      nome: 'Paróquia Nossa Senhora de Lurdes',
      endereco: 'R. Amaro Jaques, 85, Fazenda',
      telefone: '4733443972',
    ),
    Abrigo(
      nome: 'Lar Padre Jacob',
      endereco: 'R. José Copertino Chaves, 186, Fazenda',
      telefone: '4733482121',
    ),
    Abrigo(
      nome: 'Parque Dom Bosco',
      endereco: 'R. Brusque, 1333, Dom Bosco',
      telefone: '4733449100',
    ),
    Abrigo(
      nome: 'Clube Náutico Almirante Barroso',
      endereco: 'R. Almirante Barroso, 280, Centro',
      telefone: '4733482203',
    ),
    Abrigo(nome: 'Paróquia São Judas', endereco: 'R. Indaial, São Judas'),
    Abrigo(
      nome: 'Sociedade Recreativa da Fazenda',
      endereco: 'R. Luci Canziani, 550, Praia Brava',
    ),
    Abrigo(
      nome: 'Igreja CEI',
      endereco: 'Rua José Gall, 1570',
      telefone: '4721253335',
    ),
    Abrigo(
      nome: 'Igreja Luterana',
      endereco: 'Rua Dr José Bonifácio Malburg, 425, Centro',
      telefone: '47999483839',
    ),
    Abrigo(
      nome: 'Salão Paroquial Nossa Senhora da Paz',
      endereco: 'Av. José Eugênio Muller, 605, Vila Operária',
    ),
    Abrigo(
      nome: 'Colégio Salesiano',
      endereco: 'Rua Felipe Schmidt, 87 - Centro',
    ),
    Abrigo(nome: 'Colégio São José', endereco: 'Rua Silva, 365. Centro'),
    Abrigo(
      nome: 'Igreja Matriz',
      endereco: 'Praça Governador Irineu Bornhausen',
      telefone: '4733481254',
    ),
  ],
  'CRAS Promorar': [
    Abrigo(
      nome: 'Igreja São Vicente de Paulo',
      endereco: 'Rua Estefano José Vanolli, 1029',
      telefone: '4732412422',
    ),
    Abrigo(
      nome: 'Igreja Mevam',
      endereco: 'Av. Governador Adolfo Konder, 1750 - São Vicente',
    ),
    Abrigo(
      nome: 'Igreja Santuário da Família',
      endereco: 'Rua Antônio Cirilo Dutra, 62, São Vicente',
    ),
    Abrigo(
      nome: 'Salão Paroquial Nossa Senhora de Aparecida',
      endereco: 'Av. Ministro Luiz Galotti, 1692, Cidade Nova',
      telefone: '4732412792',
    ),
    Abrigo(
      nome: 'Salão Paroquial Nossa Senhora de Fátima',
      endereco: 'R. Agílio Cunha, 445, Cidade Nova',
      telefone: '4732242689',
    ),
  ],
};

/// Abrigos para animais domésticos. Na fonte o nome é só "ANIMAIS".
final List<Abrigo> catalogoAbrigosAnimais = [
  Abrigo(
    nome: 'Abrigo para animais',
    endereco: 'Rua Jorge Tzachel, 344 - Fazenda',
  ),
  Abrigo(nome: 'Abrigo para animais', endereco: 'Parque Dom Bosco'),
];
