# Skills

## O que são

Skills são **procedimentos especializados** que o agente executa quando a tarefa pede.
Diferente dos steerings (que definem comportamento geral), skills definem **como executar
uma tarefa específica** — passo a passo, com critérios claros e formato de saída definido.

A metáfora é um **SOP (Standard Operating Procedure)**: quando o agente precisa fazer um
code review, ele segue a skill `code-review`. Quando precisa debugar um bug, segue `systematic-debugging`.

---

## Onde ficam

### Kiro
```
.kiro/skills/
└── nome-da-skill/
    └── SKILL.md
```

### Claude Code
```
.claude/skills/
└── nome-da-skill/
    └── SKILL.md
```

### GitHub Copilot e Amazon Q
```
.github/skills/
└── nome-da-skill.md      ← arquivo único (sem pasta)

.amazonq/skills/
└── nome-da-skill.md
```

### TRAE
```
.trae/skills/
└── nome-da-skill.md      ← arquivo único
```

---

## Frontmatter da SKILL.md (Kiro e Claude)

```yaml
---
name: nome-da-skill
description: "Descrição em 1-2 frases. Inclua as keywords que ativam a skill."
---
```

A `description` é crucial — o agente usa ela para decidir quando ativar a skill.
Inclua as palavras que o dev provavelmente vai usar: "revisar código", "debugar bug", etc.

---

## Estrutura interna recomendada

```markdown
# Skill: Nome da Skill

## Quando usar
[Condições que ativam esta skill — exemplos de pedidos do usuário]

## Processo
[Etapas numeradas, claras e acionáveis]

## Formato de saída
[Como reportar o resultado]

## Critérios de qualidade
[Como saber que a skill foi executada bem]

## Proibições
[O que nunca fazer ao executar esta skill]
```

---

## Diferença entre skill e steering

| Aspecto | Steering | Skill |
|---------|----------|-------|
| Ativação | Permanente ou por evento | Sob demanda (quando relevante) |
| Conteúdo | "Como se comportar sempre" | "Como fazer X quando pedido" |
| Escopo | Amplo — vale para tudo | Focado — uma tarefa específica |
| Exemplo | "Nunca push para main" | "Como fazer code review em 3 etapas" |

---

## Ativação de skills

### Kiro e Claude Code
O agente detecta automaticamente quando uma skill é relevante pelo contexto da conversa.
O dev também pode invocar explicitamente com `/nome-da-skill`.

### GitHub Copilot
Skills aparecem como contexto adicional baseado em keywords.

### TRAE
Agents carregam skills sob demanda quando identificam a tarefa.

---

## Skills incluídas no harness

| Skill | O que faz |
|-------|-----------|
| `code-review` | Revisão estruturada com checklist por categoria e severidades |
| `spec-driven-development` | requirements → design → tasks → implementação |
| `systematic-debugging` | 6 etapas do diagnóstico à correção com Twin Check |
| `architecture-design` | Decisão arquitetural com alternativas, ADR e diagramas |

---

## Boas práticas

- **Uma skill = uma tarefa**. Não criar skill genérica de "desenvolvimento".
- **Formato de saída explícito**: o dev sabe o que esperar ao final.
- **Critérios mensuráveis**: "build passou" é melhor que "código de qualidade".
- **Skills curtas e densas**: 1-3KB é o tamanho ideal. Skills muito longas são ignoradas.
- **Keywords na description**: o agente usa isso para decidir quando ativar.
  "Use quando o usuário pede revisão, análise, code review, verificar código."
