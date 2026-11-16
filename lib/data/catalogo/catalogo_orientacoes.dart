// =============================================================================
// catalogo_orientacoes.dart — orientações da aba Ajuda (RF06, D20).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Texto fiel às fontes, lidas em 15/11/2026:
// - Antes, Durante e Depois: página "Como agir em enchentes" do portal da
//   Defesa Civil de Itajaí (https://defesacivil.itajai.sc.gov.br/
//   como-agir-enchentes);
// - Veículos e ruas alagadas: "Cartilha de Prevenção" do site do Ministério
//   das Cidades (gov.br), sem título, autor ou ano no documento.
// =============================================================================

/// Orientações por seção, na ordem em que aparecem na tela.
const Map<String, List<String>> catalogoOrientacoes = {
  // Defesa Civil de Itajaí, "Como agir em enchentes" (01 · Antes).
  'Antes': [
    'Se mora em área inundável, combine com vizinhos e parentes um meio de '
        'transporte para retirar pertences.',
    'Conheça o histórico de cheia da sua região e os mapas de cotas de '
        'inundação.',
    'Saiba qual abrigo cadastrado você poderá ocupar, se precisar sair de '
        'casa.',
    'Guarde documentos em sacos plásticos bem fechados e em local protegido.',
    'Evite contato com a água da cheia; use bota de borracha ou macacão '
        'impermeável.',
    'Não deixe animais de estimação acorrentados.',
  ],
  // Defesa Civil de Itajaí, "Como agir em enchentes" (02 · Durante).
  'Durante': [
    'Siga as orientações da Defesa Civil. Não enfrente a correnteza.',
    'Desligue a energia e o gás se precisar deixar o imóvel.',
    'Leve documentos, remédios de uso contínuo e itens de higiene ao se '
        'dirigir a um abrigo.',
    'Os abrigos abrem conforme a necessidade: confirme os pontos em '
        'funcionamento pelo 199 ou pelo painel ao vivo.',
  ],
  // Defesa Civil de Itajaí, "Como agir em enchentes" (03 · Depois).
  'Depois': [
    'Não consuma alimentos ou água que tenham tido contato com a enchente.',
    'Limpe e desinfete a caixa-d’água antes de voltar a usá-la.',
    'Evite encostar em cabos elétricos; avise o Corpo de Bombeiros ou a '
        'Defesa Civil.',
    'Monte um plano familiar de prevenção para a próxima temporada de chuvas.',
  ],
  // Cartilha de Prevenção, site do Ministério das Cidades (gov.br).
  'Veículos e ruas alagadas': [
    'Evite caminhar pelas águas da enchente devido ao risco de correnteza, '
        'ferimentos, animais peçonhentos e doenças.',
    'Se precisar atravessar ruas alagadas, nas quais pode haver buracos e '
        'bueiros destampados, utilize muros e paredes como apoio ou cordas '
        'com ajuda de, pelo menos, três pessoas.',
    'Não atravesse águas de enchente de carro, pois ele pode ser arrastado.',
    'Se o carro enguiçar, abandone-o.',
    'Se precisar dirigir em área alagada, mantenha baixa velocidade e o '
        'motor acelerado.',
    'Não atravesse águas alagadas atrás de outro veículo, para evitar '
        'bloqueio.',
  ],
};
