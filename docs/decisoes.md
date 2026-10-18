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

## D04 · Opção "Só a partir de Alerta" nos avisos (16/10/2026)
**Contexto:** o mockup da tela "Bairros e avisos" oferece dois modos de aviso. O RF02 previa só "avisar quando o estágio mudar".
**Decisão:** manter os dois modos.
- **O estágio mudar** (padrão, recomendado): avisa em toda mudança, para subir ou para baixar.
- **Só a partir de Alerta:** avisa apenas quando o novo estágio for Alerta ou Emergência.

**Por quê:** custa só um parâmetro na mesma regra de notificação e reduz avisos para quem preferir.
**Testes (RF02):** no modo "só a partir de Alerta", a mudança Monitoramento → Atenção não notifica e a mudança Atenção → Alerta notifica.

## D05 · Rótulo curto na barra de estágios (16/10/2026)
**Contexto:** "Monitoramento" não cabe no espaço de cada etapa da barra da tela Início.
**Decisão:** usar **"Monitor."** só na barra. O título grande e o leitor de tela continuam com "Monitoramento" por extenso.
**Por quê:** legibilidade sem perder acessibilidade.
