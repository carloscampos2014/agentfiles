# Specs

## O que são

Specs são **especificações formais de features** que o agente cria antes de implementar.
Uma spec tem três partes: o que construir (requirements), como construir (design) e as
tarefas em ordem (tasks).

Specs resolvem o maior problema do desenvolvimento com agentes: sem uma spec, o agente
implementa o que acha que você quis dizer. Com uma spec aprovada, ele implementa exatamente
o que foi acordado.

---

## Onde ficam (Kiro)

```
.kiro/specs/
└── nome-da-feature/
    ├── requirements.md
    ├── design.md
    └── tasks.md
```

---

## Quando criar uma spec

| Situação | Criar spec? |
|----------|-------------|
| Feature com 3+ classes/componentes | ✅ Sim |
| Trabalho estimado > 4 horas | ✅ Sim |
| Mudança de contrato de API ou banco | ✅ Sim |
| Qualquer mudança irreversível | ✅ Sim |
| Bugfix simples (1-2 arquivos) | ❌ Não |
| Ajuste de configuração | ❌ Não |
| Renaming ou refactoring localizado | ❌ Não |

**Regra de ouro**: se você não consegue descrever o escopo em 3 frases, precisa de spec.

---

## requirements.md

Define **o que** será construído — da perspectiva do usuário.

```markdown
# Requirements — [Nome da Feature]

## Contexto
[Por que esta feature existe. Qual problema resolve. Quem se beneficia.]

## User Stories

### US-01: [Título em formato "Como X quero Y para Z"]
**Como** [usuário]
**Quero** [ação ou funcionalidade]
**Para** [valor ou objetivo]

**Critérios de Aceite:**
- CA-01: [Dado/Quando/Então ou condição objetiva e verificável]
- CA-02: [...]

**Fora do escopo:** [o que esta story explicitamente NÃO faz]

## Regras de Negócio
| ID | Regra |
|----|-------|
| RN-01 | [regra objetiva, sem ambiguidade] |

## NFRs (Não Funcionais)
- Performance: [ex: listagem em < 500ms para 10k registros]
- Segurança: [ex: somente usuários autenticados com papel X]
```

---

## design.md

Define **como** será construído — perspectiva técnica.

```markdown
# Design — [Nome da Feature]

## Arquitetura

### Componentes afetados
- [Componente] — [o que muda ou é criado]

### Fluxo principal
[diagrama mermaid sequenceDiagram]

### Modelo de dados
[diagrama mermaid erDiagram ou tabela de colunas novas]

## Decisões de Design
| Decisão | Alternativa | Motivo da escolha |
|---------|------------|------------------|
| [decisão] | [alternativa descartada] | [razão] |

## Impacto em código existente
- [arquivo/módulo] — [o que muda e por que]
```

---

## tasks.md

Define **quando e como** implementar — granularidade de execução.

```markdown
# Tasks — [Nome da Feature]

## Fase 1 — Domínio

- [ ] **Task 1.1** — Criar entidade [Nome]
  - Arquivos: `Domain/Entities/[Nome].cs`
  - Critérios: [CA-01], [CA-02]
  - Estimativa: P (1-2h)

## Fase 2 — Application

- [ ] **Task 2.1** — Criar use case [Ação][Nome]
  - Arquivos: `Application/UseCases/[Nome]/`
  - Critérios: [CA-03]
  - Estimativa: M (2-4h)

## Estimativas
| Tamanho | Horas |
|---------|-------|
| P | 1-2h |
| M | 2-4h |
| G | 4-8h |
```

---

## Fluxo de desenvolvimento com spec

```
1. Dev pede ao agente para criar spec da feature X
2. Agente elicita requisitos (uma pergunta por vez)
3. Agente gera requirements.md
4. Dev revisa e aprova (ou pede ajustes)
5. Agente gera design.md
6. Dev revisa e aprova
7. Agente gera tasks.md
8. Dev aprova e diz "pode implementar"
9. Agente implementa task 1.1, faz commit, roda testes
10. Agente valida CA da task 1.1 antes de avançar
11. Repete para cada task
```

---

## Critérios de aceite bem escritos

```
❌ Ruim: "O sistema deve funcionar bem"
❌ Ruim: "A interface deve ser intuitiva"
❌ Ruim: "O código deve ser limpo"

✅ Bom: "Dado um pedido com 0 itens, quando criar, então retornar erro 'Pedido deve ter ao menos 1 item'"
✅ Bom: "A listagem de pedidos retorna em menos de 500ms para até 10.000 registros"
✅ Bom: "Usuário sem papel 'admin' recebe 403 ao acessar /admin/usuarios"
```

Critério de aceite = condição verificável = pode virar um teste automatizado.
