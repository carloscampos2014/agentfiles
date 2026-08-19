# Agents (Subagentes)

## O que são

Agents são **personas especializadas** com escopo, ferramentas e comportamento definidos.
Enquanto o agente principal é generalista, os subagentes são especialistas — um para
arquitetura, outro para QA, outro para análise de requisitos.

Quando você invoca um subagente, ele recebe o contexto da conversa atual, aplica sua
especialização, executa sua tarefa e retorna o resultado para o agente principal ou diretamente
para você.

---

## Onde ficam

| Ferramenta | Localização | Frontmatter |
|------------|-------------|-------------|
| Claude Code | `.claude/agents/*.md` | `name`, `description`, `tools`, `model: sonnet` |
| GitHub Copilot | `.github/agents/*.md` | `name`, `description`, `tools` |
| Amazon Q | `.amazonq/rules/*.md` | `name`, `description`, `tools`, `model: claude-sonnet-4-5-20250929` |
| Kiro | `.kiro/agents/*.md` | via configuração de spec |

---

## Frontmatter obrigatório

### Claude Code
```yaml
---
name: nome-kebab-case
description: "O que este agent faz e quando invocar — uma frase."
tools: Read, Write, Bash, Grep, Glob, WebSearch
model: sonnet
---
```

### Amazon Q
```yaml
---
name: nome-kebab-case
description: "O que este agent faz e quando invocar."
tools: Read, Write, Edit, Bash, Grep, Glob, WebSearch
model: claude-sonnet-4-5-20250929
---
```

### GitHub Copilot
```yaml
---
name: nome-kebab-case
description: "O que este agent faz e quando invocar."
tools: Read, Write, Edit, Bash, Grep, Glob, WebSearch
---
```

**Diferença chave**: Amazon Q e Claude Code têm o campo `model`. GitHub Copilot não.

---

## Como invocar

| Ferramenta | Como invocar |
|------------|-------------|
| Claude Code | `@nome-do-agent` no chat |
| Amazon Q | Selecionar na lista de agents |
| GitHub Copilot | `@nome-do-agent` |

---

## Estrutura interna recomendada

```markdown
---
name: senior-developer
description: "Desenvolvedor sênior — implementação, bugs, refactoring. Use para código."
tools: Read, Write, Bash, Grep, Glob
model: sonnet
---

Você é um [papel] especializado em [domínio].

## FILOSOFIA
[Princípios em lista ✅/❌]

## PROCESSO
[Etapas que este agent segue]

## PADRÕES
[Exemplos de código, tabelas de nomenclatura, etc.]

## CHECKLIST ANTES DE ENTREGAR
[Critérios de aceite do trabalho deste agent]

## FORMATO DE RESPOSTA
[Template de como reportar resultados]
```

---

## Diferença entre agent e skill

| Aspecto | Agent | Skill |
|---------|-------|-------|
| O que é | Persona especializada | Procedimento especializado |
| Quando usar | Para delegar um domínio completo | Para executar uma tarefa pontual |
| Exemplo | `@solutions-architect` — tudo de arquitetura | `/code-review` — revisar este código |
| Contexto | Isolado (tem seu próprio prompt) | No contexto da conversa atual |
| Ferramenta | Invocado explicitamente | Ativado por relevância ou `/nome` |

---

## Agents incluídos no harness

| Agent | Especialidade | Quando invocar |
|-------|--------------|----------------|
| `senior-developer` | Implementação, bugs, refactoring | Qualquer tarefa de código |
| `solutions-architect` | Arquitetura, ADRs, diagramas | Decisões técnicas, design de sistema |
| `qa-engineer` | Testes, cobertura, validação | Planos de teste, review de qualidade |
| `business-analyst` | Requisitos, user stories, priorização | Descoberta, refinamento de features |

---

## Ferramentas disponíveis

| Ferramenta | O que faz |
|------------|-----------|
| `Read` | Lê arquivos do projeto |
| `Write` | Cria/sobrescreve arquivos |
| `Edit` | Edita partes de arquivos |
| `Bash` | Executa comandos shell |
| `Grep` | Busca padrões em arquivos |
| `Glob` | Lista arquivos por padrão |
| `WebSearch` | Busca na internet |

---

## Boas práticas

- **Uma responsabilidade por agent**: um agent de "backend" que também faz UX e arquitetura
  é um generalista disfarçado — não aproveita a especialização.
- **Description como gatilho**: "Use para implementações de código, features, bugs e refactoring"
  é melhor que "Desenvolvedor sênior".
- **Menos ferramentas, mais foco**: não dar `Write` para um agent de code review — ele não
  deve modificar código, apenas analisar.
- **Conteúdo denso**: agents devem ter exemplos reais de código, tabelas e checklists.
  Um agent de 1KB não ensina nada ao agente que o invoca.
