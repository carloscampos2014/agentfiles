# Guia de Uso — Google Antigravity

## O que o Antigravity oferece

Google Antigravity é uma plataforma de desenvolvimento AI-first que combina execução autônoma, subagentes, sandboxing e um sistema flexível de customizações.

Ele possui suporte nativo e de primeira classe a todos os pilares do harness:
- **Rules:** Diretrizes contextuais e hierárquicas em Markdown (`.agent/rules/*.md` e `GEMINI.md`).
- **Skills:** Procedimentos executados sob demanda através de **Progressive Disclosure** (`.agent/skills/<nome>/SKILL.md`).
- **Hooks:** Interceptadores de ciclo de vida (`.agent/hooks.json`) disparados antes e depois da execução de ferramentas ou de sessões.
- **MCP:** Integração nativa com o ecossistema Model Context Protocol (`mcp_config.json` ou `.agent/mcp_config.json`).

---

## Estrutura que o harness cria

```
GEMINI.md                            ← Instrução e índice raiz do projeto
.agent/
├── hooks.json                       ← Interceptação de ciclo de vida (PreToolUse)
├── mcp_config.json                  ← Servidores MCP do projeto
├── hooks/
│   └── guardrails.js                ← Script de guardrail de comandos (Node.js)
├── rules/                           ← Regras e diretrizes carregadas pelo agente
│   ├── 01-result-pattern.md
│   ├── 02-logging-observability.md
│   ├── 03-testing-requirements.md
│   ├── 04-database-best-practices.md
│   ├── briefing-detalhado.md        ← Formato obrigatório de briefing
│   ├── engineering-standards.md     ← SOLID, Clean Code e padrões
│   ├── harness-anti-patterns.md     ← Comportamentos proibidos
│   ├── method-development.md        ← Loop de 7 passos para implementação
│   ├── senior-developer.md
│   ├── solutions-architect.md
│   └── workflow.md                  ← Branches, Conventional Commits e PRs
├── skills/                          ← Procedimentos ativáveis sob demanda
│   ├── architecture-design/SKILL.md
│   ├── bootstrap-from-code/SKILL.md
│   ├── bootstrap-from-docs/SKILL.md
│   ├── code-review/SKILL.md
│   ├── spec-driven-development/SKILL.md
│   └── systematic-debugging/SKILL.md
├── knowledge/
│   ├── INDEX.md                     ← Índice da base de conhecimento
│   └── memory.jsonl                 ← Grafo de conhecimento persistente (MCP memory)
└── quality/
    ├── history.json                 ← Histórico de qualidade por task
    └── tech-debt.json               ← Rastreamento de débito técnico
```

---

## Inicialização rápida

Para inicializar um projeto com suporte ao Antigravity:

```powershell
# Windows
.\scripts\bootstrap.ps1 `
    -ProjectPath        "C:\Dev\MeuProjeto" `
    -ProjectName        "MeuProjeto" `
    -ProjectDescription "Sistema de exemplo em Node.js e TypeScript" `
    -StackDescription   "Node.js, TypeScript, PostgreSQL" `
    -GithubOwner        "meuusuario" `
    -GithubRepo         "MeuProjeto" `
    -BuildCommand       "npm run build" `
    -TestCommand        "npm test" `
    -Antigravity
```

Ou incluir Antigravity junto com outras ferramentas usando `-All`.

---

## Componentes em detalhes

### 1. Rules (`.agent/rules/`)

As rules do Antigravity orientam a tomada de decisão do modelo. Elas suportam controle de ativação via frontmatter YAML:

* **Sempre ativas (`trigger: always_on`):**
  * `briefing-detalhado.md`: Exige briefing prévio com tabela de escopo e comparação antes/depois.
  * `engineering-standards.md`: Força SOLID, Clean Code, métodos curtos e proibição de secrets.
  * `harness-anti-patterns.md`: Bloqueia workarounds, verificação teatral e conclusões sem evidência.
  * `workflow.md`: Branches protegidas e Conventional Commits.

* **Sob demanda (`trigger: model_decision`):**
  * Ativadas por *progressive disclosure* conforme o contexto da tarefa (ex.: `01-result-pattern.md`, `04-database-best-practices.md`).

### 2. Skills (`.agent/skills/`)

Cada skill é uma pasta com um arquivo `SKILL.md` contendo `name` e `description` no frontmatter:
* O Antigravity injeta inicialmente apenas o nome e a descrição no orçamento de contexto.
* Quando uma tarefa exige a skill (ou quando solicitada pelo usuário), o procedimento completo é lido sob demanda.

### 3. Hooks e Guardrails (`.agent/hooks.json`)

O arquivo `.agent/hooks.json` intercepta a chamada de ferramentas:

```json
{
  "safety-guardrails": {
    "PreToolUse": [
      {
        "matcher": "run_command",
        "hooks": [
          {
            "type": "command",
            "command": "node .agent/hooks/guardrails.js"
          }
        ]
      }
    ]
  }
}
```

O script `guardrails.js` recebe os dados da chamada via `stdin` e responde em `stdout`:
* Bloqueia `git push --force`, `git push -f`, `git reset --hard`, exclusões destrutivas (`rm -rf /`) e push direto para `main`/`master`.
* Retorna `{"decision": "deny", "reason": "..."}` para abortar a ação imediatamente ou `{"decision": "allow"}` para permitir.

### 4. Servidores MCP (`.agent/mcp_config.json`)

Disponibiliza ferramentas externas padronizadas:
* `filesystem`: Leitura e escrita controlada no diretório do projeto.
* `git`: Inspeção de histórico, diff e branches.
* `github`: Interação com issues, PRs e releases via `GITHUB_PAT`.
* `knowledge-rag`: Busca vetorial semântica nos arquivos de documentação do projeto.
* `memory`: Armazenamento de grafos de conhecimento em `.agent/knowledge/memory.jsonl`.
* `fetch`: Consulta de documentações e endpoints HTTP externos.

---

## Validação e Sincronização

Você pode validar a integridade do harness a qualquer momento:

```powershell
.\scripts\validate-harness.ps1 -ProjectPath "C:\Dev\MeuProjeto"
```

E sincronizar skills novas entre o Antigravity e outras ferramentas com:

```powershell
.\scripts\sync-tools.ps1 -ProjectPath "C:\Dev\MeuProjeto" -Type skill -Name code-review -SourceTool antigravity
```

