# CLAUDE.md — regras de trabalho no Alerta Cheia Itajaí

Este arquivo orienta o Claude (e qualquer pessoa do grupo) ao escrever código neste repositório. Leia antes de qualquer alteração. Em caso de conflito, o pedido explícito do usuário no chat prevalece.

## Contexto em 30 segundos
- App Flutter (Android e iOS) de **complemento** aos alertas oficiais de cheia da Defesa Civil de Itajaí. Projeto de extensão da UNIVALI/ADS em que **TDD é critério de avaliação**.
- Arquitetura MVVM em camadas: `ui/` → `domain/` → `data/`. Detalhes em `docs/arquitetura.md`.
- Estágios oficiais: **Monitoramento, Atenção, Alerta, Emergência**. As cotas são **por estação** e vêm do catálogo oficial da Defesa Civil.
- O autor principal é desenvolvedor Java/Spring e iniciante em Flutter, Dart, Git e CI. Explique como para um iniciante e use analogias com Java quando ajudarem.

---

## 1. TDD de verdade (obrigatório)
1. **Vermelho:** escreva o teste primeiro e rode, para mostrar que ele falha pelo motivo certo.
2. **Verde:** escreva o **mínimo** de código para passar. Nada além do que o teste pede.
3. **Refatorar:** melhore o código **sem mudar os testes**. Se precisar mudar um teste, é comportamento novo e começa outro ciclo.
- Cada etapa vira um commit separado (`test:` → `feat:` → `refactor:`), porque o histórico serve de evidência no relatório.
- Mostre ao usuário a saída do terminal de cada etapa e indique o print a tirar.
- Nunca escreva código de produção sem um teste que o exija, salvo infraestrutura (tema, navegação, configuração), e mesmo assim deixe claro que é infraestrutura.

## 2. Testes eficientes
- **Rápidos e determinísticos:** sem rede, sem relógio real, sem aleatoriedade. Injete o relógio e os serviços (ex.: receber `DateTime agora` ou um `Relogio` falso).
- **Valores-limite sempre:** para cada fronteira, teste 1 cm abaixo, exatamente nela e 1 cm acima.
- **Um comportamento por teste**, com nome que descreve a regra em português: `'nível 1,61 m → alerta'`.
- **Estrutura AAA** (Arrange, Act, Assert), com comentário marcando as partes quando ajudar.
- **Tabelas de casos** (`Map` + `forEach`) quando o mesmo comportamento varia só nos dados, como o `@ParameterizedTest` do JUnit.
- **Mocks só nas bordas** (serviços, Firebase, notificações), com `mocktail`. Nunca mocke as regras do `domain/`: teste-as de verdade.
- **Pirâmide:** muitos testes unitários (`domain/`), alguns de widget (`ui/`), poucos de integração (`integration_test/`).
- Teste o **comportamento**, não detalhes de implementação, para que a refatoração não quebre testes à toa.
- Cobertura mínima de **80% em `lib/domain` e `lib/data`**, exigida no CI. A cobertura é consequência do TDD, não meta para "inflar".
- Use dados reais quando existirem (cotas oficiais, leituras reais) e cite a fonte e a data no comentário.

## 3. Simplicidade antes de tudo
- **KISS:** a solução mais simples que resolve o problema atual. Um `if` claro vence um padrão de projeto elegante.
- **YAGNI:** não crie abstração, parâmetro ou classe "para o futuro". Só quando um segundo caso real aparecer.
- **Sem dependência nova sem justificativa.** Antes de adicionar um pacote, explique por que o Flutter/Dart puro não resolve, e peça confirmação.
- Prefira os recursos nativos: `ChangeNotifier` + `ListenableBuilder` para estado e injeção por construtor, sem framework de DI.
- Se houver duas soluções equivalentes, escolha a mais fácil de **ler e testar**.

## 4. Código modular
- **Um arquivo, uma responsabilidade**: um modelo, uma regra ou uma tela por arquivo. Se passar de ~200 linhas, avalie dividir.
- **Funções curtas** (idealmente até ~25 linhas) e com um só propósito.
- **Regra de dependência:** `domain/` é Dart puro e não importa `package:flutter`, `ui/` nem `data/`. A `ui/` não fala direto com serviços: passa pelo ViewModel.
- **Interfaces nas bordas:** todo serviço externo (dados do rio, Firestore, notificações) tem uma interface em `data/servicos/` e ao menos uma implementação falsa para testes.
- **Dados não são código:** cotas, abrigos, contatos e bairros ficam em catálogos (`data/`), nunca espalhados como números mágicos nas regras.
- `test/` espelha `lib/`: `lib/domain/regras/x.dart` ↔ `test/domain/regras/x_test.dart`.

## 5. Estilo e legibilidade
- **Comentários em português explicando cada bloco**: o que faz e por quê. Comentário de cabeçalho em todo arquivo, dizendo o papel dele e a etapa do TDD quando for o caso.
- Nomes em português, claros e sem abreviação: `classificarEstagio`, `cotasDc01`, `abaAtual`. Termos técnicos consagrados podem ficar em inglês (`build`, `widget`, `ViewModel`).
- Prefira **imutabilidade**: campos `final`, construtores `const` quando possível.
- Valide entradas na criação do objeto e lance `ArgumentError` com mensagem que diga **qual** valor está errado.
- Use `enum` para conjuntos fechados (estágios, altura da água), não strings soltas.
- Antes de dizer "pronto", rode e confirme: `dart format .`, `flutter analyze` (zero avisos) e `flutter test`. Se não foi possível rodar, diga isso explicitamente.

## 6. Git e commits
- Conventional Commits em português: `test(rf01): ...`, `feat(rf02): ...`, `refactor:`, `fix:`, `ci:`, `docs:`, `chore:`.
- Commits pequenos e com um só assunto. Uma branch por funcionalidade (`feature/rf01-estagio`), entrando no `main` por Pull Request com CI verde.
- Nunca reescrever o histórico do `main` (`push --force`) nem apagar arquivos sem pedir.

## 7. Segurança, privacidade e acessibilidade
- **Nenhum segredo no repositório:** `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`, `.env` e keystores ficam no `.gitignore`. No CI, use GitHub Secrets. Confira o `git status` antes de cada commit.
- **LGPD:** o app não pede nome, documento, e-mail nem login. Não coletar nem registrar dados pessoais; a localização só é usada no ponto marcado.
- **Offline:** o último alerta recebido precisa ficar disponível sem internet.
- **Acessibilidade:** contraste mínimo de 4,5:1 (cores claras como canela e joelho levam texto escuro), rótulos para leitor de tela (`Semantics`, `tooltip`) e alvos de toque de pelo menos 48 px.
- O app é **complemento**: nunca apresentar uma informação como alerta oficial e sempre deixar visível o caminho para o 199, o 193 e o 192.

## 8. Como trabalhar com o usuário
- **Não invente dados de domínio** (cotas, telefones, abrigos, bairros). Pergunte ou busque a fonte oficial e registre a origem e a data.
- Antes de uma decisão difícil de desfazer (arquitetura, dependência, mudança de requisito), apresente as opções com prós e contras e uma recomendação.
- Entregue em passos que o usuário consiga executar e verificar sozinho, com o comando, o resultado esperado e o que fazer se der errado.
- Mantenha o quadro Scrum no Trello em dia: mova os cartões quando o trabalho começar e quando estiver concluído (CI verde).
