// =============================================================================
// catalogo_estacoes.dart — as 11 estações de nível de Itajaí com as cotas.
//
// ETAPA VERDE: código mínimo para os testes passarem.
// Fonte: portal de monitoramento da Defesa Civil de Itajaí, consultado em
// 19/10/2026 (docs/catalogo-estacoes.md). Reserva offline do app (D07): os
// valores do portal têm prioridade quando houver internet.
// =============================================================================
import '../../domain/models/cotas_estacao.dart';
import '../../domain/models/estacao.dart';

/// Estações de monitoramento de nível da Defesa Civil de Itajaí.
final List<Estacao> catalogoEstacoes = [
  Estacao(
    codigo: 'DC01',
    nome: 'ICMBio/CEPSUL',
    rio: 'Rio Itajaí-Açu',
    cotas: CotasEstacao(atencao: 1.21, alerta: 1.61, emergencia: 1.75),
  ),
  Estacao(
    codigo: 'DC02',
    nome: 'Praça Celso Pereira da Silva',
    rio: 'Rio Itajaí-Açu',
    cotas: CotasEstacao(atencao: 1.60, alerta: 2.00, emergencia: 2.50),
  ),
  Estacao(
    codigo: 'DC03',
    nome: 'Captação SEMASA',
    rio: 'Rio Itajaí-Mirim (canal retificado)',
    cotas: CotasEstacao(atencao: 1.48, alerta: 1.85, emergencia: 2.50),
  ),
  Estacao(
    codigo: 'DC04',
    nome: 'Vitalmar Pescados',
    rio: 'Rio Itajaí-Mirim (canal retificado e curso antigo)',
    cotas: CotasEstacao(atencao: 1.50, alerta: 1.85, emergencia: 2.25),
  ),
  Estacao(
    codigo: 'DC05',
    nome: 'Propriedade privada',
    rio: 'Rio Itajaí-Mirim (curso antigo)',
    cotas: CotasEstacao(atencao: 1.60, alerta: 2.20, emergencia: 3.00),
  ),
  Estacao(
    codigo: 'DC06',
    nome: 'Itamirim Clube de Campo',
    rio: 'Rio Itajaí-Mirim (curso antigo)',
    cotas: CotasEstacao(atencao: 1.50, alerta: 1.85, emergencia: 2.55),
  ),
  Estacao(
    codigo: 'DC07',
    nome: 'Portal',
    rio: 'Ribeirão da Murta',
    cotas: CotasEstacao(atencao: 1.00, alerta: 1.40, emergencia: 1.50),
  ),
  Estacao(
    codigo: 'DC08',
    nome: 'Rua Benjamin Dagnoni',
    rio: 'Ribeirão Canhanduba',
    cotas: CotasEstacao(atencao: 1.70, alerta: 2.30, emergencia: 2.89),
  ),
  Estacao(
    codigo: 'DC09',
    nome: 'Ponte da Rua Lidia Puel Peixer',
    rio: 'Ribeirão da Murta',
    cotas: CotasEstacao(atencao: 1.22, alerta: 1.42, emergencia: 1.62),
  ),
  Estacao(
    codigo: 'DC10',
    nome: 'Bairro Limoeiro',
    rio: 'Rio Itajaí-Mirim',
    cotas: CotasEstacao(atencao: 8.00, alerta: 9.00, emergencia: 10.00),
  ),
  Estacao(
    codigo: 'DC11',
    nome: 'Santa Regina (Volta de Cima)',
    rio: 'Rio Itajaí-Açu',
    cotas: CotasEstacao(atencao: 3.00, alerta: 4.00, emergencia: 5.00),
  ),
];
