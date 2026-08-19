# agentfiles

> Os dotfiles do seu ambiente de desenvolvimento com agentes AI.

Templates, automações e documentação para inicializar o harness de desenvolvimento em novos projetos — da mesma forma que `dotfiles` padroniza seu shell, o `agentfiles` padroniza como os agentes AI se comportam no seu projeto.

Suporta **8 ferramentas**: Kiro IDE · Claude Code · GitHub Copilot · Amazon Q · OpenAI Codex · Gemini CLI · Qwen Code · TRAE IDE

---

## Início rápido

```powershell
# Projeto .NET — todas as ferramentas
C:\Dev\agentfiles\scripts\bootstrap.ps1 `
    -ProjectPath        "C:\Dev\MeuProjeto" `
    -ProjectName        "MeuProjeto" `
    -ProjectDescription "Sistema de gestão de contratos com .NET e Blazor." `
    -StackDescription   ".NET 10, C#, PostgreSQL, Blazor WASM" `
    -GithubOwner        "meuusuario" `
    -GithubRepo         "MeuProjeto" `
    -BuildCommand       "dotnet build MeuProjeto.sln -c Debug" `
    -TestCommand        "dotnet test tests/ --logger console;verbosity=minimal" `
    -All

# Projeto Node/TypeScript — só Kiro + Claude + Codex
C:\Dev\agentfiles\scripts\bootstrap.ps1 `
    -ProjectPath        "C:\Dev\MeuApp" `
    -ProjectName        "MeuApp" `
    -ProjectDescription "API REST em Node.js com TypeScript e PostgreSQL." `
    -StackDescription   "Node.js, TypeScript, PostgreSQL, Express" `
    -GithubOwner        "meuusuario" `
    -GithubRepo         "MeuApp" `
    -BuildCommand       "npm run build" `
    -TestCommand        "npm test" `
    -Kiro -Claude -Codex
```

---

## O que cada ferramenta recebe

### Kiro IDE (`-Kiro`)

```
.kiro/
├── harness-config.json              ← config central (liga/desliga componentes)
├── settings/
│   └── mcp.json                     ← MCPs: github, git, filesystem, memory, fetch, figma...
├── steering/                        ← regras e instruções (lidas automaticamente)
│   ├── harness-output-formatter.md  (always) formato de respostas
│   ├── harness-anti-patterns.md     (always) comportamentos proibidos
│   ├── harness-agent-router.md      (always) classificação de pedidos
│   ├── harness-one-question.md      (always) uma pergunta por vez
│   ├── harness-verification-report.md (auto) evidência antes de "concluído"
│   ├── method-development.md        (manual) loop de 7 passos
│   └── git-commits.md               (auto)   conventional commits
├── hooks/                           ← automações por evento do IDE
│   ├── guardrails-pre-write.json    bloqueia git push --force, rm -rf, push para main
│   ├── build-test-on-stop.json      roda build+testes ao encerrar sessão
│   ├── pre-task-spec-check.json     lê spec antes de iniciar task
│   ├── validate-task-completion.json valida fidelidade ao spec após task
│   ├── session-summary.json         salva resumo em .kiro/knowledge/sessions/
│   └── missing-test-alert.json      alerta ao criar arquivo sem teste
├── knowledge/
│   └── INDEX.md                     ← índice da base de conhecimento
├── quality/
│   ├── history.json                 ← quality scores por task
│   └── tech-debt.json               ← dívida técnica detectada
└── skills/                          ← pasta para skills do projeto
```

Steerings globais instalados em `~/.kiro/steering/` (disponíveis em todos os projetos):
`engineering-standards`, `workflow-aprovacao`, `workflow-desenvolvimento`, `graphify`, `continuar-de-onde-paramos`

### Claude Code (`-Claude`)

```
.mcp.json                            ← MCP de projeto (github, git, filesystem, memory, fetch)
.claude/
├── CLAUDE.md                        ← índice + tabela de agents/skills/commands
├── settings.json                    ← hooks (PostToolUse, PreToolUse) + permissões allow/deny
├── settings.local.json              ← overrides pessoais (gitignored)
├── agents/                          ← subagentes especializados — invocar com @nome
│   ├── senior-developer.md          model: sonnet — implementação, bugs, refactoring
│   ├── solutions-architect.md       model: sonnet — arquitetura, ADRs, diagramas
│   ├── qa-engineer.md               model: sonnet — testes, cobertura, validação
│   └── business-analyst.md          model: sonnet — requisitos, user stories, MoSCoW
├── rules/                           ← carregadas automaticamente
│   ├── engineering-standards.md     SOLID, Clean Code, segurança
│   ├── workflow.md                  branches, commits, PRs
│   ├── senior-developer.md          padrões de implementação com exemplos de código
│   ├── solutions-architect.md       Clean Architecture, diagramas, ADR template
│   ├── 01-result-pattern.md         Result<T>, NotificationContext
│   ├── 02-logging-observability.md  FileLoggingService, auditoria, GlobalExceptionMiddleware
│   ├── 03-testing-requirements.md   cobertura mínima, AAA, Testcontainers
│   └── 04-database-best-practices.md índices, soft delete, audit log, paginação
├── skills/                          ← ativar com /nome
│   ├── code-review/SKILL.md         revisão estruturada com checklist e severidades
│   ├── spec-driven-development/SKILL.md requirements → design → tasks
│   ├── systematic-debugging/SKILL.md 6 etapas + twin check
│   └── architecture-design/SKILL.md padrões arquiteturais + ADR template
└── commands/
    └── generate-docs.md             /generate-docs — gera documentação técnica
```

### GitHub Copilot (`-Copilot`)

```
.github/
├── copilot-instructions.md          ← regras de ouro, anti-patterns, padrões de código, comandos
├── agents/                          ← agentes especializados
│   ├── senior-developer.md
│   ├── solutions-architect.md
│   ├── qa-engineer.md
│   └── business-analyst.md
├── skills/                          ← skills ativáveis
│   ├── code-review.md
│   ├── spec-driven-development.md
│   ├── systematic-debugging.md
│   ├── architecture-design.md
│   └── README.md
└── commands/
    └── generate-docs.md
```

### Amazon Q (`-AmazonQ`)

```
.amazonq/
├── rules/                           ← frontmatter com name + tools + model obrigatório
│   ├── senior-developer.md
│   ├── solutions-architect.md
│   ├── qa-engineer.md
│   └── business-analyst.md
└── skills/                          ← mesmo conteúdo do .github/skills/
    ├── code-review.md
    ├── spec-driven-development.md
    ├── systematic-debugging.md
    ├── architecture-design.md
    └── README.md
```

### OpenAI Codex (`-Codex`)

```
AGENTS.md                            ← instrução principal (hierarquia: global → projeto → subdir)
.codex/
└── config.toml                      ← MCPs de projeto (github, filesystem, fetch, memory)
```

### Gemini CLI (`-Gemini`)

```
GEMINI.md                            ← instrução principal (hierarquia: ~/.gemini → projeto → subdir)
```

Skills, hooks e agents do Gemini existem dentro de **extensões** (pacotes instalados separadamente via `gemini extensions install`), não como arquivos de projeto.

### Qwen Code (`-Qwen`)

```
QWEN.md                              ← instrução principal (mesma mecânica do Gemini CLI)
```

Agents, skills e MCPs do Qwen existem dentro de **extensões** (`qwen extensions install`), não como arquivos de projeto.

### TRAE IDE (`-Trae`)

```
.trae/
├── rules/                           ← guardrails permanentes (sempre ativos)
│   ├── 01-engineering-standards.md  SOLID, Clean Code, Result Pattern
│   ├── 02-git-workflow.md           branches, commits, PRs, proibições
│   ├── 03-architecture.md           Clean Architecture, nomenclatura, dependency rule
│   └── 04-testing-requirements.md  cobertura mínima, AAA, cenários obrigatórios
└── skills/                          ← procedimentos ativados sob demanda
    ├── code-review.md
    ├── systematic-debugging.md
    └── spec-driven-development.md
```

Agents do TRAE são configurados pela UI do IDE, não por arquivos de projeto.

---

## Parâmetros do bootstrap

| Parâmetro | Obrigatório | Descrição |
|-----------|-------------|-----------|
| `-ProjectPath` | Não | Caminho absoluto do projeto. Padrão: diretório atual |
| `-ProjectName` | **Sim** | Nome do projeto |
| `-ProjectDescription` | **Sim** | Descrição em 1-2 frases |
| `-StackDescription` | Não | Stack tecnológica principal |
| `-GithubOwner` | Não | Owner do repositório GitHub |
| `-GithubRepo` | Não | Nome do repositório GitHub |
| `-BuildCommand` | Não | Comando de build completo |
| `-TestCommand` | Não | Comando de testes |
| `-LintCommand` | Não | Comando de lint |
| `-DbConnectionString` | Não | Connection string para MCP postgres (adicionado ao mcp.json) |
| `-Kiro` | Não | Inicializar Kiro IDE |
| `-Claude` | Não | Inicializar Claude Code |
| `-Copilot` | Não | Inicializar GitHub Copilot |
| `-AmazonQ` | Não | Inicializar Amazon Q |
| `-Codex` | Não | Inicializar OpenAI Codex |
| `-Gemini` | Não | Inicializar Gemini CLI |
| `-Qwen` | Não | Inicializar Qwen Code |
| `-Trae` | Não | Inicializar TRAE IDE |
| `-All` | Não | Inicializar todas as ferramentas |

Se nenhuma flag for passada, `-Kiro` é ativado por padrão.

---

## Após o bootstrap: passos obrigatórios

**1. Criar `project-standards.md` no Kiro**

O steering mais importante que o bootstrap não gera automaticamente — contém os padrões específicos da stack:

```markdown
---
inclusion: auto
---

# Padrões específicos — NomeDoProjeto

## Stack obrigatória
- Backend: .NET 10, C#, PostgreSQL, Dapper
- Testes: xUnit, FluentAssertions, Testcontainers, NSubstitute

## Estrutura de projetos
src/
  NomeProjeto.Domain/
  NomeProjeto.Application/
  NomeProjeto.Infrastructure/
  NomeProjeto.Api/
tests/
  NomeProjeto.Domain.Tests/
  NomeProjeto.Application.Tests/
  NomeProjeto.IntegrationTests/
```

Salvar em `.kiro/steering/project-standards.md`.

**2. Ajustar os comandos no `harness-config.json`**

Se não passou `-BuildCommand` e `-TestCommand` no bootstrap:

```json
"build": {
  "command": "dotnet build NomeProjeto.sln -c Debug",
  "test_command": "dotnet test tests/ --logger console;verbosity=minimal",
  "lint_command": ""
}
```

**3. Adicionar hooks de stack específica (opcional — Kiro)**

Para projetos .NET, adicione em `.kiro/hooks/build-on-cs-save.json`:

```json
{
  "version": "v1",
  "hooks": [{
    "name": "Build ao salvar C#",
    "trigger": "PostFileSave",
    "matcher": "\\.cs$",
    "action": {
      "type": "command",
      "command": "dotnet build NomeProjeto.sln --no-restore -v quiet 2>&1 | Select-Object -Last 5",
      "timeout": 60
    }
  }]
}
```

**4. Configurar variáveis de ambiente**

| Variável | Usada por | Como configurar |
|----------|-----------|----------------|
| `GITHUB_PAT` | MCP github (Kiro, Claude, Codex) | `$env:GITHUB_PAT = "ghp_..."` |
| `FIGMA_API_KEY` | MCP figma (Kiro) | `$env:FIGMA_API_KEY = "..."` |

---

## Referência rápida — Kiro steerings

| Steering | Inclusion | Ativar com |
|----------|-----------|-----------|
| `harness-output-formatter` | `always` | Automático |
| `harness-anti-patterns` | `always` | Automático |
| `harness-agent-router` | `always` | Automático |
| `harness-one-question` | `always` | Automático |
| `harness-verification-report` | `auto` | Automático |
| `git-commits` | `auto` | Automático |
| `method-development` | `manual` | `#method-development` no chat |
| `engineering-standards` *(global)* | `auto` | Automático |
| `workflow-aprovacao` *(global)* | `auto` | Automático |
| `workflow-desenvolvimento` *(global)* | `auto` | Automático |
| `continuar-de-onde-paramos` *(global)* | `manual` | `#continuar-de-onde-paramos` |

---

## Documentação completa

| Documento | O que cobre |
|-----------|-------------|
| [`docs/INDEX.md`](docs/INDEX.md) | Índice de toda a documentação com caminhos rápidos |
| [`docs/GUIA-HARNESS.md`](docs/GUIA-HARNESS.md) | Referência técnica completa — inventário, matriz de capacidades, como estender |
| [`docs/conceitos/`](docs/conceitos/) | O que é cada componente: harness, steering, hooks, skills, agents, MCP, specs |
| [`docs/guias-criacao/`](docs/guias-criacao/) | Como criar steering, hook, skill, agent, MCP e spec do zero |
| [`docs/ferramentas/`](docs/ferramentas/) | Guia de uso por ferramenta: Kiro, Claude, Copilot, Amazon Q, Codex, Gemini, Qwen, TRAE |
| [`docs/templates/`](docs/templates/) | O que faz e como customizar cada template incluído |
