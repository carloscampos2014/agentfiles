# Guia: Criar um Hook

## Quando criar um novo hook

- Você quer que algo aconteça automaticamente quando salvar um arquivo
- Você quer bloquear um comando perigoso antes que seja executado
- Você quer gerar um relatório ao final de cada sessão
- Você quer verificar conformidade sempre que criar um arquivo novo

Se a ação é sob demanda, não automática → use uma **skill**, não um hook.

---

## Método rápido — usar o wizard

```powershell
C:\Dev\agentfiles\scripts\new-hook.ps1 -ProjectPath "C:\Dev\MeuProjeto"
```

---

## Método manual — passo a passo

### Passo 1 — Definir o evento e a ação

| Pergunta | Opções |
|----------|--------|
| Quando deve disparar? | PostFileSave, PostFileCreate, PreToolUse, Stop, PreTaskExec, PostTaskExec |
| O que deve fazer? | Executar comando shell (`command`) ou instruir o agente (`agent`) |
| Deve filtrar por arquivo/ferramenta? | Sim → definir `matcher` em regex |

### Passo 2 — Escolher o tipo de ação

**Use `command` quando:**
- A verificação é objetiva (build passou? lint OK?)
- Precisa de output de um processo externo
- Quer bloquear ação com `exit 2`

**Use `agent` quando:**
- A verificação requer leitura e interpretação de código
- Quer que o agente analise e alerte, não execute
- A lógica de verificação é complexa

### Passo 3 — Criar o arquivo

```
.kiro/hooks/nome-descritivo.json
```

### Passo 4 — Escrever o JSON

#### Template para `command`

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Nome Descritivo do Hook",
      "description": "O que este hook faz em uma frase",
      "trigger": "PostFileSave",
      "matcher": "\\.cs$",
      "action": {
        "type": "command",
        "command": "dotnet build --no-restore -v quiet 2>&1 | Select-Object -Last 5",
        "timeout": 60
      },
      "enabled": true
    }
  ]
}
```

#### Template para `agent`

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Nome Descritivo do Hook",
      "description": "O que este hook faz em uma frase",
      "trigger": "PostFileCreate",
      "matcher": "src\\\\.*\\.cs$",
      "action": {
        "type": "agent",
        "prompt": "Um arquivo foi criado em src/. Verifique se [condição]. Se [problema], alerte o usuário com: [mensagem]. Não [ação proibida] — apenas alerte."
      },
      "enabled": true
    }
  ]
}
```

#### Template para PreToolUse com bloqueio

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Bloquear Operação Perigosa",
      "description": "Bloqueia [operação] antes de executar",
      "trigger": "PreToolUse",
      "matcher": "execute_pwsh|execute_bash",
      "action": {
        "type": "agent",
        "prompt": "Um comando está prestes a ser executado. Se contiver [padrão perigoso], responda com exit 2 e explique o problema. Se for seguro, deixe passar com exit 0."
      }
    }
  ]
}
```

---

## Exemplos práticos

### Build ao salvar C#

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

### Lint ao salvar TypeScript

```json
{
  "version": "v1",
  "hooks": [{
    "name": "Lint ao salvar TypeScript",
    "trigger": "PostFileSave",
    "matcher": "\\.(ts|tsx)$",
    "action": {
      "type": "command",
      "command": "npx eslint \"${file}\" --max-warnings 0 2>&1 | tail -10",
      "timeout": 30
    }
  }]
}
```

### Guarda de arquitetura — Application não importa Infrastructure

```json
{
  "version": "v1",
  "hooks": [{
    "name": "Guarda de Arquitetura",
    "trigger": "PostFileSave",
    "matcher": "src\\\\.*\\.Application\\\\.*\\.cs$",
    "action": {
      "type": "agent",
      "prompt": "Um arquivo da camada Application foi salvo. Leia o conteúdo e verifique se contém referências proibidas: EntityFrameworkCore, DbContext, Infrastructure, Api, Microsoft.AspNetCore. Se encontrar, alerte: '[arquivo] viola a regra de dependência: Application não pode referenciar [referência]'. Não corrija — apenas alerte."
    }
  }]
}
```

---

## Regras de matcher (regex)

```
\\.cs$                    → arquivos terminando em .cs
src\\\\.*\\.cs$           → .cs dentro de src/ (note escape duplo no JSON)
\\.(ts|tsx)$              → .ts ou .tsx
src\\\\.*\\.(Application|Domain)\\\\.*\\.cs$  → Application ou Domain
execute_pwsh|execute_bash → ferramentas de shell
fs_write|str_replace      → ferramentas de escrita de arquivo
```

---

## Checklist antes de commitar

- [ ] Nome do arquivo é descritivo
- [ ] `trigger` é o evento correto para o que você quer
- [ ] `matcher` filtra apenas o que deve disparar (não muito amplo)
- [ ] Tipo `command` tem `timeout` realista
- [ ] Tipo `agent` tem prompt claro sobre o que verificar e como reportar
- [ ] `enabled: true` está presente
- [ ] JSON é válido (testar com `Get-Content hook.json | ConvertFrom-Json`)
