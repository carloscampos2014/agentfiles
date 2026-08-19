# Guia: Criar uma Spec

## Quando criar

| Situação | Criar spec? |
|----------|-------------|
| Feature com 3+ arquivos | ✅ |
| Trabalho > 4 horas | ✅ |
| Mudança de contrato (API, banco) | ✅ |
| Qualquer mudança irreversível | ✅ |
| Bugfix simples | ❌ |
| Ajuste de config | ❌ |

---

## Criar com o agente (método recomendado)

No chat do Kiro ou Claude Code:

```
Quero criar uma spec para [feature]. 
Ajude a elicitar os requisitos.
```

O agente usa a skill `spec-driven-development` para guiar o processo.

---

## Criar manualmente

### Estrutura

```
.kiro/specs/nome-da-feature/
├── requirements.md
├── design.md
└── tasks.md
```

### requirements.md — O Quê

```markdown
# Requirements — [Feature]

## Contexto
[Por que existe. Qual problema resolve. Quem usa.]

## User Stories

### US-01: [Título]
**Como** [usuário] **Quero** [ação] **Para** [valor]

**Critérios de Aceite:**
- CA-01: Dado [contexto], quando [ação], então [resultado verificável]
- CA-02: [...]

**Fora do escopo:** [o que esta story não faz]

## Regras de Negócio
| ID | Regra |
|----|-------|
| RN-01 | [regra específica e objetiva] |

## NFRs
- Performance: [requisito mensurável]
- Segurança: [requisito específico]
```

### design.md — O Como

```markdown
# Design — [Feature]

## Componentes afetados
- [Componente] — [o que muda]

## Fluxo principal
[diagrama mermaid]

## Modelo de dados
[tabela ou mermaid erDiagram]

## Decisões técnicas
| Decisão | Alternativa descartada | Motivo |
|---------|----------------------|--------|
```

### tasks.md — O Quando

```markdown
# Tasks — [Feature]

- [ ] **Task 1.1** — [descrição]
  - Arquivos: [lista]
  - Critérios: CA-01, CA-02
  - Estimativa: P/M/G

- [ ] **Task 1.2** — [descrição]
  ...
```

---

## Processo de aprovação

```
1. Gerar requirements.md
2. Dev lê e aprova (ou pede ajuste)
3. Gerar design.md
4. Dev lê e aprova
5. Gerar tasks.md
6. Dev diz "pode implementar"
```

**Nunca pular a aprovação.** Uma spec não aprovada não é uma spec — é um rascunho.

---

## Critérios de aceite bem escritos

```
❌ "O sistema deve funcionar bem"
❌ "A interface deve ser rápida"
✅ "Dado pedido com 0 itens, quando criar, retornar erro 400 com mensagem 'mínimo 1 item'"
✅ "Listagem retorna em < 500ms para até 10.000 registros"
```
