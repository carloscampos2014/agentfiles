# Steerings

## O que são

Steerings são **instruções permanentes** que o agente lê em toda sessão. Definem como ele deve
se comportar — padrões de código, fluxos de trabalho, regras de segurança, formato de respostas.

A metáfora é um **manual de procedimentos**: o agente segue essas regras em tudo que faz,
sem precisar ser lembrado a cada mensagem.

---

## Onde ficam (Kiro)

```
.kiro/steering/
└── nome-do-steering.md
```

Cada arquivo é um steering independente com um frontmatter que define quando é carregado.

---

## Frontmatter obrigatório

```markdown
---
inclusion: always | auto | fileMatch | manual
description: "O que este steering faz — uma frase"
---

# Conteúdo do steering...
```

### Modos de inclusão

| Modo | Comportamento | Quando usar |
|------|--------------|-------------|
| `always` | Carregado em **toda** interação | Regras críticas que nunca podem ser ignoradas |
| `auto` | Kiro decide por relevância de contexto | Regras que só importam em certos cenários |
| `fileMatch` | Ao editar arquivo que bate com `fileMatchPattern` | Padrões de linguagem/framework |
| `manual` | Dev digita `#nome-do-steering` no chat | Workflows opcionais, ativados sob demanda |

### Exemplo com fileMatch

```markdown
---
inclusion: fileMatch
fileMatchPattern: "**/*.cs"
description: "Padrões específicos para C# — aplicados ao editar arquivos .cs"
---
```

---

## Equivalentes em outras ferramentas

| Ferramenta | Equivalente ao steering |
|------------|------------------------|
| Claude Code | `rules/*.md` |
| GitHub Copilot | `copilot-instructions.md` (um arquivo único) |
| Amazon Q | `.amazonq/rules/*.md` |
| TRAE | `.trae/rules/*.md` |
| Codex | Seções dentro do `AGENTS.md` |
| Gemini / Qwen | Seções dentro do `GEMINI.md` / `QWEN.md` |

---

## Diferença entre steering e skill

| Steering | Skill |
|----------|-------|
| Sempre ativo (ou ativado por evento) | Ativado sob demanda |
| Define **como se comportar** | Define **como executar uma tarefa** |
| "Nunca fazer push direto para main" | "Como fazer um code review passo a passo" |
| Regras e restrições | Procedimentos e workflows |

---

## Boas práticas

- **Um steering = um tópico**. Não misturar git, arquitetura e testes no mesmo arquivo.
- **Nomes descritivos**: `engineering-standards.md`, não `regras.md`.
- **`always` com moderação**: cada steering `always` aumenta o contexto de toda sessão.
  Prefira `auto` quando possível.
- **Conteúdo acionável**: o agente deve conseguir seguir o steering sem interpretação.
  "Nunca usar magic numbers" é melhor que "Escreva código limpo".
- **Exemplos concretos**: mostre `✅ correto` e `❌ errado` quando a regra não é óbvia.

---

## Steerings globais vs. projeto

**Global** (`~/.kiro/steering/`): aplicam a todos os projetos. Use para padrões pessoais.

**Projeto** (`.kiro/steering/`): aplicam apenas ao projeto atual, commitados no repo.

Quando há conflito, o projeto tem precedência sobre o global.

---

## Exemplo de steering bem estruturado

```markdown
---
inclusion: auto
description: "Padrões de commits — Conventional Commits, granularidade e proibições"
---

# Padrão de Commits

## Formato obrigatório

tipo(escopo): #N descrição concisa em imperativo

## Tipos permitidos

| Tipo | Quando |
|------|--------|
| feat | Nova funcionalidade |
| fix  | Correção de bug |
| docs | Documentação apenas |

## Proibições

- Nunca git add . — staged apenas arquivos relevantes
- Nunca commitar com build quebrado
- Nunca --no-verify sem instrução explícita
```
