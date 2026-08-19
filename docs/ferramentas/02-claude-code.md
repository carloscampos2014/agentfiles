# Guia de Uso — Claude Code

## O que o Claude Code oferece

Claude Code é o agente de terminal da Anthropic. Tem suporte completo a harness:
rules (equivalente a steerings), agents (subagentes), skills (com SKILL.md), hooks
no settings.json, commands (slash commands) e MCP via `.mcp.json`.

---

## Estrutura que o harness cria

```
.mcp.json               ← MCP de projeto (commitável, sem secrets)
.claude/
├── CLAUDE.md           ← índice do projeto (minimalista)
├── settings.json       ← hooks + permissões allow/deny
├── settings.local.json ← overrides pessoais (gitignored)
├── agents/             ← subagentes (@nome)
│   ├── senior-developer.md
│   ├── solutions-architect.md
│   ├── qa-engineer.md
│   └── business-analyst.md
├── rules/              ← carregadas automaticamente
│   ├── engineering-standards.md
│   ├── workflow.md
│   ├── senior-developer.md
│   ├── solutions-architect.md
│   ├── 01-result-pattern.md
│   ├── 02-logging-observability.md
│   ├── 03-testing-requirements.md
│   └── 04-database-best-practices.md
├── skills/             ← /nome no chat
│   ├── code-review/SKILL.md
│   ├── spec-driven-development/SKILL.md
│   ├── systematic-debugging/SKILL.md
│   └── architecture-design/SKILL.md
└── commands/
    └── generate-docs.md
```

---

## Primeiro uso após bootstrap

### 1. Personalizar CLAUDE.md

Editar com o nome e stack reais do projeto:

```markdown
# MeuProjeto

Sistema de gestão de X com .NET 10 e Blazor WASM.
Stack: .NET 10, C#, PostgreSQL, Dapper, Blazor.

Consulte `.claude/rules/` para padrões e `.claude/agents/` para especialistas.
```

### 2. Ajustar settings.local.json

Adicionar comandos específicos do projeto na lista `allow`:

```json
{
  "permissions": {
    "allow": [
      "Bash(dotnet build MeuProjeto.sln*)",
      "Bash(dotnet test tests/*)",
      "Bash(dotnet ef*)"
    ]
  }
}
```

### 3. Configurar MCP

Editar `.mcp.json` e substituir `__PROJECT_DIR__` pelo caminho real:

```json
"filesystem": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-filesystem", "C:\\Dev\\MeuProjeto"]
}
```

---

## Como usar agents

Invocar com `@nome-do-agent` no chat:

```
@solutions-architect Preciso decidir entre usar Dapper ou EF Core neste projeto.

@qa-engineer Revise a cobertura de testes do módulo de pedidos.

@business-analyst Ajude a escrever a spec para o módulo de relatórios.
```

O agente recebe o contexto atual e aplica a especialização.

---

## Como usar skills

Invocar com `/nome-da-skill` ou por contexto natural:

```
/code-review [arquivo ou trecho]

/debug Estou com um bug de concorrência no módulo de pedidos — às vezes duplica registros.

/spec Quero implementar o módulo de notificações por email.

/arch Devo usar CQRS ou arquitetura em camadas para este projeto?
```

---

## Hooks no settings.json

O harness já configura hooks básicos. Para adicionar um novo:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|Create",
        "hooks": [{
          "type": "command",
          "command": "echo 'Arquivo modificado — lembrar de rodar testes'"
        }]
      }
    ]
  }
}
```

---

## Hierarquia de configuração

```
~/.claude/settings.json     ← global (todos os projetos)
    ↓ sobrescreve
.claude/settings.json       ← projeto (commitado)
    ↓ sobrescreve
.claude/settings.local.json ← local (gitignored)
```

Use `settings.local.json` para configurações pessoais que não devem ir para o repo.

---

## Diferenças de formato entre rules e agents

| Aspecto | Rules | Agents |
|---------|-------|--------|
| Frontmatter | Opcional | Obrigatório (`name`, `tools`, `model`) |
| Ativação | Automática | Explícita (`@nome`) |
| `model` | N/A | `sonnet` |
| Conteúdo | Padrões gerais | Persona com processo e exemplos |

---

## Dicas de produtividade

- Manter `CLAUDE.md` curto — é lido em toda sessão; use para contexto essencial
- Rules são carregadas automaticamente — não precisa mencionar
- Agents são ótimos para delegação: "hei @solutions-architect, o que você acha desta decisão?"
- `/generate-docs` após implementar features — mantém docs atualizadas sem esforço manual
- Commitar `.mcp.json` — o time inteiro usa os mesmos servidores MCP
