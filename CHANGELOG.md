# Changelog

Todas as mudanças notáveis do projeto são documentadas aqui.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
versionamento segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

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
