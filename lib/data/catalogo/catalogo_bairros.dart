// =============================================================================
// catalogo_bairros.dart — tabela pronta bairro → estações próximas (D08).
//
// ETAPA VERDE: código mínimo para os testes passarem.
// A ligação é uma ESTIMATIVA, não um dado oficial. Fontes, regra e ajustes:
// docs/catalogo-bairros.md (nomes do Plano de Contingência de 22/12/2025; dados
// do OpenStreetMap e do portal da Defesa Civil consultados em 04/11/2026).
// =============================================================================
import '../../domain/models/bairro.dart';

/// Os 43 nomes do Plano de Contingência, na ordem das zonas.
final List<Bairro> catalogoBairros = [
  Bairro(nome: 'Salseiros', estacoesProximas: const ['DC02', 'DC09']),
  Bairro(nome: 'Espinheiros', estacoesProximas: const ['DC07', 'DC11']),
  Bairro(nome: 'Espinheirinhos', estacoesProximas: const ['DC11', 'DC07']),
  Bairro(nome: 'Volta de Cima', estacoesProximas: const ['DC11', 'DC02']),
  Bairro(nome: 'São Roque', estacoesProximas: const ['DC03', 'DC05']),
  Bairro(
    nome: 'São Francisco de Assis',
    estacoesProximas: const ['DC11', 'DC07'],
  ),
  Bairro(nome: 'Santa Regina', estacoesProximas: const ['DC11', 'DC07']),
  Bairro(nome: 'Portal I e II', estacoesProximas: const ['DC07', 'DC02']),
  Bairro(nome: 'Cordeiros', estacoesProximas: const ['DC09', 'DC04']),
  Bairro(nome: 'Murta', estacoesProximas: const ['DC02', 'DC09']),
  Bairro(nome: 'São Vicente', estacoesProximas: const ['DC04', 'DC03']),
  Bairro(nome: 'Rio Bonito', estacoesProximas: const ['DC04', 'DC03']),
  Bairro(nome: 'Bambuzal', estacoesProximas: const ['DC04', 'DC09']),
  Bairro(nome: 'Nilo Bittencourt', estacoesProximas: const ['DC03', 'DC06']),
  Bairro(nome: 'Cidade Nova', estacoesProximas: const ['DC06', 'DC03']),
  Bairro(nome: 'Carvalho', estacoesProximas: const ['DC06', 'DC03']),
  Bairro(nome: 'Ressacada', estacoesProximas: const ['DC06', 'DC01']),
  Bairro(nome: 'São João', estacoesProximas: const ['DC04', 'DC06']),
  Bairro(nome: 'Barra do Rio', estacoesProximas: const ['DC04', 'DC09']),
  Bairro(nome: 'Imaruí', estacoesProximas: const ['DC04', 'DC01']),
  Bairro(nome: 'Nova Brasília', estacoesProximas: const ['DC04', 'DC09']),
  Bairro(nome: 'São Judas', estacoesProximas: const ['DC06', 'DC04']),
  Bairro(nome: 'Dom Bosco', estacoesProximas: const ['DC06', 'DC01']),
  Bairro(
    nome: 'Nossa Senhora das Graças',
    estacoesProximas: const ['DC06', 'DC01'],
  ),
  Bairro(nome: 'Centro', estacoesProximas: const ['DC01', 'DC06']),
  Bairro(nome: 'Vila Operária', estacoesProximas: const ['DC06', 'DC01']),
  Bairro(nome: 'Fazenda', estacoesProximas: const ['DC01', 'DC06']),
  Bairro(nome: 'Fazendinha', estacoesProximas: const ['DC01', 'DC06']),
  Bairro(nome: 'Cabeçudas', estacoesProximas: const ['DC01', 'DC06']),
  Bairro(nome: 'Praia Brava', estacoesProximas: const ['DC01', 'DC06']),
  Bairro(nome: 'Itaipava', estacoesProximas: const ['DC05', 'DC06']),
  Bairro(nome: 'Rio do Meio', estacoesProximas: const ['DC08', 'DC06']),
  Bairro(nome: 'Canhanduba', estacoesProximas: const ['DC08', 'DC06']),
  Bairro(nome: 'KM 12', estacoesProximas: const ['DC05', 'DC08']),
  Bairro(nome: 'Arraial dos Cunha', estacoesProximas: const ['DC05']),
  Bairro(nome: 'Bahia', estacoesProximas: const ['DC08', 'DC05']),
  Bairro(nome: 'São Pedro', estacoesProximas: const ['DC06', 'DC03']),
  Bairro(nome: 'Paciência', estacoesProximas: const ['DC08', 'DC05']),
  Bairro(nome: 'Brilhante I', estacoesProximas: const ['DC10']),
  Bairro(nome: 'Brilhante II', estacoesProximas: const ['DC10']),
  Bairro(nome: 'Laranjeiras', estacoesProximas: const ['DC10']),
  Bairro(nome: 'Campeche', estacoesProximas: const ['DC10']),
  Bairro(nome: 'Limoeiro', estacoesProximas: const ['DC10']),
];
