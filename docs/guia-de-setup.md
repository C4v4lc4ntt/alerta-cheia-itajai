# Guia de setup — do zero ao primeiro commit (Windows)

Escrito para quem nunca usou Flutter, Git nem CI. Siga na ordem; cada parte termina com uma checagem. Serve para todos os integrantes do grupo.

---

## Parte 1 — Instalar o ambiente

### 1.1 Requisitos
- Windows 10 ou 11, 64 bits.
- ~15 GB livres (Flutter + Android Studio + emulador).
- Virtualização ativada na BIOS (necessária para o emulador rodar rápido). Para conferir: Gerenciador de Tarefas → Desempenho → CPU → "Virtualização: Habilitado".

### 1.2 Git for Windows
O Flutter depende do Git, então ele vem primeiro.
1. Baixe em **git-scm.com/download/win** e instale. Pode aceitar as opções padrão; só confira que está marcado **"Git Credential Manager"** (é ele que faz o login no GitHub depois).
2. Abra o **PowerShell** e configure sua identidade (aparece em cada commit):
   ```powershell
   git config --global user.name "Matheus Almeida"
   git config --global user.email "seu-email@exemplo.com"   # o mesmo da conta GitHub
   git config --global init.defaultBranch main
   git config --global core.autocrlf true
   ```
3. Checagem: `git --version` mostra a versão.

### 1.3 VS Code + Flutter SDK
1. Instale o **VS Code** (code.visualstudio.com).
2. Na aba Extensões (Ctrl+Shift+X), instale **Flutter** (da Dart Code). Ela já instala a extensão Dart.
3. Ctrl+Shift+P → digite **"Flutter: New Project"**. Como ainda não há SDK, o VS Code oferece **"Download SDK"**.
4. Escolha uma pasta **sem espaços e fora de "Arquivos de Programas"**, por exemplo `C:\dev`. O SDK vai para `C:\dev\flutter`.
5. Quando ele perguntar, clique em **"Add SDK to PATH"**. Feche e abra o PowerShell de novo.
6. Checagem: `flutter --version`.

> Alternativa manual: baixar o zip do Flutter em docs.flutter.dev, extrair em `C:\dev\flutter` e adicionar `C:\dev\flutter\bin` à variável PATH.

### 1.4 Android Studio (para o Android SDK e o emulador)
Mesmo programando no VS Code, o Android Studio é o jeito mais fácil de instalar o Android SDK.
1. Baixe em developer.android.com/studio e instale com as opções padrão.
2. Abra → **More Actions → SDK Manager**:
   - Aba **SDK Platforms**: marque a versão mais recente do Android.
   - Aba **SDK Tools**: marque **Android SDK Build-Tools**, **Android SDK Command-line Tools**, **Android Emulator** e **Android SDK Platform-Tools**. Clique em Apply.
3. Aceite as licenças no PowerShell (responda `y` a tudo):
   ```powershell
   flutter doctor --android-licenses
   ```

### 1.5 Emulador (ou seu celular)
**Emulador:** Android Studio → More Actions → **Virtual Device Manager → Create device** → escolha um Pixel → baixe uma imagem de sistema recente (x86_64) → Finish → clique em ▶ para ligar.

**Celular Android (recomendado, é mais leve):** Configurações → Sobre o telefone → toque 7 vezes em "Número da versão" para liberar o modo desenvolvedor → Opções do desenvolvedor → ative **Depuração USB** → conecte no cabo e aceite o aviso no celular.

Checagem: `flutter devices` lista o emulador ou o celular.

### 1.6 `flutter doctor`
```powershell
flutter doctor -v
```
O que precisa estar com ✓:
- **Flutter**
- **Android toolchain**
- **Android Studio** e/ou **VS Code**
- **Connected device** (com o emulador ligado ou o celular plugado)

O que **pode ficar com ✗ ou ! sem problema** neste projeto:
- **Visual Studio** — só serve para apps desktop Windows (fora do escopo).
- **Chrome** — só para web (fora do escopo).
- Xcode não aparece no Windows; o iOS é validado no GitHub Actions.

📸 *Print para o relatório:* a saída do `flutter doctor`.

---

## Parte 2 — Criar o projeto

### 2.1 Gerar o projeto base
O `flutter create` gera as pastas nativas `android/` e `ios/`, que não dá para escrever à mão.
```powershell
cd C:\dev
flutter create --org br.univali.ads --project-name alerta_cheia_itajai --platforms android,ios --description "App complementar de alerta de cheias em Itajaí" alerta-cheia-itajai
cd alerta-cheia-itajai
```

### 2.2 Copiar os arquivos deste pacote por cima
1. **Apague** `test\widget_test.dart` (é o teste do app de exemplo "contador" e vai falhar com o nosso app).
2. Copie, substituindo quando perguntar: `lib\`, `test\`, `.github\`, `docs\`, `assets\`, `README.md`, `CLAUDE.md`, `.gitignore`, `.gitattributes`.

### 2.3 Dependências de teste
```powershell
flutter pub add --dev mocktail
```
Depois abra o `pubspec.yaml` e, dentro de `dev_dependencies:`, acrescente o `integration_test` (ele vem com o próprio Flutter, por isso usa `sdk:`):
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:      # ← adicionar
    sdk: flutter         # ← adicionar
  flutter_lints: ...     # (já existe)
  mocktail: ...          # (adicionado pelo comando acima)
```

> No `pubspec.yaml`, a indentação é de 2 espaços e importa. Ele é o equivalente ao `pom.xml`.

### 2.4 Fonte Archivo
1. Em fonts.google.com, procure **Archivo** → "Get font" → "Download all". No zip, abra a pasta `static\` e copie para `assets\fonts\` do projeto: `Archivo-Regular.ttf`, `Archivo-Medium.ttf`, `Archivo-SemiBold.ttf` e `Archivo-Bold.ttf`. Apague o `.gitkeep` da pasta.
2. No `pubspec.yaml`, dentro da seção `flutter:` (perto de `uses-material-design: true`), adicione:
```yaml
flutter:
  uses-material-design: true
  fonts:
    - family: Archivo
      fonts:
        - asset: assets/fonts/Archivo-Regular.ttf
        - asset: assets/fonts/Archivo-Medium.ttf
          weight: 500
        - asset: assets/fonts/Archivo-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Archivo-Bold.ttf
          weight: 700
```
A fonte é **embutida** no app (e não baixada da internet) para funcionar offline, que é um requisito.

### 2.5 Checagem
```powershell
flutter pub get
dart format .
flutter analyze
flutter test
flutter run
```
Esperado: `No issues found!`, `All tests passed!` e o app abrindo com as 4 abas.

---

## Parte 3 — Git e GitHub

### 3.1 Os conceitos em 1 minuto
| Termo | O que é | Analogia |
|---|---|---|
| **Repositório** | A pasta do projeto + todo o histórico de versões | Um "controle de revisões" de projeto elétrico, só que automático |
| **Commit** | Uma foto do projeto num momento, com uma mensagem | Uma revisão (Rev. A, Rev. B...) com descrição da alteração |
| **Branch** | Uma linha paralela de trabalho | Uma cópia de trabalho que depois é juntada à oficial |
| **main** | A branch oficial, sempre funcionando | A revisão aprovada |
| **Remote / origin** | A cópia do repositório no GitHub | O servidor de arquivos da empresa |
| **Push / Pull** | Enviar / trazer commits do GitHub | Upload / download |
| **Pull Request (PR)** | Pedido para juntar uma branch no main, com revisão | Pedido de aprovação de revisão |

O ciclo do dia a dia é: **editar → `git add` (separar o que vai na foto) → `git commit` (tirar a foto) → `git push` (enviar)**.

### 3.2 Criar o repositório no GitHub
1. Crie a conta em github.com (se ainda não tiver).
2. Canto superior direito **+ → New repository**:
   - Nome: `alerta-cheia-itajai`
   - **Public** (portfólio + minutos de macOS gratuitos no Actions)
   - **NÃO** marque "Add a README", nem .gitignore, nem licença (já temos esses arquivos; marcar cria conflito).
3. Clique em **Create repository** e copie a URL que aparece (termina em `.git`).

### 3.3 Primeiro commit
No PowerShell, dentro da pasta do projeto:
```powershell
git init                              # transforma a pasta em repositório
git status                            # lista o que será versionado
```
**Antes de seguir, leia a lista do `git status`.** Não pode aparecer nenhum `google-services.json`, `GoogleService-Info.plist` ou `firebase_options.dart`. (Agora não existem; a partir da Sprint 3, confira sempre.) Uma chave que entra num commit fica no histórico para sempre, mesmo se apagada depois.

```powershell
git add .                             # separa todos os arquivos para o commit
git commit -m "chore: criar projeto Flutter com arquitetura MVVM e CI"
git remote add origin https://github.com/SEU_USUARIO/alerta-cheia-itajai.git
git push -u origin main               # envia; na 1ª vez abre o login do GitHub no navegador
```
Atualize a página do repositório no GitHub: os arquivos estarão lá. No README, troque `SEU_USUARIO` pelo seu usuário no badge do CI (e faça um commit `docs: ajustar badge do CI`).

### 3.4 Padrão das mensagens de commit
Usamos o padrão **Conventional Commits**: `tipo(escopo): descrição no imperativo`.

| Tipo | Quando |
|---|---|
| `test` | escreveu um teste (no TDD: a etapa **vermelha**) |
| `feat` | nova funcionalidade (no TDD: a etapa **verde**) |
| `refactor` | melhorou o código sem mudar comportamento |
| `fix` | corrigiu um bug |
| `ci` | mudou o workflow do GitHub Actions |
| `docs` | README e documentação |
| `chore` | configuração, dependências |

Exemplo do RF01: `test(rf01): classificar nível do rio em estágio de alerta` → `feat(rf01): implementar classificador de estágio` → `refactor(rf01): extrair limites para constantes`.

### 3.5 Trabalho em grupo (a partir do RF01)
```powershell
git switch -c feature/rf01-estagio    # cria e entra numa branch nova
# ... trabalha e faz commits ...
git push -u origin feature/rf01-estagio
```
No GitHub aparece o botão **"Compare & pull request"**. O CI roda no PR; com tudo verde, clique em **Merge**. Depois, no PC:
```powershell
git switch main
git pull
```
Para adicionar os colegas: repositório → Settings → Collaborators → Add people.

---

## Parte 4 — CI com GitHub Actions

### 4.1 O que acontece a cada push
O arquivo `.github/workflows/ci.yml` (comentado linha a linha) manda o GitHub:
1. ligar uma máquina Linux, baixar o código e instalar o Flutter;
2. verificar formatação (`dart format`), rodar análise estática (`flutter analyze`) e **todos os testes com cobertura** (`flutter test --coverage`);
3. guardar o relatório `lcov.info` para download;
4. no `main`, compilar um APK Android e compilar para **iOS numa máquina macOS** (é assim que validamos iOS sem ter Mac).

### 4.2 Ver o resultado
Repositório → aba **Actions** → clique na execução. Verde ✓ = tudo passou; vermelho ✗ = clique no passo que falhou para ver o erro.

Os erros mais comuns no começo:
- **"Verificar formatação" falhou** → rode `dart format .` no PC, faça commit e push.
- **"Análise estática" falhou** → rode `flutter analyze` no PC e corrija o que ele apontar.

📸 *Prints para o relatório:* a lista de execuções na aba Actions e o detalhe de uma execução verde.

### 4.3 Cobertura mínima de 80%
O passo que **reprova o CI abaixo de 80%** na lógica (`lib/domain` e `lib/data`) está comentado no `ci.yml` e será ativado junto com o primeiro código do RF01, num commit `ci: exigir 80% de cobertura na lógica`. Antes disso não há lógica para medir.

Para ver a cobertura no PC, a extensão **Coverage Gutters** do VS Code lê o `coverage/lcov.info` e pinta as linhas cobertas de verde.

---

## Parte 5 — Segredos do Firebase (Sprint 3)
- Os arquivos do Firebase já estão no `.gitignore`.
- Quando o Firebase entrar, os arquivos serão guardados como **GitHub Secrets** (Settings → Secrets and variables → Actions) e recriados pelo CI na hora do build.
- Se uma chave vazar por engano: gere outra no console do Firebase e restrinja a antiga — apagar o arquivo não basta, porque ele continua no histórico.
