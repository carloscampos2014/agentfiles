# Guia de Uso — GitHub Copilot

## O que o GitHub Copilot oferece

GitHub Copilot no contexto do harness usa a estrutura `.github/` para fornecer:
instruções globais de projeto (`copilot-instructions.md`), agents especializados,
skills ativáveis e commands (slash commands).

Diferente do Kiro e Claude Code, o Copilot **não tem hooks nem MCP por projeto**.
Seu ponto forte é a integração nativa com o GitHub e o VS Code.

---

## Estrutura que o harness cria

```
.github/
├── copilot-instructions.md  ← instruções globais do projeto
├── agents/                  ← especialistas
│   ├── senior-developer.md
│   ├── solutions-architect.md
│   ├── qa-engineer.md
│   └── business-analyst.md
├── skills/                  ← procedimentos ativáveis
│   ├── code-review.md
│   ├── spec-driven-development.md
│   ├── systematic-debugging.md
│   ├── architecture-design.md
│   └── README.md
└── commands/
    └── generate-docs.md
```

---

## Primeiro uso após bootstrap

### 1. Personalizar copilot-instructions.md

Editar o cabeçalho com dados reais do projeto:

```markdown
# MeuProjeto — Instruções para GitHub Copilot

Projeto: Sistema de gestão de X.
Stack: .NET 10, C#, PostgreSQL, Dapper, Blazor WASM.
```

### 2. Adicionar stack-specific rules

Na seção "Padrões de Código", adicionar padrões da stack:

```markdown
## Padrões específicos da stack

### C# — Dapper (sem EF Core)
- Queries sempre parametrizadas via objeto anônimo
- Soft delete com coluna `deleted_at` — nunca DELETE físico
- Mapeamento manual de entidades — sem AutoMapper

### Blazor WASM
- State management via cascading parameters ou serviços singleton
- HttpClient injetado via DI — nunca instanciar diretamente
```

---

## Como usar agents

No chat do Copilot (VS Code), mencionar o agent:

```
@senior-developer Implemente o endpoint POST /pedidos com validação FluentValidation.

@solutions-architect Preciso decidir a estrutura de pastas para este módulo.

@qa-engineer Quais testes devo escrever para este use case?
```

---

## Como usar skills

Invocar pelo comando ou por contexto:

```
/review — analisa o arquivo aberto
/debug — ajuda a diagnosticar um problema
/spec — cria spec para uma nova feature
/arch — auxilia em decisão arquitetural
```

---

## Diferença do copilot-instructions vs. agents

| Aspecto | copilot-instructions.md | agents/*.md |
|---------|------------------------|-------------|
| Escopo | Todo o workspace | Persona especializada |
| Ativação | Automático | `@nome` explícito |
| Conteúdo | Regras gerais do projeto | Expertise focada |
| Frontmatter | Não usa | `name`, `description`, `tools` |

Use `copilot-instructions.md` para o que vale sempre.
Use agents para especialistas que você chama pontualmente.

---

## Boas práticas

- **copilot-instructions.md deve ser conciso** — é lido em toda sugestão
- **Regras acionáveis** — "nunca usar AutoMapper" é melhor que "usar boas práticas"
- **Commands simulados** — os `/comandos` na seção de commands guiam o Copilot a executar
  workflows complexos de forma previsível
- **Commitar tudo** — `.github/` vai para o repo e beneficia todo o time
