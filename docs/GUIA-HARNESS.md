# Guia Técnico — agentfiles

> Referência técnica completa de todos os componentes, decisões e como estender o harness.
> Para uso rápido, veja `README.md`.

---

## O que é o harness?

O harness é uma **camada de governança e automação** que vive dentro das pastas de configuração
de cada ferramenta AI (`.kiro/`, `.claude/`, `.github/`, `.amazonq/`, `.trae/`, além de arquivos
raiz como `AGENTS.md`, `GEMINI.md`, `QWEN.md`, `.mcp.json`).

Ele é composto por arquivos `.md`, `.json` e `.toml` que cada agente lê e segue durante as
sessões de trabalho. O harness **não é executável** — são instruções e configurações interpretadas
pelos agentes em tempo de interação.

---

## Inventário completo (70 arquivos de template)

```
agentfiles/
├── README.md
├── GUIA-HARNESS.md
├── scripts/
│   └── bootstrap.ps1
└── templates/
    ├── .mcp.json                    ← MCP raiz para Claude Code
    │
    ├── .kiro/                       ── KIRO IDE ──────────────────────────────
    │   ├── harness-config.json
    │   ├── settings/mcp.json
    │   ├── steering/
    │   │   ├── harness-output-formatter.md   (always)
    │   │   ├── harness-anti-patterns.md      (always)
    │   │   ├── harness-agent-router.md       (always)
    │   │   ├── harness-one-question.md       (always)
    │   │   ├── harness-verification-report.md (auto)
    │   │   ├── method-development.md         (manual)
    │   │   └── git-commits.md                (auto)
    │   ├── hooks/
    │   │   ├── guardrails-pre-write.json     PreToolUse
    │   │   ├── build-test-on-stop.json       Stop
    │   │   ├── pre-task-spec-check.json      PreTaskExec
    │   │   ├── validate-task-completion.json PostTaskExec
    │   │   ├── session-summary.json          Stop
    │   │   └── missing-test-alert.json       PostFileCreate
    │   ├── knowledge/INDEX.md
    │   └── quality/
    │       ├── history.json
    │       └── tech-debt.json
    │
    ├── .claude/                     ── CLAUDE CODE ───────────────────────────
    │   ├── CLAUDE.md
    │   ├── settings.json            ← hooks + permissões allow/deny
    │   ├── settings.local.json      ← overrides pessoais (gitignored)
    │   ├── agents/                  ← @nome no chat
    │   │   ├── senior-developer.md  model: sonnet
    │   │   ├── solutions-architect.md
    │   │   ├── qa-engineer.md
    │   │   └── business-analyst.md
    │   ├── rules/                   ← carregadas automaticamente
    │   │   ├── engineering-standards.md
    │   │   ├── workflow.md
    │   │   ├── senior-developer.md
    │   │   ├── solutions-architect.md
    │   │   ├── 01-result-pattern.md
    │   │   ├── 02-logging-observability.md
    │   │   ├── 03-testing-requirements.md
    │   │   └── 04-database-best-practices.md
    │   ├── skills/                  ← /nome no chat
    │   │   ├── code-review/SKILL.md
    │   │   ├── spec-driven-development/SKILL.md
    │   │   ├── systematic-debugging/SKILL.md
    │   │   └── architecture-design/SKILL.md
    │   └── commands/
    │       └── generate-docs.md
    │
    ├── .github/                     ── GITHUB COPILOT ────────────────────────
    │   ├── copilot-instructions.md
    │   ├── agents/
    │   │   ├── senior-developer.md  (sem campo model — diferença do Amazon Q)
    │   │   ├── solutions-architect.md
    │   │   ├── qa-engineer.md
    │   │   └── business-analyst.md
    │   ├── skills/
    │   │   ├── code-review.md
    │   │   ├── spec-driven-development.md
    │   │   ├── systematic-debugging.md
    │   │   ├── architecture-design.md
    │   │   └── README.md
    │   └── commands/
    │       └── generate-docs.md
    │
    ├── .amazonq/                    ── AMAZON Q ──────────────────────────────
    │   ├── rules/                   ← frontmatter: name + description + tools + model
    │   │   ├── senior-developer.md
    │   │   ├── solutions-architect.md
    │   │   ├── qa-engineer.md
    │   │   └── business-analyst.md
    │   └── skills/                  ← mesmo conteúdo do .github/skills/
    │       ├── code-review.md
    │       ├── spec-driven-development.md
    │       ├── systematic-debugging.md
    │       ├── architecture-design.md
    │       └── README.md
    │
    ├── codex/                       ── OPENAI CODEX ──────────────────────────
    │   ├── AGENTS.md
    │   └── .codex/
    │       └── config.toml          ← MCPs: github, filesystem, fetch, memory
    │
    ├── gemini/                      ── GEMINI CLI ────────────────────────────
    │   └── GEMINI.md
    │
    ├── qwen/                        ── QWEN CODE ─────────────────────────────
    │   └── QWEN.md
    │
    └── .trae/                       ── TRAE IDE ──────────────────────────────
        ├── rules/
        │   ├── 01-engineering-standards.md
        │   ├── 02-git-workflow.md
        │   ├── 03-architecture.md
        │   └── 04-testing-requirements.md
        └── skills/
            ├── code-review.md
            ├── systematic-debugging.md
            └── spec-driven-development.md
```

---

## Matriz de capacidades por ferramenta

| Capacidade | Kiro | Claude | Copilot | Amazon Q | Codex | Gemini | Qwen | TRAE |
|------------|------|--------|---------|----------|-------|--------|------|------|
| Arquivo principal | steerings | CLAUDE.md | copilot-instructions.md | rules/ | AGENTS.md | GEMINI.md | QWEN.md | rules/ |
| MCP por projeto | ✅ mcp.json | ✅ .mcp.json | ❌ | ❌ | ✅ config.toml | via extensão | via extensão | ❌ |
| Agents/Subagents | via spec | ✅ agents/ | ✅ agents/ | ✅ rules/ | ❌ | via extensão | via extensão | via UI |
| Skills | ✅ skills/ | ✅ skills/SKILL.md | ✅ skills/ | ✅ skills/ | ❌ | via extensão | via extensão | ✅ skills/ |
| Hooks/Automações | ✅ hooks/ | ✅ settings.json | ❌ | ❌ | ❌ | via extensão | ❌ | ❌ |
| Commands | steerings manual | ✅ commands/ | ✅ commands/ | ❌ | ❌ | via extensão | via extensão | ❌ |
| Hierarquia global/projeto | ✅ ~/.kiro | ✅ ~/.claude | ❌ | ❌ | ✅ ~/.codex | ✅ ~/.gemini | ✅ ~/.qwen | ❌ |

---

## 1. Kiro IDE — componentes em detalhe

### harness-config.json

Controla quais componentes do harness estão ativos.

| Componente | Função |
|------------|--------|
| `templates` | Templates estruturados para features/bugs |
| `knowledge_capture` | Captura automática de padrões |
| `review_validation` | Validação em code reviews |
| `pre_requirements` | Avalia completude antes de specs |
| `quality_reporting` | Quality Score após tasks |
| `retrospective` | Planejado vs. real ao concluir spec |
| `onboarding` | Adapta nível de detalhe por dev |
| `tech_debt_detector` | Detecta dívida técnica |
| `agent_router` | Classifica pedidos, contexto mínimo |
| `git_guardrails` | Bloqueia comandos git destrutivos |

Para desativar: `"quality_reporting": false`

### Steerings — modos de inclusão

| Modo | Comportamento |
|------|--------------|
| `always` | Toda interação — usar para regras críticas |
| `auto` | Kiro detecta relevância pelo contexto |
| `fileMatch` + `fileMatchPattern` | Ao editar arquivo com pattern |
| `manual` | Dev digita `#nome` no chat |

### Steerings globais (`~/.kiro/steering/`)

Instalados pelo harness e disponíveis em **todos** os projetos:

| Arquivo | Inclusion | O que faz |
|---------|-----------|-----------|
| `engineering-standards.md` | `auto` | SOLID, Clean Code, segurança, testes |
| `workflow-aprovacao.md` | `auto` | Briefing + aguardar aprovação |
| `workflow-desenvolvimento.md` | `auto` | Ciclo completo de branch → PR |
| `graphify.md` | `auto` | Consultar knowledge graph quando existe |
| `continuar-de-onde-paramos.md` | `manual` | Retomar trabalho — fetch + issues |

### Hooks — eventos disponíveis

| Evento | Quando dispara |
|--------|---------------|
| `PostFileSave` | Ao salvar arquivo |
| `PostFileCreate` | Ao criar arquivo novo |
| `PreToolUse` | Antes de executar ferramenta — pode bloquear (exit 2) |
| `PostToolUse` | Após executar ferramenta |
| `Stop` | Quando o agente encerra |
| `PreTaskExec` | Antes de iniciar task de spec |
| `PostTaskExec` | Após concluir task de spec |
| `UserPromptSubmit` | Ao enviar mensagem no chat |

### Hook de stack específica — exemplo .NET

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

### Knowledge Base — tipos de artefatos

| Prefixo | Tipo | Quando criar |
|---------|------|-------------|
| `PIT-*.md` | Armadilha | Problema que não deve se repetir |
| `WRK-*.md` | Workaround | Solução temporária ativa |
| `RN-*.md` | Regra de Negócio | Regra complexa documentada |
| `ADR-*.md` | Decisão Técnica | Architecture Decision Record |
| `PA-*.md` | Padrão Arquitetural | Padrão reutilizável do projeto |
| `CC-*.md` | Convenção de Código | Convenção específica do projeto |

Capturar quando: mesmo problema 3+ vezes, decisão de design tomada, armadilha custosa.

### MCP — servidores incluídos (`.kiro/settings/mcp.json`)

| MCP | O que fornece |
|-----|--------------|
| `microsoft-learn` | Docs oficiais Microsoft (REST) |
| `filesystem` | Acesso ao sistema de arquivos |
| `github` | GitHub API — issues, PRs, projetos |
| `git` | Operações git programáticas |
| `fetch` | Busca de URLs externas |
| `memory` | Memória persistente entre sessões |
| `sequential-thinking` | Raciocínio estruturado em etapas |
| `time` | Data e hora atual |
| `figma` | Leitura de designs Figma (requer `FIGMA_API_KEY`) |

Adicionar postgres automaticamente passando `-DbConnectionString` no bootstrap.

---

## 2. Claude Code — componentes em detalhe

### Estrutura de arquivos

| Arquivo | Propósito |
|---------|-----------|
| `CLAUDE.md` | Índice — minimalista, aponta para rules e agents |
| `settings.json` | Hooks por evento + permissões allow/deny |
| `settings.local.json` | Overrides pessoais — gitignored |
| `agents/*.md` | Subagentes com `name`, `description`, `tools`, `model: sonnet` |
| `rules/*.md` | Carregadas automaticamente — sem frontmatter obrigatório |
| `skills/<nome>/SKILL.md` | Skills ativadas com `/nome` no chat |
| `commands/*.md` | Slash commands reutilizáveis |
| `.mcp.json` (raiz do projeto) | MCP scoped para o projeto |

### Diferença entre rules e agents

| Aspecto | Rules | Agents |
|---------|-------|--------|
| Ativação | Automática — toda sessão | Explícita — `@nome` no chat |
| Escopo | Padrões gerais | Persona especializada |
| Frontmatter | Opcional (`description:`) | Obrigatório (`name`, `tools`, `model`) |
| Conteúdo | Regras e padrões | Processo completo com exemplos de código |

### Hooks no settings.json

```json
"hooks": {
  "PostToolUse": [{ "matcher": "Write|Edit", "hooks": [...] }],
  "PreToolUse":  [{ "matcher": "Bash",       "hooks": [...] }]
}
```

### `.mcp.json` na raiz do projeto

Diferente do `~/.claude/settings.json` (global), o `.mcp.json` é **scoped para o projeto**,
commitado no repositório e compartilhado com o time.

---

## 3. GitHub Copilot — componentes em detalhe

### copilot-instructions.md

Arquivo único de instruções — sem frontmatter. Estrutura:
1. Cabeçalho (projeto + stack)
2. Regras de Ouro numeradas
3. Anti-patterns proibidos
4. Padrões de nomenclatura e código
5. Comandos simulados (/slash)

### agents/

Mesmo formato que Amazon Q, **sem** o campo `model` no frontmatter.

```yaml
---
name: senior-developer
description: "..."
tools: Read, Write, Edit, Bash, Grep, Glob, WebSearch
---
```

### skills/

Arquivos `.md` soltos (diferente do Claude Code que usa pastas com `SKILL.md`).

---

## 4. Amazon Q — componentes em detalhe

### Frontmatter obrigatório nas rules

```yaml
---
name: nome-kebab-case
description: "Descrição em 1 frase"
tools: Read, Write, Edit, Bash, Grep, Glob, WebSearch
model: claude-sonnet-4-5-20250929
---
```

O campo `model` é **exclusivo do Amazon Q** — GitHub Copilot e Claude Code não o usam.

---

## 5. OpenAI Codex — componentes em detalhe

### AGENTS.md — hierarquia de descoberta

```
~/.codex/AGENTS.md          ← global (todas as sessões)
    ↓ (herda e pode sobrescrever)
AGENTS.md                   ← raiz do projeto
    ↓ (herda e pode sobrescrever)
subdir/AGENTS.md            ← instrução específica de subcomponente
```

Instruções mais próximas do diretório atual têm precedência.

### .codex/config.toml — MCP de projeto

```toml
[mcp_servers.github]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]
env_vars = ["GITHUB_PERSONAL_ACCESS_TOKEN"]
```

Diferente do Kiro (JSON), o Codex usa TOML para configuração de MCP.

---

## 6. Gemini CLI e Qwen Code — limitações de projeto

Ambos suportam agents, skills, hooks e MCP, mas **apenas dentro de extensões**
(pacotes instalados separadamente via `gemini extensions install` ou `qwen extensions install`).

O que funciona como arquivo de projeto:
- `GEMINI.md` / `QWEN.md` — instrução principal com hierarquia global → projeto → subdir
- `@./caminho.md` (Gemini) — importar outros arquivos de contexto

O que requer extensão separada: agents, skills, hooks, MCP, commands.

---

## 7. TRAE IDE — componentes em detalhe

### Rules (`.trae/rules/`)

Guardrails permanentes — sempre ativos, aplicados a todos os agents.

| Arquivo | O que define |
|---------|-------------|
| `01-engineering-standards.md` | SOLID, Clean Code, Result Pattern, segurança |
| `02-git-workflow.md` | Branches, commits, PRs, proibições git |
| `03-architecture.md` | Clean Architecture, dependency rule, nomenclatura |
| `04-testing-requirements.md` | Cobertura mínima, AAA, cenários obrigatórios |

### Skills (`.trae/skills/`)

Procedimentos ativados sob demanda — carregados pelo agent quando a tarefa é relevante.

| Arquivo | Quando carregar |
|---------|----------------|
| `code-review.md` | Revisão de código, análise de PR |
| `systematic-debugging.md` | Investigação de bugs |
| `spec-driven-development.md` | Feature nova, planejamento |

Agents são configurados pela UI do TRAE — não há arquivo de projeto para eles.

---

## 8. Placeholders — substituídos pelo bootstrap

| Placeholder | Substituído por |
|-------------|----------------|
| `__PROJECT_NAME__` | Nome do projeto |
| `__PROJECT_DIR__` | Caminho absoluto do projeto |
| `__PROJECT_DIRNAME__` | Nome da pasta (último segmento do path) |
| `__PROJECT_DESCRIPTION__` | Descrição do projeto |
| `__STACK_DESCRIPTION__` | Stack tecnológica |
| `__GITHUB_OWNER__` | Owner do repositório GitHub |
| `__GITHUB_REPO__` | Nome do repositório GitHub |
| `__BUILD_COMMAND__` | Comando de build |
| `__TEST_COMMAND__` | Comando de testes |
| `__LINT_COMMAND__` | Comando de lint |

---

## 9. Como estender o harness

### Adicionar novo steering (Kiro)

1. Criar `templates/.kiro/steering/<nome>.md` com frontmatter `inclusion:`
2. Se universal: adicionar na lista `$steeringsUniversais` do `bootstrap.ps1`
3. Se opcional de stack: documentar no README como steering a adicionar manualmente

### Adicionar novo hook (Kiro)

1. Criar `templates/.kiro/hooks/<nome>.json` seguindo o schema de hooks do Kiro
2. Se universal: adicionar na lista `$hooksUniversais` do `bootstrap.ps1`

### Adicionar nova rule (Claude Code)

1. Criar `templates/.claude/rules/<nome>.md`
2. Adicionar na lista de rules do bloco Claude no `bootstrap.ps1`
3. Referenciar na tabela do `CLAUDE.md` template

### Adicionar novo agent (Claude / Copilot / Amazon Q)

1. Criar o arquivo em `templates/.claude/agents/`, `templates/.github/agents/` e `templates/.amazonq/rules/`
2. Claude e Copilot: frontmatter com `name`, `description`, `tools` (Claude adiciona `model: sonnet`)
3. Amazon Q: frontmatter com `name`, `description`, `tools`, `model: claude-sonnet-4-5-20250929`
4. Adicionar nas listas de agents nos três blocos do `bootstrap.ps1`

### Adicionar nova skill

1. Criar em `templates/.github/skills/<nome>.md` (conteúdo base)
2. Criar em `templates/.claude/skills/<nome>/SKILL.md` (frontmatter com `name` e `description`)
3. Copiar para `templates/.amazonq/skills/<nome>.md`
4. Criar em `templates/.trae/skills/<nome>.md` (versão condensada sem frontmatter)
5. Adicionar nas listas de skills nos quatro blocos do `bootstrap.ps1`

### Adicionar nova ferramenta

1. Criar pasta em `templates/<ferramenta>/`
2. Criar os arquivos conforme a estrutura documentada da ferramenta
3. Adicionar `-Switch` novo nos parâmetros do `bootstrap.ps1`
4. Adicionar bloco de cópia no `bootstrap.ps1`
5. Atualizar `README.md` e `GUIA-HARNESS.md`
