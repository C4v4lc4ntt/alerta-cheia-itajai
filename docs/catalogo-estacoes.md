# Catálogo das estações de monitoramento

Fonte: portal de monitoramento da Defesa Civil de Itajaí, página "Nível dos Rios"
(https://monitoramento.defesacivil.itajai.sc.gov.br/monitoramento/rios),
dados públicos da página (`/data/current/app.json`, gerado em 19/10/2026 20:20).
Consultado em 19/10/2026.

Unidade das cotas: metros. Regra do app (D02): nível ≥ cota → muda o estágio.
Os códigos estão escritos como no portal (DC01, sem hífen).

| Código | Nome da estação | Rio / curso d'água | Atenção (m) | Alerta (m) | Emergência (m) |
|---|---|---|---|---|---|
| DC01 | ICMBio/CEPSUL | Rio Itajaí-Açu | 1,21 | 1,61 | 1,75 |
| DC02 | Praça Celso Pereira da Silva | Rio Itajaí-Açu | 1,60 | 2,00 | 2,50 |
| DC03 | Captação SEMASA | Rio Itajaí-Mirim (canal retificado) | 1,48 | 1,85 | 2,50 |
| DC04 | Vitalmar Pescados | Rio Itajaí-Mirim (canal retificado e curso antigo) | 1,50 | 1,85 | 2,25 |
| DC05 | Propriedade privada | Rio Itajaí-Mirim (curso antigo) | 1,60 | 2,20 | 3,00 |
| DC06 | Itamirim Clube de Campo | Rio Itajaí-Mirim (curso antigo) | 1,50 | 1,85 | 2,55 |
| DC07 | Portal | Ribeirão da Murta | 1,00 | 1,40 | 1,50 |
| DC08 | Rua Benjamin Dagnoni | Ribeirão Canhanduba | 1,70 | 2,30 | 2,89 |
| DC09 | Ponte da Rua Lidia Puel Peixer | Ribeirão da Murta | 1,22 | 1,42 | 1,62 |
| DC10 | Bairro Limoeiro | Rio Itajaí-Mirim | 8,00 | 9,00 | 10,00 |
| DC11 | Santa Regina (Volta de Cima) | Rio Itajaí-Açu | 3,00 | 4,00 | 5,00 |

## Papel deste catálogo no app
- O app busca as cotas e os níveis direto no portal da Defesa Civil (opção A,
  decisão D07 em `docs/decisoes.md`).
- Este catálogo é a referência dos testes (valores conferidos, com fonte e data)
  e a reserva quando o app estiver sem internet e ainda não tiver dados salvos.
- Se o portal mudar alguma cota, atualize esta tabela com a nova data de consulta.

## Observações
- DC01 e DC07 conferem com as cotas usadas nos testes desde 16/10/2026.
- Em todas as estações, Atenção < Alerta < Emergência.
- O portal também mostra estações de Rio do Sul, Brusque e Blumenau. Elas ficam
  fora do catálogo porque o app trata só de Itajaí.

## Maré — Cabeçudas
- Consulta em 19/10/2026, na página "Marés" do portal
  (https://monitoramento.defesacivil.itajai.sc.gov.br/monitoramento/mares).
- O portal publica só a tábua de marés mensal (previsão, em arquivo).
  Não há medição do marégrafo em tempo real nem cotas de estágio para a maré.
- Consequência: no RF01, a maré não muda o estágio. O tratamento no app será
  decidido no ciclo 5.
- Descartados: tabuademares.com e mareaovivo.com. São previsões de terceiros,
  sem fonte primária identificada ou sem termos de reutilização, e não medem
  a água extra trazida pelo vento.

## Divergência com o Plano de Contingência
O Plano de Contingência de Inundação (atualizado em 22/12/2025, Tabela 11, p. 23)
traz cotas diferentes das do portal em quatro estações (Atenção / Alerta / Emergência, em m):

| Estação | Plano (22/12/2025) | Portal (19/10/2026) |
|---|---|---|
| DC01 | 1,16 / 1,36 / 1,56 | 1,21 / 1,61 / 1,75 |
| DC07 | 1,00 / 1,35 / 1,65 | 1,00 / 1,40 / 1,50 |
| DC08 | 1,80 / 2,30 / 2,89 | 1,70 / 2,30 / 2,89 |
| DC09 | 1,12 / 1,32 / 1,52 | 1,22 / 1,42 / 1,62 |

- As outras sete estações têm as mesmas cotas nas duas fontes.
- O app segue o portal (D07), porque é o que a população vê e é atualizado
  com os níveis. A confirmação foi pedida à Defesa Civil no e-mail de 20/10/2026.
- O plano não liga bairros a estações: agrupa os bairros em 10 zonas só para
  organizar os abrigos (seção 4.3.1).
