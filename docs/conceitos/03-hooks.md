# Hooks

## O que são

Hooks são **automações disparadas por eventos do IDE**. Quando algo acontece — você salva um
arquivo, cria um novo, o agente encerra uma sessão — o hook executa uma ação automaticamente.

Sem hooks, você precisa lembrar de rodar o build depois de cada mudança, de verificar a
arquitetura a cada novo arquivo, de salvar um resumo da sessão ao final. Com hooks, isso
acontece automaticamente.

---

## Onde ficam (Kiro)

```
.kiro/hooks/
└── nome-do-hook.json
```

Cada arquivo é um hook independente com schema JSON.

---

## Schema de um hook

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Nome descritivo",
      "description": "O que este hook faz",
      "trigger": "PostFileSave",
      "matcher": "padrão-regex-opcional",
      "action": {
        "type": "command | agent",
        "command": "comando shell",
        "prompt": "instrução para o agente",
        "timeout": 60
      },
      "enabled": true
    }
  ]
}
```

---

## Eventos disponíveis

| Evento | Quando dispara | Suporta matcher? |
|--------|---------------|-----------------|
| `PostFileSave` | Ao salvar arquivo | ✅ (path do arquivo) |
| `PostFileCreate` | Ao criar arquivo novo | ✅ (path do arquivo) |
| `PostFileDelete` | Ao deletar arquivo | ✅ (path do arquivo) |
| `PreToolUse` | Antes de executar ferramenta | ✅ (nome da ferramenta) |
| `PostToolUse` | Após executar ferramenta | ✅ (nome da ferramenta) |
| `Stop` | Quando o agente encerra | ❌ |
| `PreTaskExec` | Antes de iniciar task de spec | ❌ |
| `PostTaskExec` | Após concluir task de spec | ❌ |
| `UserPromptSubmit` | Ao enviar mensagem no chat | ❌ |
| `SessionStart` | Ao iniciar nova sessão | ❌ |

---

## Tipos de ação

### `command` — executa um comando shell

```json
"action": {
  "type": "command",
  "command": "dotnet build --no-restore -v quiet 2>&1 | Select-Object -Last 5",
  "timeout": 60
}
```

- Recebe contexto da sessão via stdin (JSON)
- `exit 0` = sucesso
- `exit 2` = bloquear a ação (só para PreToolUse)
- Outros códigos = falha silenciosa

### `agent` — injeta instrução no contexto do agente

```json
"action": {
  "type": "agent",
  "prompt": "Um arquivo foi salvo em Domain. Verifique se há referências proibidas a Infrastructure ou Api. Se encontrar, alerte o usuário."
}
```

- O agente lê o prompt e age de acordo
- Útil para verificações que requerem leitura de código
- Não executa código — apenas instrui o agente

---

## Matcher — filtrar por arquivo ou ferramenta

O matcher é uma **expressão regular** testada contra:
- Para `PostFileSave`, `PostFileCreate`: o **caminho do arquivo**
- Para `PreToolUse`, `PostToolUse`: o **nome da ferramenta**

```json
"matcher": "\\.cs$"                          // arquivos .cs
"matcher": "src\\\\.*\\.cs$"                // arquivos .cs dentro de src/
"matcher": "fs_write|str_replace"           // ferramentas de escrita
"matcher": "src\\\\.*\\.(Application|Domain)\\\\.*\\.cs$"  // camadas específicas
```

---

## Hooks no Claude Code

No Claude Code, hooks ficam no `settings.json`, não em arquivos separados:

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "echo 'Arquivo modificado'"
      }]
    }]
  }
}
```

---

## Padrão PreToolUse com permissão dinâmica

O PreToolUse pode retornar uma decisão de permissão:

```json
{
  "hookSpecificOutput": {
    "permissionDecision": "ask",
    "permissionDecisionReason": "Este comando parece destrutivo"
  }
}
```

Valores: `allow`, `deny`, `ask`

---

## Boas práticas

- **Um hook = uma responsabilidade**. Não combinar build + lint + testes no mesmo hook.
- **Timeouts realistas**: builds .NET levam ~30s, não 5s.
- **Matcher específico**: evitar disparo em arquivos irrelevantes.
- **Hooks `command` para CI**: use para verificações objetivas (build passou? testes passaram?).
- **Hooks `agent` para análise**: use quando a verificação requer leitura e interpretação de código.
- **Não bloquear tudo**: hooks muito restritivos frustram o fluxo. Reserve `exit 2` para
  proibições reais (push --force, rm -rf na raiz).

---

## Hooks incluídos no harness

| Hook | Evento | Tipo | O que faz |
|------|--------|------|-----------|
| `guardrails-pre-write` | PreToolUse | agent | Bloqueia git destrutivo |
| `build-test-on-stop` | Stop | agent | Roda build+testes ao encerrar |
| `pre-task-spec-check` | PreTaskExec | agent | Lê spec antes da task |
| `validate-task-completion` | PostTaskExec | agent | Valida fidelidade ao spec |
| `session-summary` | Stop | agent | Salva resumo da sessão |
| `missing-test-alert` | PostFileCreate | agent | Alerta ao criar arquivo sem teste |
