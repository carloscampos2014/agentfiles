# Documentação — agentfiles

Índice completo de toda a documentação do harness.
Para uso rápido, veja o [`README.md`](../README.md) na raiz.

---

## Referência técnica

| Documento | O que cobre |
|-----------|-------------|
| [`GUIA-HARNESS.md`](GUIA-HARNESS.md) | Inventário completo dos templates, matriz de capacidades, MCPs, hooks, steerings, como estender |
| [`../CHANGELOG.md`](../CHANGELOG.md) | Histórico de versões — o que mudou em cada release |

---

## Conceitos

Entenda o que é cada componente antes de usar ou criar.

| Documento | O que explica |
|-----------|--------------|
| [`conceitos/01-harness.md`](conceitos/01-harness.md) | O que é o harness, analogia, onde os arquivos ficam, global vs. projeto, fluxo típico de sessão |
| [`conceitos/02-steering.md`](conceitos/02-steering.md) | O que são steerings, frontmatter, modos de inclusão (always/auto/fileMatch/manual), diferença de skill |
| [`conceitos/03-hooks.md`](conceitos/03-hooks.md) | O que são hooks, eventos disponíveis, tipos de ação (command/agent), schema completo, matcher regex |
| [`conceitos/04-skills.md`](conceitos/04-skills.md) | O que são skills, onde ficam por ferramenta, frontmatter SKILL.md, diferença de steering, ativação |
| [`conceitos/05-agents.md`](conceitos/05-agents.md) | O que são agents/subagentes, frontmatter por ferramenta, como invocar, ferramentas disponíveis |
| [`conceitos/06-mcp.md`](conceitos/06-mcp.md) | O que é MCP, schema por ferramenta (JSON/TOML), servidores incluídos, variáveis de ambiente |
| [`conceitos/07-specs.md`](conceitos/07-specs.md) | O que são specs, quando criar, templates requirements/design/tasks, fluxo de aprovação |

---

## Guias de criação

Como criar cada artefato do zero — com templates prontos e checklists.

| Documento | O que ensina |
|-----------|-------------|
| [`guias-criacao/01-criar-steering.md`](guias-criacao/01-criar-steering.md) | Quando criar, escolher modo de inclusão, template mínimo, equivalentes em outras ferramentas |
| [`guias-criacao/02-criar-hook.md`](guias-criacao/02-criar-hook.md) | Evento certo para cada caso, tipo command vs agent, templates para build/lint/arquitetura/bloqueio |
| [`guias-criacao/03-criar-skill.md`](guias-criacao/03-criar-skill.md) | Template SKILL.md completo, criar para todas as ferramentas, checklist de qualidade |
| [`guias-criacao/04-criar-agent.md`](guias-criacao/04-criar-agent.md) | Frontmatter por ferramenta (Claude/Copilot/Amazon Q), exemplo DevSecOps completo, ferramentas mínimas |
| [`guias-criacao/05-criar-mcp.md`](guias-criacao/05-criar-mcp.md) | Servidores populares (Postgres, Jira, Slack, Playwright), servidor customizado Node.js, boas práticas |
| [`guias-criacao/06-criar-spec.md`](guias-criacao/06-criar-spec.md) | Templates requirements/design/tasks, critérios de aceite bem escritos, fluxo de aprovação |

---

## Guias de ferramentas

Como usar o harness em cada ferramenta — primeiro uso, configuração e dicas.

| Documento | Ferramenta |
|-----------|-----------|
| [`ferramentas/01-kiro.md`](ferramentas/01-kiro.md) | **Kiro IDE** — steerings, hooks, knowledge base, specs, MCP, fluxo de trabalho típico |
| [`ferramentas/02-claude-code.md`](ferramentas/02-claude-code.md) | **Claude Code** — rules, agents (@nome), skills (/nome), hooks no settings.json, .mcp.json |
| [`ferramentas/03-copilot.md`](ferramentas/03-copilot.md) | **GitHub Copilot** — copilot-instructions, agents, skills, commands |
| [`ferramentas/04-amazon-q.md`](ferramentas/04-amazon-q.md) | **Amazon Q** — rules com frontmatter model, skills, diferença do Copilot |
| [`ferramentas/05-codex.md`](ferramentas/05-codex.md) | **OpenAI Codex** — AGENTS.md, hierarquia por diretório, .codex/config.toml para MCP |
| [`ferramentas/06-gemini-qwen.md`](ferramentas/06-gemini-qwen.md) | **Gemini CLI e Qwen Code** — GEMINI.md/QWEN.md, hierarquia, @import, extensões |
| [`ferramentas/07-trae.md`](ferramentas/07-trae.md) | **TRAE IDE** — rules permanentes, skills ativáveis, agents via UI, modo SOLO |

---

## Documentação de templates

O que faz cada template incluído no harness e como customizar.

| Documento | Cobre |
|-----------|-------|
| [`templates/kiro-steerings.md`](templates/kiro-steerings.md) | harness-output-formatter, harness-anti-patterns, harness-agent-router, harness-one-question, harness-verification-report, method-development, git-commits |
| [`templates/kiro-hooks.md`](templates/kiro-hooks.md) | guardrails-pre-write, build-test-on-stop, pre-task-spec-check, validate-task-completion, session-summary, missing-test-alert |
| [`templates/claude-rules.md`](templates/claude-rules.md) | engineering-standards, workflow, senior-developer (rule), solutions-architect (rule), 01-result-pattern, 02-logging-observability, 03-testing-requirements, 04-database-best-practices |
| [`templates/agentes-skills.md`](templates/agentes-skills.md) | senior-developer, solutions-architect, qa-engineer, business-analyst (agents) + code-review, spec-driven-development, systematic-debugging, architecture-design (skills) |

---

## Scripts

| Script | OS | O que faz | Uso |
|--------|-----|-----------|-----|
| [`../scripts/bootstrap.ps1`](../scripts/bootstrap.ps1) | Win/Mac/Linux | Inicializa novo projeto com todas as ferramentas | `bootstrap.ps1 -ProjectPath ... -All` |
| [`../scripts/unix/bootstrap.sh`](../scripts/unix/bootstrap.sh) | Mac/Linux | Wrapper bash para bootstrap.ps1 | `./bootstrap.sh --ProjectPath ... --All` |
| [`../scripts/unix/new-project.sh`](../scripts/unix/new-project.sh) | Mac/Linux | Wizard interativo Unix para novo projeto | `./new-project.sh` |
| [`../scripts/install-deps.ps1`](../scripts/install-deps.ps1) | Windows | Instala Git, Node.js, Python, uv, gh CLI via winget | `./install-deps.ps1` |
| [`../scripts/unix/install-deps.sh`](../scripts/unix/install-deps.sh) | Mac/Linux | Instala todas as dependências via brew/apt/dnf/pacman | `./install-deps.sh` |
| [`../scripts/new-steering.ps1`](../scripts/new-steering.ps1) | Win/Mac/Linux | Wizard para criar steering com template por tipo | `new-steering.ps1 -ProjectPath ...` |
| [`../scripts/new-hook.ps1`](../scripts/new-hook.ps1) | Win/Mac/Linux | Wizard para criar hook com todos os eventos e tipos | `new-hook.ps1 -ProjectPath ...` |
| [`../scripts/new-skill.ps1`](../scripts/new-skill.ps1) | Win/Mac/Linux | Cria skill em todas as ferramentas detectadas | `new-skill.ps1 -ProjectPath ...` |
| [`../scripts/new-agent.ps1`](../scripts/new-agent.ps1) | Win/Mac/Linux | Cria agent para Claude, Copilot e Amazon Q | `new-agent.ps1 -ProjectPath ...` |
| [`../scripts/sync-tools.ps1`](../scripts/sync-tools.ps1) | Win/Mac/Linux | Propaga skill ou agent editado para todas as ferramentas | `sync-tools.ps1 -Type skill -Name code-review` |
| [`../scripts/validate-harness.ps1`](../scripts/validate-harness.ps1) | Win/Mac/Linux | Valida completude e integridade do harness de um projeto | `validate-harness.ps1 -ProjectPath ...` |

---

## Caminhos rápidos

**Estou começando** → leia [`conceitos/01-harness.md`](conceitos/01-harness.md) e depois execute o `bootstrap.ps1`

**Quero criar um steering** → [`guias-criacao/01-criar-steering.md`](guias-criacao/01-criar-steering.md) ou `new-steering.ps1`

**Quero criar um hook** → [`guias-criacao/02-criar-hook.md`](guias-criacao/02-criar-hook.md) ou `new-hook.ps1`

**Quero criar uma skill** → [`guias-criacao/03-criar-skill.md`](guias-criacao/03-criar-skill.md) ou `new-skill.ps1`

**Quero criar um agent** → [`guias-criacao/04-criar-agent.md`](guias-criacao/04-criar-agent.md) ou `new-agent.ps1`

**Quero adicionar um MCP** → [`guias-criacao/05-criar-mcp.md`](guias-criacao/05-criar-mcp.md)

**Não entendo o que é X** → pasta [`conceitos/`](conceitos/) tem explicação de cada componente

**Quero ver o que cada template faz** → pasta [`templates/`](templates/)

**Quero verificar se meu projeto está ok** → `validate-harness.ps1 -ProjectPath "C:\Dev\MeuProjeto"`
