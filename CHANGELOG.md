# Changelog

Todas as mudanças notáveis do projeto são documentadas aqui.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
versionamento segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

---

## [1.2.0] — 2026-11-09

### Adicionado

**Templates — Google Antigravity**
- Estrutura de templates completa em `templates/.agent/`
- 11 rules modulares em `.agent/rules/`: `briefing-detalhado.md`, `engineering-standards.md`, `harness-anti-patterns.md`, `workflow.md`, `01-result-pattern.md`, `02-logging-observability.md`, `03-testing-requirements.md`, `04-database-best-practices.md`, `senior-developer.md`, `solutions-architect.md` e `method-development.md`
- 6 skills completas com `SKILL.md` em `.agent/skills/`: `code-review`, `spec-driven-development`, `systematic-debugging`, `architecture-design`, `bootstrap-from-docs`, `bootstrap-from-code`
- Hook nativo `hooks.json` com `PreToolUse` e script `hooks/guardrails.js` para bloqueio de comandos perigosos
- Configuração de MCP nativo `mcp_config.json` com servidores filesystem, git, github, fetch, knowledge-rag, memory e sequential-thinking
- Estrutura de knowledge base (`knowledge/INDEX.md`) e controle de qualidade (`quality/history.json`, `quality/tech-debt.json`)

**Scripts**
- `bootstrap.ps1`: suporte ao switch `-Antigravity` e inclusão no `-All`
- `validate-harness.ps1`: validação de integridade para a estrutura `.agent/` e `mcp_config.json`
- `update-harness.ps1`: detecção e atualização de rules e hooks do Antigravity
- `sync-tools.ps1`: suporte a Antigravity como origem e destino de sincronização de skills e agents
- `new-skill.ps1` & `new-agent.ps1`: detecção e criação de skills e rules para Antigravity
- `scripts/unix/new-project.sh`: adição do Antigravity no wizard interativo

**Documentação**
- `docs/ferramentas/08-antigravity.md`: guia de uso completo do harness com o Google Antigravity
- Atualizados `README.md`, `docs/INDEX.md` e `docs/GUIA-HARNESS.md`

---

## [1.1.0] — 2026-08-19

### Adicionado

**Templates — Kiro IDE**
- `steering/briefing-detalhado.md` — formato visual obrigatório de briefing com tabela de escopo, blocos antes/depois, emojis de status
- `steering/harness-knowledge-rag.md` — instrui o agente quando e como usar `knowledge-rag` e `memory` MCP
- `hooks/session-summary.json` — atualizado para v2 com ADRs inline, steerings ativos, knowledge consultado e contexto crítico para retomada
- `hooks/harness-retrospective.json` — novo hook PostTaskExec: compara planejado vs real ao concluir última task do spec
- `skills/bootstrap-from-docs/SKILL.md` — lê documentos de ideia e gera comando bootstrap completo
- `skills/bootstrap-from-code/SKILL.md` — analisa código-fonte existente e gera comando bootstrap completo
- MCPs `knowledge-rag` (busca semântica local via uvx) e `memory` com path configurado em `mcp.json`

**Templates — Todas as ferramentas**
- `briefing-detalhado` adicionado como rule/instruction/steering em Claude, Copilot (instructions/), Amazon Q, TRAE
- `briefing-detalhado` adicionado via append em AGENTS.md, GEMINI.md, QWEN.md
- Skills `bootstrap-from-docs` e `bootstrap-from-code` adicionados em Claude, Copilot, Amazon Q, TRAE
- MCP `knowledge-rag` adicionado em `.mcp.json` (raiz do projeto)

**Scripts**
- `update-harness.ps1` — compara templates com projeto por hash SHA256, atualiza apenas o que mudou, nunca toca em arquivos do projeto, suporta `-WhatIf`
- `validate-harness.ps1` — corrigido: `@()` para `[regex]::Matches()` e `${path}` para evitar ParseException no PowerShell strict mode; `harness-retrospective` adicionado à lista de hooks obrigatórios

### Alterado

- `bootstrap.ps1` — adicionados `briefing-detalhado`, `harness-knowledge-rag`, `harness-retrospective` às listas de cópia; adicionados skills `bootstrap-from-docs` e `bootstrap-from-code` para todas as ferramentas

---

## [1.0.0] — 2026-08-18

### Adicionado

**Templates — Kiro IDE**
- 7 steerings universais: output-formatter, anti-patterns, agent-router, one-question, verification-report, method-development, git-commits
- 6 hooks universais: guardrails-pre-write, build-test-on-stop, pre-task-spec-check, validate-task-completion, session-summary, missing-test-alert
- harness-config.json com componentes e thresholds configuráveis
- mcp.json com 9 servidores: microsoft-learn, filesystem, github, git, fetch, memory, sequential-thinking, time, figma
- knowledge/INDEX.md e estrutura quality/ para base de conhecimento e métricas

**Templates — Claude Code**
- CLAUDE.md minimalista como índice
- 8 rules: engineering-standards, workflow, senior-developer, solutions-architect, 01-result-pattern, 02-logging-observability, 03-testing-requirements, 04-database-best-practices
- 4 agents: senior-developer, solutions-architect, qa-engineer, business-analyst
- 4 skills (pastas SKILL.md): code-review, spec-driven-development, systematic-debugging, architecture-design
- settings.json com hooks e permissões allow/deny
- .mcp.json de projeto

**Templates — GitHub Copilot**
- copilot-instructions.md com regras de ouro, anti-patterns, padrões e comandos simulados
- 4 agents, 4 skills, 1 command (generate-docs)

**Templates — Amazon Q**
- 4 rules com frontmatter completo (name, tools, model)
- 4 skills sincronizadas com .github/skills/

**Templates — OpenAI Codex**
- AGENTS.md com instrução principal e hierarquia por diretório
- .codex/config.toml com MCPs em formato TOML

**Templates — Gemini CLI e Qwen Code**
- GEMINI.md e QWEN.md com hierarquia global → projeto → subdir

**Templates — TRAE IDE**
- 4 rules: engineering-standards, git-workflow, architecture, testing-requirements
- 3 skills: code-review, systematic-debugging, spec-driven-development

**Scripts**
- bootstrap.ps1 — inicializa novo projeto (8 ferramentas, placeholders substituídos)
- new-steering.ps1 — wizard interativo com 5 tipos de template
- new-hook.ps1 — wizard com todos os eventos e tipos de ação
- new-skill.ps1 — cria skill em todas as ferramentas detectadas simultaneamente
- new-agent.ps1 — cria agent para Claude, Copilot e Amazon Q com frontmatter correto
- sync-tools.ps1 — propaga skill ou agent editado para todas as ferramentas
- validate-harness.ps1 — validação completa com erros e avisos

**Documentação**
- docs/INDEX.md — índice central com caminhos rápidos
- docs/GUIA-HARNESS.md — referência técnica completa
- 7 docs de conceitos: harness, steering, hooks, skills, agents, MCP, specs
- 6 guias de criação: steering, hook, skill, agent, MCP, spec
- 7 guias de ferramentas: Kiro, Claude, Copilot, Amazon Q, Codex, Gemini+Qwen, TRAE
- 4 docs de templates: kiro-steerings, kiro-hooks, claude-rules, agents-skills

**Steerings globais** (instalados em `~/.kiro/steering/`)
- engineering-standards, workflow-aprovacao, workflow-desenvolvimento, graphify, continuar-de-onde-paramos
