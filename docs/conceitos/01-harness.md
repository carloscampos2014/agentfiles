# O que é o Harness

## Definição

O harness é uma **camada de governança e automação** que envolve seu projeto e ensina os agentes AI
a trabalharem do seu jeito — com seus padrões, seus fluxos e seu contexto.

Sem harness, cada sessão começa do zero. O agente não sabe que você usa Clean Architecture,
que commits devem seguir Conventional Commits, que testes são obrigatórios antes de qualquer PR.
Você repete as mesmas instruções toda vez.

Com harness, essas regras ficam em arquivos. O agente as lê no início de cada sessão e as
segue consistentemente — em qualquer projeto, com qualquer desenvolvedor do time.

---

## Analogia

Pense no harness como o **onboarding automatizado do agente**. É o equivalente de dar ao agente
o mesmo documento que você daria para um desenvolvedor novo no time:

- "Usamos Clean Architecture neste projeto"
- "Commits seguem Conventional Commits"
- "Toda feature começa com um briefing aprovado"
- "Nunca push direto para main"

A diferença é que o agente lê e segue isso em **toda sessão**, sem precisar ser lembrado.

---

## O que compõe o harness

```
harness
├── Steerings     → "como se comportar" — regras e instruções permanentes
├── Hooks         → "o que fazer quando X acontece" — automações por evento
├── Skills        → "como executar tarefa Y" — procedimentos especializados
├── Agents        → "quem faz o quê" — personas especializadas
├── MCP           → "ferramentas externas" — GitHub, banco, filesystem, etc.
└── Specs         → "o que construir" — requirements + design + tasks
```

Cada componente tem uma responsabilidade clara. Eles não se sobrepõem.

---

## Onde os arquivos ficam

O harness usa as pastas de configuração que cada ferramenta AI lê automaticamente:

| Ferramenta | Pasta principal | Arquivo raiz |
|------------|----------------|--------------|
| Kiro | `.kiro/` | — |
| Claude Code | `.claude/` | `CLAUDE.md` |
| GitHub Copilot | `.github/` | `copilot-instructions.md` |
| Amazon Q | `.amazonq/` | — |
| OpenAI Codex | — | `AGENTS.md` |
| Gemini CLI | — | `GEMINI.md` |
| Qwen Code | — | `QWEN.md` |
| TRAE | `.trae/` | — |

---

## Dois níveis: global e projeto

### Global (`~/.kiro/steering/`, `~/.claude/`, `~/.codex/`)
Aplica a **todos** os seus projetos. Bom para padrões pessoais que você quer em toda sessão:
- Idioma de resposta
- Proibições universais (nunca push --force)
- Ferramentas que você sempre usa

### Projeto (`.kiro/`, `.claude/`, etc.)
Aplica **apenas ao projeto atual**. Commitado no repositório — compartilhado com o time:
- Stack do projeto
- Estrutura de pastas
- Regras de negócio específicas
- Comandos de build e teste

---

## O harness não é um programa

Os arquivos do harness não são executados diretamente. Eles são **lidos e interpretados** pelo
agente AI durante as conversas. Pense neles como documentação que o agente segue, não código
que roda.

A única exceção são os hooks do tipo `command` — esses sim executam comandos shell em resposta
a eventos do IDE.

---

## Fluxo típico de uma sessão com harness

```
1. Dev abre o projeto no IDE
2. Agente carrega os arquivos de configuração (steerings, rules, hooks)
3. Dev digita: "implementar o módulo de pagamentos"
4. Agente classifica o pedido (agent-router)
5. Agente faz briefing e aguarda aprovação (workflow-aprovacao)
6. Dev aprova
7. Agente implementa seguindo os padrões do projeto (engineering-standards)
8. Hook dispara ao salvar arquivo (build-on-cs-save)
9. Agente verifica build e testes
10. Agente faz commit seguindo Conventional Commits (git-commits)
11. Ao encerrar, hook salva resumo da sessão (session-summary)
```

O dev foca nas decisões. O harness garante que o processo é seguido.
