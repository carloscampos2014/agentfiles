---
name: bootstrap-from-code
description: Analisa o codigo-fonte de um projeto existente e gera o comando bootstrap.ps1 completo, detectando stack, estrutura, comandos de build e ferramentas presentes. Ativar com /bootstrap-from-code ou "gerar bootstrap a partir do codigo".
---

# Skill: Bootstrap from Code

Analisa o código-fonte de um projeto que ainda não tem harness configurado e monta o comando `bootstrap.ps1` mais adequado, com todos os parâmetros preenchidos a partir do que o código revela.

## Como ativar

`/bootstrap-from-code` ou dizer "gera o bootstrap baseado no código" / "lê o projeto e monta o bootstrap"

O usuário deve indicar:
- Onde está o projeto (pasta raiz)
- Onde está o agentfiles (ex: `C:\Dev\agentfiles`)

---

## Processo

### Etapa 1 — Detectar stack pelo projeto

Ler os arquivos de configuração na raiz do projeto:

| Arquivo | Indica |
|---------|--------|
| `*.sln`, `*.slnx`, `*.csproj` | .NET (C#) |
| `package.json` | Node.js, TypeScript, JavaScript |
| `pom.xml`, `build.gradle` | Java/Kotlin |
| `Cargo.toml` | Rust |
| `go.mod` | Go |
| `requirements.txt`, `pyproject.toml`, `setup.py` | Python |
| `pubspec.yaml` | Flutter/Dart |
| `*.xcodeproj`, `Package.swift` | Swift/iOS |
| `Gemfile` | Ruby |
| `composer.json` | PHP |

Ler também:
- `README.md` — descrição, stack mencionada, comandos de build/test
- `Makefile`, `justfile` — comandos disponíveis
- `Dockerfile`, `docker-compose.yml` — serviços e dependências
- `.github/workflows/*.yml` — pipelines CI revelam comandos exatos de build e test

### Etapa 2 — Inferir comandos de build e test

Com base na stack detectada, identificar os comandos mais prováveis:

**Exemplos por stack:**
- `.NET` → `dotnet build *.sln -c Debug` / `dotnet test tests/ --logger console;verbosity=minimal`
- `Node/npm` → `npm run build` / `npm test`
- `Node/yarn` → `yarn build` / `yarn test`
- `Python` → `python -m build` / `pytest`
- `Go` → `go build ./...` / `go test ./...`
- `Rust` → `cargo build` / `cargo test`

Se o `README.md` ou CI tiver o comando exato, usar esse — é mais confiável que inferir.

### Etapa 3 — Detectar nome e descrição

- **Nome** — nome da pasta raiz ou nome da solution/package principal
- **Descrição** — primeira linha do `README.md`, ou description no `package.json` / `pyproject.toml`

### Etapa 4 — Detectar repositório GitHub

Verificar:
```
git remote get-url origin
```
Extrair owner e repo do URL (ex: `github.com/owner/repo`).

### Etapa 5 — Detectar ferramentas já presentes

Verificar quais pastas/arquivos já existem:
- `.kiro/` → `-Kiro` (já tem, avisar)
- `.claude/` → `-Claude` (já tem, avisar)
- `.github/copilot-instructions.md` → `-Copilot` (já tem, avisar)
- `.amazonq/` → `-AmazonQ` (já tem, avisar)
- `.trae/` → `-Trae` (já tem, avisar)
- `AGENTS.md` → `-Codex` (já tem, avisar)
- `GEMINI.md` → `-Gemini` (já tem, avisar)

Para ferramentas já presentes: avisar que o bootstrap não sobrescreverá arquivos existentes (`-replace $false`).

### Etapa 6 — Montar o comando

```powershell
& "C:\Dev\agentfiles\scripts\bootstrap.ps1" `
    -ProjectPath "C:\Dev\__NOME_PROJETO__" `
    -ProjectName "__NOME_PROJETO__" `
    -ProjectDescription "__DESCRICAO__" `
    -StackDescription "__STACK__" `
    -GithubOwner "__OWNER__" `
    -GithubRepo "__REPO__" `
    -BuildCommand "__BUILD_COMMAND__" `
    -TestCommand "__TEST_COMMAND__" `
    -Kiro -Claude -Copilot
```

### Etapa 7 — Apresentar resultado

```
## Bootstrap gerado a partir do código

### Stack detectada
[descrição da stack com evidências — qual arquivo revelou cada coisa]

### Parâmetros identificados
| Parâmetro | Valor | Fonte |
|-----------|-------|-------|
| ProjectName | NomeDoProjeto | Pasta raiz / solution |
| BuildCommand | dotnet build ... | .github/workflows/ci.yml |
| ...

### Ferramentas recomendadas
- ✅ Kiro (sempre)
- ✅ Claude (recomendado)
- ⚠️ .github já existe — Copilot: bootstrap não sobrescreverá arquivos existentes

### Parâmetros pendentes
- [o que não foi possível detectar]

### Comando

\`\`\`powershell
& "C:\Dev\agentfiles\scripts\bootstrap.ps1" `
    ...
\`\`\`
```

---

## Regras

- Nunca executar o bootstrap diretamente — apenas gerar o comando para o usuário revisar e executar
- Sempre indicar a fonte de cada parâmetro detectado (qual arquivo revelou)
- Se o projeto já tiver harness parcial, usar `update-harness.ps1` em vez de bootstrap — avisar o usuário
- Se não conseguir detectar build command com confiança, deixar o placeholder e indicar como preencher
