# Guia de Uso — Kiro IDE

## O que o Kiro oferece

O Kiro é a ferramenta com maior suporte a harness de todas. Tem a estrutura mais completa:
steerings (com modos de inclusão), hooks por evento, skills, specs estruturadas, MCPs e
uma knowledge base persistente por projeto.

---

## Estrutura que o harness cria

```
.kiro/
├── harness-config.json     ← liga/desliga componentes, thresholds, comandos de build
├── settings/
│   └── mcp.json            ← servidores MCP do projeto
├── steering/               ← regras e instruções
├── hooks/                  ← automações por evento
├── knowledge/              ← base de conhecimento persistente
│   ├── INDEX.md
│   ├── patterns/           ← PIT, WRK, RN, ADR, PA, CC
│   └── sessions/           ← resumos de sessão
├── quality/
│   ├── history.json        ← quality scores por task
│   └── tech-debt.json
└── skills/                 ← skills do projeto
```

Steerings globais em `~/.kiro/steering/` — disponíveis em todos os projetos.

---

## Primeiro uso após bootstrap

### 1. Criar `project-standards.md`

O steering mais importante não é gerado automaticamente porque é 100% específico do projeto.

```powershell
New-Item ".kiro\steering\project-standards.md" -Force
```

Conteúdo mínimo:

```markdown
---
inclusion: auto
---

# Padrões do Projeto

## Stack
- [listar tecnologias principais]

## Estrutura de pastas
[listar src/, tests/, etc.]

## Comandos
- Build: [comando]
- Testes: [comando]

## Regras específicas
- [regra 1]
- [regra 2]
```

### 2. Verificar harness-config.json

```json
"build": {
  "command": "dotnet build MeuProjeto.sln",
  "test_command": "dotnet test tests/",
  "lint_command": ""
}
```

### 3. Configurar variáveis de ambiente

```powershell
$env:GITHUB_PAT     = "ghp_..."
$env:FIGMA_API_KEY  = "figd_..."
```

---

## Steerings — referência rápida

| Steering | Modo | Ativar com |
|----------|------|-----------|
| `harness-output-formatter` | always | automático |
| `harness-anti-patterns` | always | automático |
| `harness-agent-router` | always | automático |
| `harness-one-question` | always | automático |
| `harness-verification-report` | auto | automático |
| `git-commits` | auto | automático |
| `method-development` | manual | `#method-development` |
| `engineering-standards` *(global)* | auto | automático |
| `workflow-aprovacao` *(global)* | auto | automático |
| `workflow-desenvolvimento` *(global)* | auto | automático |
| `continuar-de-onde-paramos` *(global)* | manual | `#continuar-de-onde-paramos` |

---

## Hooks — o que cada um faz

| Hook | Quando dispara | Ação |
|------|---------------|------|
| `guardrails-pre-write` | Antes de executar shell | Bloqueia comandos git destrutivos |
| `build-test-on-stop` | Ao encerrar sessão | Roda build + testes |
| `pre-task-spec-check` | Antes de iniciar task | Lê spec e confirma escopo |
| `validate-task-completion` | Após concluir task | Valida critérios de aceite |
| `session-summary` | Ao encerrar sessão | Salva resumo em knowledge/sessions/ |
| `missing-test-alert` | Ao criar arquivo .cs/.ts/.py | Alerta se não há teste correspondente |

### Adicionar hook de stack específica (.NET)

Criar `.kiro/hooks/build-on-cs-save.json`:

```json
{
  "version": "v1",
  "hooks": [{
    "name": "Build ao salvar C#",
    "trigger": "PostFileSave",
    "matcher": "\\.cs$",
    "action": {
      "type": "command",
      "command": "dotnet build --no-restore -v quiet 2>&1 | Select-Object -Last 5",
      "timeout": 60
    }
  }]
}
```

---

## Knowledge Base — como usar

Criar artefatos de conhecimento quando descobrir padrões importantes:

```markdown
<!-- .kiro/knowledge/patterns/PIT-npgsql-connection-pool.md -->
# PIT: Pool de conexões Npgsql esgota sob carga

**ID:** PIT-npgsql-pool
**Descoberto em:** 2026-01-15

## Problema
Sob carga > 50 req/s, Npgsql lança "connection pool exhausted".

## Causa Raiz
NpgsqlDataSource não registrada como singleton — nova instância a cada request.

## Solução
Registrar uma única instância: builder.Services.AddNpgsqlDataSource(connStr);
```

Atualizar `INDEX.md` após cada novo artefato.

---

## Fluxo de trabalho típico

```
1. Abrir projeto → Kiro carrega steerings e hooks
2. "Continuar de onde paramos" → #continuar-de-onde-paramos
3. Escolher feature → agente cria spec em .kiro/specs/
4. Aprovar spec → "pode implementar"
5. Agente implementa task por task
6. Hook valida cada task concluída
7. Agente faz commit e PR
8. Ao encerrar → hook salva resumo da sessão
```

---

## Dicas de produtividade

- **`#method-development`** antes de implementações complexas — garante o loop de 7 passos
- **`#continuar-de-onde-paramos`** no início de cada dia — sincroniza com issues do GitHub
- Manter `project-standards.md` atualizado — é o steering mais lido pelo agente
- Commitar `.kiro/knowledge/` — o time inteiro se beneficia da base de conhecimento
- **Não** commitar `.kiro/quality/` — é histórico de sessão, não configuração
