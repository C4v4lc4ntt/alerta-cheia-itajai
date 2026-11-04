# Registro de decisões

Decisões que mudam ou detalham os requisitos do relatório da Etapa 1. Cada uma registra o contexto, o que foi decidido e o porquê, para servir de evidência no relatório final.

---

## D01 · Estágios oficiais da Defesa Civil (16/10/2026)
**Contexto:** o relatório e o mockup usavam Normal / Atenção / Alerta / Alerta Máximo. O portal de monitoramento da Defesa Civil de Itajaí usa outros nomes.
**Decisão:** adotar os nomes oficiais **Monitoramento, Atenção, Alerta e Emergência**.
**Por quê:** manter coerência com os canais oficiais, já que o app é complemento e não concorrente.

## D02 · Cotas por estação e comparação "≥" (16/10/2026)
**Contexto:** a Defesa Civil monitora 11 estações e cada uma tem as próprias cotas.
**Decisão:** as cotas são um dado de cada estação, vindo do catálogo oficial (consulta em 16/10/2026). Atingir a cota já muda o estágio (`nível ≥ cota`). O estágio da cidade é o mais grave entre as estações, e o estágio do bairro é o mais grave entre as estações ligadas a ele.
**Por quê:** segurança (na dúvida, avisar antes), coerência com os boletins ("a partir de", "atingiu a cota") e testes de valor-limite claros.

## D03 · "Ainda alagado" renova o prazo do ponto (16/10/2026)
**Contexto:** o mockup tem o botão "Ainda alagado" e o contador de confirmações, mas o RF04 previa só expiração em 6 horas e 3 contestações ("Já baixou").
**Decisão:** cada **"Ainda alagado"** renova o prazo, e o ponto passa a sumir **6 horas depois da última confirmação**, e não 6 horas depois de criado. Com **3 "Já baixou"**, o ponto some na hora.
**Por quê:** se a rua continua alagada, o ponto não deve desaparecer do mapa.
**Testes (RF04):** ponto sem confirmação expira em 6 h; confirmação às 2 h leva a expiração para 8 h; ponto com 3 contestações fica inativo mesmo dentro do prazo.
**Situação:** adiada pela D06. No MVP, o ponto expira 6 h depois de criado.

## D04 · Opção "Só a partir de Alerta" nos avisos (16/10/2026)
**Contexto:** o mockup da tela "Bairros e avisos" oferece dois modos de aviso. O RF02 previa só "avisar quando o estágio mudar".
**Decisão:** manter os dois modos.
- **O estágio mudar** (padrão, recomendado): avisa em toda mudança, para subir ou para baixar.
- **Só a partir de Alerta:** avisa apenas quando o novo estágio for Alerta ou Emergência.

**Por quê:** custa só um parâmetro na mesma regra de notificação e reduz avisos para quem preferir.
**Testes (RF02):** no modo "só a partir de Alerta", a mudança Monitoramento → Atenção não notifica e a mudança Atenção → Alerta notifica.
**Situação:** adiada pela D06. No MVP, só o modo "O estágio mudar".

## D05 · Rótulo curto na barra de estágios (16/10/2026)
**Contexto:** "Monitoramento" não cabe no espaço de cada etapa da barra da tela Início.
**Decisão:** usar **"Monitor."** só na barra. O título grande e o leitor de tela continuam com "Monitoramento" por extenso.
**Por quê:** legibilidade sem perder acessibilidade.

## D06 · Escopo do MVP para uma pessoa (19/10/2026)
**Contexto:** o desenvolvimento ficou com um só integrante, e o plano gratuito do Firebase não envia push sem servidor (Cloud Functions) nem guarda fotos sem o Cloud Storage.
**Decisão:**
- **RF02:** notificação **local**, gerada pelo próprio app quando o estágio muda. O modo "Só a partir de Alerta" (D04) fica para depois.
- **RF03:** sem foto (o requisito já a tratava como opcional).
- **RF04:** o ponto expira **6 h depois de criado**; com 3 "Já baixou" some na hora. A renovação por "Ainda alagado" (D03) fica para depois.

**Por quê:** garantir os seis requisitos funcionando, com TDD e validação com moradores, até 05/12/2026.
**Testes:** RF02 — mudança de estágio gera notificação local, mesmo estágio não gera; RF04 — ponto com mais de 6 h desde a criação fica inativo, e ponto com 3 contestações fica inativo mesmo dentro do prazo.


## D07 · Dados reais do portal da Defesa Civil (19/10/2026)
**Contexto:** o relatório previa um serviço simulado no MVP. A página "Nível dos Rios"
do portal de monitoramento da Defesa Civil de Itajaí é alimentada por um arquivo
público de dados (`/data/current/app.json`) com, para cada estação, o nível, o horário
da medição e as cotas de Atenção, Alerta e Emergência.
**Decisão:**
- O app busca os níveis e as cotas nesse arquivo público, por trás da interface
  `NivelRioServico` (implementação "Defesa Civil").
- O serviço simulado continua: é usado nos testes e para demonstrar cenários de cheia.
- Os testes nunca acessam a internet. A leitura do arquivo é testada com uma cópia
  salva, com a data registrada.
- `docs/catalogo-estacoes.md` é a referência dos testes e a reserva offline.
- O código da estação segue o portal, sem hífen (`DC01`), e é a chave que liga
  leituras, cotas e bairros, sem nenhuma conversão no caminho.
- Se a busca falhar, o app mostra a última leitura salva com o horário dela.
- O pacote de acesso à rede será justificado e confirmado no ciclo em que for usado.
- A autorização para consumir esses dados será pedida à Defesa Civil (passo 17).
**Por quê:** a validação com moradores fica mais convincente com o rio de verdade, e
as cotas acompanham a fonte oficial em vez de ficarem fixas no código.

## D08 · Estágio do bairro com estações estimadas (revisada em 04/11/2026)
**Contexto:** não há fonte oficial da relação entre estações e bairros. Ela foi
pedida à Defesa Civil por e-mail em 20/10/2026, com prazo até 02/11/2026, e não
houve resposta. O número D08 estava reservado e entra já com esta revisão.
**Decisão:**
- O bairro mostra o estágio oficial da cidade.
- Como complemento, a tela mostra as estações mais próximas do bairro, estimadas
  pelos limites dos bairros (OpenStreetMap) e pelas coordenadas das estações do
  `app.json`, conferidas com notícias de alagamentos, com link e data.
- A tela avisa que a proximidade é uma estimativa, não um dado oficial.
- O bairro nunca aparece com estágio menor que o da cidade.
- A estimativa fica em uma tabela pronta (bairro → estações), calculada fora do
  app, com fonte e data no catálogo. O app não guarda os limites dos bairros.
- Se a Defesa Civil enviar a relação oficial, ela substitui a estimativa.
**Por quê:** ajuda o morador a acompanhar os rios perto de casa sem apresentar
uma estimativa como informação oficial e sem reduzir o alerta.
**Testes:** o estágio do bairro é igual ao da cidade, mesmo quando as estações
próximas estão em estágio menor; a estimativa não muda o estágio mostrado.

## D09 · Pacote http para ler o portal (26/10/2026)
**Contexto:** a D07 exige baixar o `app.json` do portal da Defesa Civil.
**Decisão:** usar o pacote `http` (1.6.0), mantido pela equipe do Dart.
- Uso: um GET no endereço público do `app.json`; nenhum dado é enviado.
- Testes: `MockClient`, que já vem no pacote, finge a resposta do portal.
  Nenhum teste acessa a internet.
- O portal responde `application/json` sem charset: o corpo é decodificado
  explicitamente como UTF-8, senão "Itajaí" vira texto quebrado.
**Por quê:** é o pacote recomendado pelo Flutter para requisições HTTP, é
pequeno e já traz a ferramenta de teste. O `dio` foi descartado por trazer
recursos que o app não usa.

## D10 · Maré pelo boletim oficial e pela tábua mensal (26/10/2026)
**Contexto:** a tábua de marés do portal é uma imagem (JPEG) publicada uma vez
por mês (`/api/v1/tabuas-mare/atual`); os horários e alturas não podem ser
lidos com segurança pelo app. O portal também publica o boletim da Defesa
Civil (`/api/v1/situacao-atual`), com a situação da cidade e um texto que
inclui os horários de risco de maré.
**Decisão:**
- A tela Início mostra o boletim oficial (situação, texto e horário) e um
  botão para ver a tábua de marés do mês.
- O app não extrai valores da imagem e a maré não muda o estágio (passo 16).
- Se a tábua publicada não for do mês atual, o app avisa.
- Os alertas ativos (`/api/v1/alertas/ativo`) ficam para o RF02, quando o
  formato real de um alerta for conhecido.
**Por quê:** a maré chega ao morador com a interpretação oficial, sem o app
criar regra própria, e reaproveita o acesso ao portal da D07/D09.

## D11 · O cartão grande diz o que é calculado (26/10/2026)
**Contexto:** o app calcula o estágio mais grave entre as 11 estações (D02) e o
mostrava como "Estágio em Itajaí". Um único ribeirão em Alerta fazia a tela dizer
"Itajaí: Alerta", enquanto o boletim oficial podia continuar em "Normalidade",
porque o problema é local.
**Decisão:**
- O cartão grande passa a se chamar "Estágio mais grave entre as estações",
  também no rótulo do leitor de tela. A regra do cálculo não muda.
- O boletim oficial continua logo abaixo, com o nome que a Defesa Civil usar.
- No RF02, o destaque passa para a estação do bairro escolhido ou a mais perto
  do morador; se outra estiver em estágio mais grave, a tela explica qual.
**Por quê:** o app é complemento dos canais oficiais (D01) e não pode parecer
uma declaração da Defesa Civil; o título diz exatamente o que o app calculou,
sem perder o aviso quando qualquer rio sobe.

## D12 · A primeira leitura não notifica (04/11/2026)
**Contexto:** a notificação do RF02 compara o estágio atual com o anterior (D06).
Na primeira leitura depois da instalação, não existe estágio anterior.
**Decisão:** a primeira leitura só guarda o estágio como ponto de partida. A
notificação começa na primeira mudança.
**Por quê:** sem estágio anterior não há mudança, e quem instala já vê o estágio
na tela, com o app aberto.
**Testes:** sem estágio anterior não notifica em nenhum dos quatro estágios.

## D13 · Mapa centralizado na posição do morador (04/11/2026)
**Contexto:** o morador quer abrir o mapa e ver os alagamentos perto de onde está.
O RF04 previa só exibir os pontos ativos, e o GPS era opcional.
**Decisão:**
- Ao abrir o mapa, o app pede a localização e explica para quê.
- Com permissão, o GPS é usado uma vez para centralizar o mapa. A posição não é
  guardada nem enviada.
- Sem permissão, o mapa abre em Itajaí com todos os pontos ativos, e o restante
  do app continua funcionando.
- O acesso ao GPS fica atrás de uma interface em `data/servicos/`. O pacote
  `geolocator` será justificado e confirmado no RF04.
- O geofencing em segundo plano continua fora (D06).
**Por quê:** mostra primeiro o que importa para quem está na rua, sem coletar a
posição do morador (LGPD) e sem impedir o uso de quem negar a permissão.
**Testes:** com permissão, o mapa centraliza na posição recebida; sem permissão ou
com falha no GPS, centraliza em Itajaí.

## D14 · Verificação do estágio com o app fechado (04/11/2026)
**Contexto:** a notificação local da D06 depende de o app conferir o estágio. Sem
verificação em segundo plano, o morador só seria avisado ao abrir o app.
**Decisão:**
- No Android, o `workmanager` pede uma verificação periódica, com intervalo mínimo
  de 15 minutos. O horário é decidido pelo sistema e pode atrasar.
- O app também verifica ao abrir e ao voltar para o primeiro plano, usando a mesma
  lógica.
- No iOS, a verificação acontece só com o app em uso. O autor não tem iPhone para
  testar, a Apple não garante quando a tarefa roda e a validação usa APK.
- O app avisa que a notificação pode atrasar e não substitui os canais oficiais.
- Quem participar da validação deve deixar a bateria do app em "Sem restrições".
- Limite: se a notificação com o app fechado não funcionar no Samsung até
  10/11/2026, o app volta a verificar só em uso, com o limite declarado.
**Por quê:** é a opção sem servidor que mantém a D06 e cabe no calendário. Serviço
em primeiro plano e push ficaram de fora pelo incômodo ao usuário e pelo custo de
implementação.
**Testes:** a verificação é testada com serviços falsos: estágio mudou → notifica e
salva; mesmo estágio → não notifica; primeira leitura → só salva (D12); falha na
busca → mantém o último estágio e não notifica.
