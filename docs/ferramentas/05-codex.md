# Guia de Uso — OpenAI Codex

## O que o Codex oferece

O Codex CLI é o agente de terminal da OpenAI. Seu sistema de configuração é mais
simples que o Kiro e o Claude Code: instruções em `AGENTS.md` e MCPs em `config.toml`.
Não tem hooks, agents separados nem skills — toda instrução fica no `AGENTS.md`.

O ponto forte é a hierarquia de descoberta: pode ter um `AGENTS.md` global, um por
projeto e um por subdiretório, com as instruções mais próximas tendo precedência.

---

## Estrutura que o harness cria

```
AGENTS.md               ← instrução principal do projeto
.codex/
└── config.toml         ← MCPs de projeto
```

---

## Hierarquia de AGENTS.md

```
~/.codex/AGENTS.md          ← global (aplica em todos os projetos)
    ↓ complementado por
AGENTS.md                   ← raiz do projeto
    ↓ complementado por
subdir/AGENTS.md            ← instrução específica de subcomponente
    ↓ complementado por
subdir/subdir/AGENTS.md     ← instrução ainda mais específica
```

Instruções são **concatenadas**, não substituídas. Mais próximo = aparece depois = tem precedência.

---

## Primeiro uso após bootstrap

### 1. Substituir os placeholders no AGENTS.md

```powershell
# Verificar e editar manualmente
notepad AGENTS.md
```

Substituir:
- `__PROJECT_NAME__` → nome real
- `__PROJECT_DESCRIPTION__` → descrição real
- `__BUILD_COMMAND__` → `dotnet build MeuProjeto.sln`
- `__TEST_COMMAND__` → `dotnet test tests/`

### 2. Configurar MCPs no .codex/config.toml

```toml
[mcp_servers.github]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]
env_vars = ["GITHUB_PERSONAL_ACCESS_TOKEN"]

[mcp_servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "C:\\Dev\\MeuProjeto"]
```

### 3. Configurar variável de ambiente

```powershell
$env:GITHUB_PERSONAL_ACCESS_TOKEN = "ghp_..."
```

---

## Criar instrução para subcomponente

Para um serviço com regras diferentes do projeto raiz:

```
services/payments/AGENTS.md
```

```markdown
# Serviço de Pagamentos — Regras Específicas

## Regras adicionais

- Usar `make test-payments` em vez de `dotnet test`
- Toda alteração de valor monetário deve ter log de auditoria
- Nunca logar valores de cartão — usar apenas últimos 4 dígitos
```

O Codex carregará o `AGENTS.md` raiz + este arquivo ao trabalhar em `services/payments/`.

---

## AGENTS.override.md — sobrescrever sem deletar

Para uma substituição temporária sem apagar o arquivo base:

```
~/.codex/AGENTS.override.md   ← substitui o global
services/payments/AGENTS.override.md  ← substitui o da pasta
```

Quando o override existe, o arquivo regular da mesma pasta é ignorado.

---

## Dicas de produtividade

- **AGENTS.md conciso**: o limite padrão é 32KB total para todas as instruções concatenadas
- **Dividir por subdiretório**: coloque instruções de pagamentos em `services/payments/AGENTS.md`,
  não tudo na raiz
- **Global para preferências pessoais**: `~/.codex/AGENTS.md` é ótimo para
  "sempre responder em português" e "preferir pnpm a npm"
- **config.toml no projeto**: MCPs de projeto (filesystem, postgres) ficam em `.codex/config.toml`
  e vão para o repo. MCPs pessoais (memory, time) ficam em `~/.codex/config.toml`
