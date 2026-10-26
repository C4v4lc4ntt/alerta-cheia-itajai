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
