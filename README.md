# agentfiles

> Os dotfiles do seu ambiente de desenvolvimento com agentes AI.

Templates, automações e documentação para inicializar o harness de desenvolvimento em novos projetos — da mesma forma que `dotfiles` padroniza seu shell, o `agentfiles` padroniza como os agentes AI se comportam no seu projeto.

Suporta **8 ferramentas**: Kiro IDE · Claude Code · GitHub Copilot · Amazon Q · OpenAI Codex · Gemini CLI · Qwen Code · TRAE IDE

---

## Pré-requisitos

Node.js LTS, Python 3.10+, uv, Git e GitHub CLI.

```powershell
# Windows — instala tudo via winget
.\scripts\windows\install-deps.ps1
```

```bash
# macOS / Linux — instala via brew / apt / dnf / pacman
chmod +x scripts/unix/install-deps.sh && ./scripts/unix/install-deps.sh
```

Ver [`docs/INSTALACAO.md`](docs/INSTALACAO.md) para instruções detalhadas por OS.

---

## Início rápido

```powershell
# Windows — todas as ferramentas
.\scripts\bootstrap.ps1 `
    -ProjectPath        "C:\Dev\MeuProjeto" `
    -ProjectName        "MeuProjeto" `
    -ProjectDescription "Sistema de gestão de contratos com .NET e Blazor." `
    -StackDescription   ".NET 10, C#, PostgreSQL, Blazor WASM" `
    -GithubOwner        "meuusuario" `
    -GithubRepo         "MeuProjeto" `
    -BuildCommand       "dotnet build MeuProjeto.sln -c Debug" `
    -TestCommand        "dotnet test tests/ --logger console;verbosity=minimal" `
    -All

# Windows — só Kiro + Claude + Codex
.\scripts\bootstrap.ps1 `
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

```bash
# macOS / Linux — wizard interativo
./scripts/unix/new-project.sh

# macOS / Linux — direto com argumentos
./scripts/unix/bootstrap.sh \
    --ProjectPath "$HOME/Dev/MeuApp" \
    --ProjectName "MeuApp" \
    --ProjectDescription "API REST em Node.js com TypeScript." \
    --StackDescription "Node.js, TypeScript, PostgreSQL" \
    --Kiro --Claude --Codex
```

---

## O que cada ferramenta recebe

### Kiro IDE (`-Kiro`)

```
.kiro/
├── harness-config.json              ← config central (liga/desliga componentes)
├── settings/
│   └── mcp.json                     ← MCPs: github, git, filesystem, knowledge-rag, memory, fetch, figma...
├── steering/                        ← regras e instruções (lidas automaticamente)
│   ├── harness-output-formatter.md  (always) formato de respostas
│   ├── harness-anti-patterns.md     (always) comportamentos proibidos
│   ├── harness-agent-router.md      (always) classificação de pedidos
│   ├── harness-one-question.md      (always) uma pergunta por vez
│   ├── harness-verification-report.md (auto) evidência antes de "concluído"
│   ├── harness-knowledge-rag.md     (always) quando e como usar knowledge-rag e memory
│   ├── briefing-detalhado.md        (always) formato obrigatório de briefing por arquivo
│   ├── method-development.md        (manual) loop de 7 passos
│   └── git-commits.md               (auto)   conventional commits
├── hooks/                           ← automações por evento do IDE
│   ├── guardrails-pre-write.json    bloqueia git push --force, rm -rf, push para main
│   ├── build-test-on-stop.json      roda build+testes ao encerrar sessão
│   ├── pre-task-spec-check.json     lê spec antes de iniciar task
│   ├── validate-task-completion.json valida fidelidade ao spec após task
│   ├── session-summary.json         resumo v2 com ADRs inline + contexto crítico
│   ├── harness-retrospective.json   planejado vs real ao concluir última task do spec
│   └── missing-test-alert.json      alerta ao criar arquivo sem teste
├── knowledge/
│   ├── INDEX.md                     ← índice da base de conhecimento
│   └── memory.jsonl                 ← grafo de conhecimento persistente (MCP memory)
├── quality/
│   ├── history.json                 ← quality scores por task
│   ├── tech-debt.json               ← dívida técnica detectada
│   └── retrospectives/              ← relatórios de retrospectiva por spec
└── skills/
    ├── bootstrap-from-docs/SKILL.md  lê documentos e gera comando bootstrap
    └── bootstrap-from-code/SKILL.md  lê código existente e gera comando bootstrap
```

Steerings globais instalados em `~/.kiro/steering/` (disponíveis em todos os projetos):
`engineering-standards`, `workflow-aprovacao`, `workflow-desenvolvimento`, `graphify`, `continuar-de-onde-paramos`

### Claude Code (`-Claude`)

```
.mcp.json                            ← MCP de projeto (github, git, filesystem, knowledge-rag, memory, fetch)
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
│   ├── briefing-detalhado.md        formato obrigatório de briefing por arquivo
│   ├── 01-result-pattern.md         Result<T>, NotificationContext
│   ├── 02-logging-observability.md  FileLoggingService, auditoria, GlobalExceptionMiddleware
│   ├── 03-testing-requirements.md   cobertura mínima, AAA, Testcontainers
│   └── 04-database-best-practices.md índices, soft delete, audit log, paginação
├── skills/                          ← ativar com /nome
│   ├── code-review/SKILL.md         revisão estruturada com checklist e severidades
│   ├── spec-driven-development/SKILL.md requirements → design → tasks
│   ├── systematic-debugging/SKILL.md 6 etapas + twin check
│   ├── architecture-design/SKILL.md padrões arquiteturais + ADR template
│   ├── bootstrap-from-docs/SKILL.md lê documentos e gera comando bootstrap
│   └── bootstrap-from-code/SKILL.md lê código existente e gera comando bootstrap
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
├── instructions/                    ← always-on (applyTo: "**")
│   └── briefing-detalhado.md        formato obrigatório de briefing por arquivo
├── skills/                          ← skills ativáveis
│   ├── code-review.md
│   ├── spec-driven-development.md
│   ├── systematic-debugging.md
│   ├── architecture-design.md
│   ├── bootstrap-from-docs.md
│   ├── bootstrap-from-code.md
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
│   ├── business-analyst.md
│   └── briefing-detalhado.md
└── skills/
    ├── code-review.md
    ├── spec-driven-development.md
    ├── systematic-debugging.md
    ├── architecture-design.md
    ├── bootstrap-from-docs.md
    ├── bootstrap-from-code.md
    └── README.md
```

### OpenAI Codex (`-Codex`)

```
AGENTS.md                            ← instrução principal + briefing-detalhado (append)
.codex/
└── config.toml                      ← MCPs de projeto (github, filesystem, fetch, memory)
```

### Gemini CLI (`-Gemini`)

```
GEMINI.md                            ← instrução principal + briefing-detalhado (append)
```

Skills, hooks e agents do Gemini existem dentro de **extensões** (pacotes instalados separadamente via `gemini extensions install`), não como arquivos de projeto.

### Qwen Code (`-Qwen`)

```
QWEN.md                              ← instrução principal + briefing-detalhado (append)
```

Agents, skills e MCPs do Qwen existem dentro de **extensões** (`qwen extensions install`), não como arquivos de projeto.

### TRAE IDE (`-Trae`)

```
.trae/
├── rules/                           ← guardrails permanentes (sempre ativos)
│   ├── 01-engineering-standards.md  SOLID, Clean Code, Result Pattern
│   ├── 02-git-workflow.md           branches, commits, PRs, proibições
│   ├── 03-architecture.md           Clean Architecture, nomenclatura, dependency rule
│   ├── 04-testing-requirements.md   cobertura mínima, AAA, cenários obrigatórios
│   └── briefing-detalhado.md        formato obrigatório de briefing por arquivo
└── skills/                          ← procedimentos ativados sob demanda
    ├── code-review.md
    ├── systematic-debugging.md
    ├── spec-driven-development.md
    ├── bootstrap-from-docs.md
    └── bootstrap-from-code.md
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

## Após o bootstrap

O bootstrap cria os arquivos base. Dois passos restam para completar:

**1. Criar o arquivo de padrões do projeto**

Cada ferramenta tem um arquivo onde ficam os padrões específicos da stack — estrutura de pastas, bibliotecas, regras de negócio. O bootstrap não gera esse arquivo porque só você sabe o conteúdo.

Consulte o guia da sua ferramenta em [`docs/ferramentas/`](docs/ferramentas/) para saber onde e como criar.

**2. Configurar variáveis de ambiente**

| Variável | Usada por |
|----------|-----------|
| `GITHUB_PAT` | MCP github |
| `FIGMA_API_KEY` | MCP figma (opcional) |

Para detalhes por ferramenta, exemplos de hooks de stack e referência de steerings, veja [`docs/ferramentas/`](docs/ferramentas/).

---

## Scripts disponíveis

| Script | O que faz |
|--------|-----------|
| `bootstrap.ps1` | Inicializa novo projeto com templates e placeholders substituídos |
| `update-harness.ps1` | Atualiza projeto existente comparando com templates (só o que mudou) |
| `validate-harness.ps1` | Valida se o harness do projeto está completo e sem problemas |
| `sync-tools.ps1` | Propaga skill ou agent editado para todas as ferramentas do projeto |
| `new-steering.ps1` | Wizard interativo para criar novo steering |
| `new-hook.ps1` | Wizard para criar novo hook |
| `new-skill.ps1` | Cria skill em todas as ferramentas detectadas |
| `new-agent.ps1` | Cria agent para Claude, Copilot e Amazon Q |

### Atualizar harness de projeto existente

Quando os templates do agentfiles são atualizados, use o `update-harness.ps1` para propagar as mudanças:

```powershell
# Ver o que mudou sem aplicar
.\scripts\update-harness.ps1 -ProjectPath "C:\Dev\MeuProjeto" -WhatIf

# Aplicar atualizações
.\scripts\update-harness.ps1 -ProjectPath "C:\Dev\MeuProjeto"
```

O script compara hash dos templates com os arquivos do projeto e atualiza apenas o que mudou.
Nunca toca em arquivos específicos do projeto (`harness-config.json`, `mcp.json`, `project-standards.md`, etc.).
Arquivos novos nos templates aparecem como **AUSENTES** — adicioná-los manualmente ou via bootstrap.

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
