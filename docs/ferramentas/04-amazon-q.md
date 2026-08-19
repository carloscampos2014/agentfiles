# Guia de Uso — Amazon Q

## O que o Amazon Q oferece

Amazon Q Developer usa `.amazonq/` para rules e skills. Não tem hooks nem MCP
por projeto, mas as rules têm frontmatter obrigatório com `model` — o que permite
especificar qual modelo usar para cada persona.

---

## Estrutura que o harness cria

```
.amazonq/
├── rules/              ← agents com frontmatter completo
│   ├── senior-developer.md
│   ├── solutions-architect.md
│   ├── qa-engineer.md
│   └── business-analyst.md
└── skills/             ← mesmo conteúdo do .github/skills/
    ├── code-review.md
    ├── spec-driven-development.md
    ├── systematic-debugging.md
    ├── architecture-design.md
    └── README.md
```

---

## Frontmatter obrigatório das rules

```yaml
---
name: nome-kebab-case
description: "O que faz e quando usar — palavras-chave inclusas."
tools: Read, Write, Edit, Bash, Grep, Glob, WebSearch
model: claude-sonnet-4-5-20250929
---
```

**Diferença chave**: o campo `model` é obrigatório e usa o nome completo do modelo.
GitHub Copilot não tem esse campo. Claude Code usa `model: sonnet` (alias curto).

---

## Primeiro uso após bootstrap

### 1. Verificar os nomes dos modelos disponíveis

O harness usa `claude-sonnet-4-5-20250929` por padrão. Para atualizar:

```yaml
model: claude-sonnet-4-5-20250929   ← padrão no harness
```

Verificar modelos disponíveis no console do Amazon Q Developer.

### 2. Adicionar rules de stack específica

Criar `.amazonq/rules/project-standards.md`:

```yaml
---
name: project-standards
description: "Padrões específicos deste projeto — stack, estrutura e regras de negócio."
tools: Read, Grep, Glob
model: claude-sonnet-4-5-20250929
---

# Padrões do Projeto

## Stack
[lista]

## Estrutura
[estrutura de pastas]
```

---

## Diferença entre rules e skills no Amazon Q

| Rules | Skills |
|-------|--------|
| Tem frontmatter obrigatório | Sem frontmatter (arquivo Markdown livre) |
| Define personas/agents | Define procedimentos |
| Ativado pela seleção do agent | Ativado por palavras-chave |

---

## Boas práticas

- **model atualizado** — verificar periodicamente se há versão mais recente disponível
- **tools mínimos** — não dar `Write` para agents de review
- **description com keywords** — o Amazon Q usa para selecionar automaticamente o agent certo
- Manter rules e skills sincronizados com `.github/` — use `sync-tools.ps1` para isso
