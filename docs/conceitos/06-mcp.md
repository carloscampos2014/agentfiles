# MCP — Model Context Protocol

## O que é

MCP é um **protocolo aberto** que conecta agentes AI a ferramentas e fontes de dados externas.
É o "USB" dos agentes: qualquer ferramenta que implementa o protocolo pode ser conectada a
qualquer agente que o suporta.

Sem MCP, o agente só consegue ler/escrever arquivos e rodar comandos. Com MCP, ele consegue:
- Criar issues e PRs no GitHub
- Consultar o banco de dados do projeto
- Buscar documentação atualizada
- Acessar designs no Figma
- Manter memória persistente entre sessões

---

## Onde fica a configuração

| Ferramenta | Arquivo | Formato |
|------------|---------|---------|
| Kiro | `.kiro/settings/mcp.json` | JSON |
| Claude Code | `.mcp.json` (projeto) ou `~/.claude/settings.json` (global) | JSON |
| OpenAI Codex | `.codex/config.toml` (projeto) ou `~/.codex/config.toml` (global) | TOML |
| Gemini CLI | via `gemini-extension.json` dentro de uma extensão | JSON |
| Qwen Code | via `qwen-extension.json` dentro de uma extensão | JSON |

---

## Schema — Kiro e Claude Code (JSON)

```json
{
  "mcpServers": {
    "nome-do-servidor": {
      "command": "npx",
      "args": ["-y", "@pacote/servidor"],
      "env": {
        "VARIAVEL": "${env:NOME_DA_VAR}"
      }
    }
  }
}
```

### Servidor HTTP remoto

```json
{
  "mcpServers": {
    "microsoft-learn": {
      "url": "https://learn.microsoft.com/api/mcp"
    }
  }
}
```

---

## Schema — Codex (TOML)

```toml
[mcp_servers.github]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]
env_vars = ["GITHUB_PERSONAL_ACCESS_TOKEN"]

[mcp_servers.figma]
url = "https://mcp.figma.com/mcp"
bearer_token_env_var = "FIGMA_OAUTH_TOKEN"
```

---

## Servidores incluídos no harness

| Servidor | Pacote | O que fornece | Requer |
|----------|--------|--------------|--------|
| `microsoft-learn` | URL REST | Docs Microsoft | — |
| `filesystem` | `@modelcontextprotocol/server-filesystem` | Acesso ao sistema de arquivos | — |
| `github` | `@modelcontextprotocol/server-github` | Issues, PRs, repos | `GITHUB_PAT` |
| `git` | `mcp-server-git` | Operações git programáticas | — |
| `fetch` | `mcp-server-fetch` | Busca de URLs externas | — |
| `memory` | `@modelcontextprotocol/server-memory` | Memória persistente | — |
| `sequential-thinking` | `@modelcontextprotocol/server-sequential-thinking` | Raciocínio estruturado | — |
| `time` | `mcp-server-time` | Data e hora atual | — |
| `figma` | `figma-developer-mcp` | Designs Figma | `FIGMA_API_KEY` |
| `postgres` | `@modelcontextprotocol/server-postgres` | Consultas ao banco | connection string |

---

## Como adicionar um servidor MCP

### 1. Servidor stdio (comando local)

```json
"meu-servidor": {
  "command": "npx",
  "args": ["-y", "@meu-pacote/servidor"],
  "env": {
    "API_KEY": "${env:MINHA_API_KEY}"
  }
}
```

### 2. Servidor HTTP remoto

```json
"meu-servidor": {
  "url": "https://meu-servidor.com/mcp",
  "env": {
    "Authorization": "Bearer ${env:MEU_TOKEN}"
  }
}
```

### 3. Com uvx (Python)

```json
"meu-servidor": {
  "command": "uvx",
  "args": ["--from", "meu-pacote==1.0.0", "--with", "mcp==1.1.2", "meu-servidor"]
}
```

---

## Variáveis de ambiente no MCP

Nunca colocar tokens diretamente no arquivo de configuração. Use:

```json
"env": {
  "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_PAT}"
}
```

Configurar no terminal antes de abrir o IDE:
```powershell
$env:GITHUB_PAT = "ghp_seu_token_aqui"
```

Ou no `.env` do sistema (nunca commitado):
```
GITHUB_PAT=ghp_seu_token_aqui
FIGMA_API_KEY=figd_seu_token_aqui
```

---

## Diferença entre .kiro/settings/mcp.json e .mcp.json

| Arquivo | Ferramenta | Escopo | Commitável? |
|---------|-----------|--------|-------------|
| `.kiro/settings/mcp.json` | Kiro | Projeto | ✅ (sem secrets) |
| `.mcp.json` (raiz) | Claude Code | Projeto, compartilhado | ✅ (sem secrets) |
| `~/.claude/settings.json` | Claude Code | Global, pessoal | ❌ |
| `.codex/config.toml` | Codex | Projeto | ✅ (sem secrets) |
| `~/.codex/config.toml` | Codex | Global, pessoal | ❌ |

---

## Boas práticas

- **Commitável sim, secrets não**: o arquivo de config vai para o repo. Os tokens, nunca.
- **Instalar dependências**: servidores `npx` e `uvx` são baixados na primeira execução.
  Garanta acesso à internet no primeiro uso.
- **Reiniciar após configurar**: alterações no mcp.json requerem reinício da sessão do IDE.
- **Testar um servidor por vez**: ao adicionar novo servidor, testar antes de adicionar o próximo.
