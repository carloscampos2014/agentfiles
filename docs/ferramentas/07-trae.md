# Guia de Uso — TRAE IDE

## O que o TRAE oferece

TRAE (ByteDance) é uma IDE baseada em VS Code com agentes AI integrados. Usa `.trae/rules/`
para guardrails permanentes e `.trae/skills/` para procedimentos ativáveis. Agents são
configurados pela UI, não por arquivos de projeto.

O sistema Rules + Skills do TRAE é o mais próximo da combinação steering + skill do Kiro,
com a diferença que não tem hooks nem MCP por projeto.

---

## Estrutura que o harness cria

```
.trae/
├── rules/                      ← guardrails permanentes (sempre ativos)
│   ├── 01-engineering-standards.md
│   ├── 02-git-workflow.md
│   ├── 03-architecture.md
│   └── 04-testing-requirements.md
└── skills/                     ← procedimentos ativáveis sob demanda
    ├── code-review.md
    ├── systematic-debugging.md
    └── spec-driven-development.md
```

---

## Rules — guardrails permanentes

As rules são aplicadas a todos os agents em todas as conversas. Pense nelas como
o `settings.json` de um linter — ativas o tempo todo.

### Adicionar rule de stack específica

Criar `.trae/rules/05-stack-patterns.md`:

```markdown
# Padrões de Stack — MeuProjeto

## Backend (.NET)
- Usar Dapper para queries, nunca EF Core
- Resultado de use cases: Result<T> — nunca void
- Migrations via DbUp (SQL versionado)
- Zero warnings no build

## Frontend (Blazor WASM)
- State via serviços injetados, não campos estáticos
- Chamar API via HttpClient injetado, nunca new HttpClient()
- Componentes sem lógica de negócio — delegar para serviços
```

---

## Skills — procedimentos ativáveis

Skills são carregadas pelo agent quando detecta que a tarefa é relevante.
O dev também pode pedir explicitamente: "use a skill de code-review neste arquivo".

### Adicionar skill customizada

Criar `.trae/skills/deploy-checklist.md`:

```markdown
# Skill: Deploy Checklist

## Quando usar
Antes de qualquer deploy para produção ou homologação.

## Processo

### 1. Verificação de código
- [ ] Build limpo sem warnings
- [ ] Todos os testes passando
- [ ] Nenhum TODO pendente relacionado ao que será deployado

### 2. Verificação de configuração
- [ ] Variáveis de ambiente de produção configuradas
- [ ] Connection strings apontando para o banco correto
- [ ] Logs configurados para produção (não debug)

### 3. Verificação de banco
- [ ] Migrations testadas em ambiente similar à produção
- [ ] Backup feito antes de rodar migrations em produção

## Formato de saída
✅/❌ para cada item da checklist
Resultado final: ✅ Pronto para deploy / ❌ [N] itens pendentes
```

---

## Agents no TRAE — via UI

Agents são criados e gerenciados pela interface do TRAE, não por arquivos. Para criar:

1. Abrir painel de Agents no TRAE
2. Clicar em "New Agent"
3. Definir:
   - Nome e descrição
   - Prompt do sistema (usar o conteúdo dos agents do `.github/agents/` como base)
   - Ferramentas disponíveis
   - Modelo

**Dica**: usar o conteúdo de `.github/agents/senior-developer.md` como base para o prompt
do agent de desenvolvedor no TRAE — o conteúdo é o mesmo, só o mecanismo é diferente.

---

## Modo SOLO

O TRAE tem um modo "SOLO" onde o agent trabalha de forma mais autônoma em tasks longas.
Para aproveitar melhor:

1. Criar spec da feature em `.kiro/specs/` (se o projeto também usa Kiro) ou em `docs/specs/`
2. Ativar a skill `spec-driven-development` antes de iniciar
3. O agent SOLO segue o processo de requirements → design → tasks automaticamente

---

## Boas práticas

- **Rules curtas e específicas**: cada rule deve cobrir um tópico, sem misturar
- **Skills com formato de saída claro**: o agent sabe como reportar o resultado
- **Sincronizar com .github/**: use `sync-tools.ps1` para manter skills consistentes entre TRAE e Copilot
- **Commitar .trae/**: rules e skills vão para o repo — beneficiam todo o time
