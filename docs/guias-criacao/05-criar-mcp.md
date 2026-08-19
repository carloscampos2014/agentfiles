# Guia: Adicionar um Servidor MCP

## Quando adicionar um MCP

- Você quer que o agente acesse uma API externa (Jira, Confluence, Slack)
- Quer que o agente consulte o banco de dados diretamente
- Quer dar ao agente acesso a ferramentas de monitoramento ou observabilidade
- Quer persistir memória entre sessões de forma estruturada

---

## Método rápido

Editar o arquivo de configuração do MCP da ferramenta e adicionar o bloco do servidor.

---

## Encontrar servidores MCP disponíveis

Repositórios de referência:
- [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) — servidores oficiais
- [punkpeye/awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers) — lista curada
- npm: `npm search @modelcontextprotocol`

---

## Adicionar no Kiro (`.kiro/settings/mcp.json`)

```json
{
  "mcpServers": {
    "nome-do-servidor": {
      "command": "npx",
      "args": ["-y", "@pacote/servidor", "argumentos-extras"],
      "env": {
        "VARIAVEL_API": "${env:NOME_DA_ENV_VAR}"
      }
    }
  }
}
```

## Adicionar no Claude Code (`.mcp.json` na raiz)

Mesmo formato JSON. Commitável junto com o projeto.

## Adicionar no Codex (`.codex/config.toml`)

```toml
[mcp_servers.nome-do-servidor]
command = "npx"
args = ["-y", "@pacote/servidor"]

[mcp_servers.nome-do-servidor.env]
VARIAVEL_API = "valor"
```

---

## Exemplos de servidores úteis

### Banco de dados PostgreSQL

```json
"postgres": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-postgres",
           "postgresql://usuario:senha@localhost:5432/nome_banco"]
}
```

### Banco de dados SQLite

```json
"sqlite": {
  "command": "uvx",
  "args": ["mcp-server-sqlite", "--db-path", "C:\\Dev\\MeuProjeto\\data.db"]
}
```

### Jira

```json
"jira": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-jira"],
  "env": {
    "JIRA_URL": "${env:JIRA_URL}",
    "JIRA_TOKEN": "${env:JIRA_TOKEN}",
    "JIRA_EMAIL": "${env:JIRA_EMAIL}"
  }
}
```

### Slack

```json
"slack": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-slack"],
  "env": {
    "SLACK_BOT_TOKEN": "${env:SLACK_BOT_TOKEN}"
  }
}
```

### Playwright (browser automation)

```json
"playwright": {
  "command": "npx",
  "args": ["-y", "@playwright/mcp@latest"]
}
```

### Servidor customizado com Node.js

1. Criar `mcp-servers/meu-servidor/index.js`:

```javascript
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';

const server = new McpServer({ name: 'meu-servidor', version: '1.0.0' });

server.registerTool('buscar_dados', {
  description: 'Busca dados da API interna',
  inputSchema: z.object({ id: z.string() }).shape,
}, async ({ id }) => {
  const data = await fetch(`https://minha-api.com/dados/${id}`);
  const json = await data.json();
  return { content: [{ type: 'text', text: JSON.stringify(json) }] };
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

2. Registrar no `mcp.json`:

```json
"meu-servidor": {
  "command": "node",
  "args": ["mcp-servers/meu-servidor/index.js"],
  "cwd": "C:\\Dev\\MeuProjeto"
}
```

---

## Boas práticas

- **Secrets fora do arquivo**: usar `${env:NOME_VAR}` — nunca valor literal.
- **Testar individualmente**: adicionar um servidor por vez para isolar problemas.
- **Reiniciar o IDE**: alterações no mcp.json só têm efeito após reinício.
- **Timeout de startup**: servidores npm demoram na primeira execução (download do pacote).
- **Scope do projeto vs. global**:
  - Projeto (`.kiro/settings/mcp.json`, `.mcp.json`): para servidores ligados ao projeto (banco, filesystem)
  - Global (`~/.kiro/settings/mcp.json`, `~/.claude/settings.json`): para servidores pessoais (memory, time)
