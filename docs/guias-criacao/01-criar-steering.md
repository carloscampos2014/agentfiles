# Guia: Criar um Steering

## Quando criar um novo steering

- Você se repetiu a mesma instrução ao agente 3+ vezes em sessões diferentes
- Existe um padrão do projeto que o agente esquece entre sessões
- Você quer uma regra de segurança que nunca pode ser ignorada
- Há um workflow específico que o time inteiro deve seguir

Se a instrução é para uma tarefa pontual → use uma **skill**, não um steering.

---

## Método rápido — usar o wizard

```powershell
C:\Dev\agentfiles\scripts\new-steering.ps1 -ProjectPath "C:\Dev\MeuProjeto"
```

O wizard pergunta o nome, modo de inclusão e conteúdo inicial, e cria o arquivo no lugar certo.

---

## Método manual — passo a passo

### Passo 1 — Definir o escopo

Responda antes de escrever:
- **Qual é a única coisa que este steering ensina?** (Se a resposta tem "e", divida em dois)
- **Quando deve estar ativo?** `always`, `auto`, `fileMatch` ou `manual`
- **Quem se beneficia?** Apenas você, o time todo, ou apenas ao editar certos arquivos?

### Passo 2 — Escolher o modo de inclusão

| Conteúdo do steering | Modo recomendado |
|---------------------|-----------------|
| Proibições absolutas, regras de segurança | `always` |
| Padrões de código, workflow de git | `auto` |
| Convenções de uma linguagem específica | `fileMatch` |
| Workflow opcional, ativado pelo dev | `manual` |

Use `always` com moderação — cada steering `always` aumenta o contexto de toda sessão.

### Passo 3 — Criar o arquivo

```
.kiro/steering/nome-descritivo.md
```

Nomenclatura:
- Kebab-case: `engineering-standards.md`, não `EngineeringStandards.md`
- Nome descreve o conteúdo: `git-commits.md`, não `regras.md`
- Prefixo opcional para agrupar: `csharp-patterns.md`, `react-patterns.md`

### Passo 4 — Escrever o conteúdo

```markdown
---
inclusion: auto
description: "O que este steering faz — uma frase que o agente usa para decidir quando carregar"
---

# Título Descritivo

## Seção 1 — [tópico]

[conteúdo]

## Seção 2 — [tópico]

[conteúdo]
```

### Passo 5 — Testar

Abra uma sessão no Kiro e pergunte algo relacionado ao tema do steering.
Verifique se o agente está seguindo as regras novas.

Para `manual`: teste digitando `#nome-do-steering` no chat e verificando se o contexto é carregado.

---

## Template mínimo

```markdown
---
inclusion: auto
description: "Padrões de [tópico] para [contexto]"
---

# Padrões de [Tópico]

## Regras

- [regra 1 — acionável e específica]
- [regra 2]
- [regra 3]

## ✅ Correto

[exemplo de código ou comportamento correto]

## ❌ Errado

[exemplo do que não fazer]
```

---

## Equivalentes em outras ferramentas

Se quiser que o steering também valha para outras ferramentas, crie equivalentes:

| Ferramenta | Onde adicionar |
|------------|---------------|
| Claude Code | `.claude/rules/<nome>.md` (sem frontmatter `inclusion`) |
| GitHub Copilot | Seção no `.github/copilot-instructions.md` |
| Amazon Q | `.amazonq/rules/<nome>.md` (com frontmatter `name/tools/model`) |
| TRAE | `.trae/rules/<nome>.md` |
| Codex | Seção no `AGENTS.md` |
| Gemini | Seção no `GEMINI.md` |

Ou use o script `sync-tools.ps1` para propagar automaticamente.

---

## Checklist antes de commitar

- [ ] Nome do arquivo é descritivo e em kebab-case
- [ ] Frontmatter tem `inclusion` e `description`
- [ ] Conteúdo tem regras acionáveis (não vagas)
- [ ] Tem exemplos de ✅ correto e ❌ errado quando necessário
- [ ] Modo `always` é realmente necessário (ou pode ser `auto`?)
- [ ] Steering cobre um único tópico
