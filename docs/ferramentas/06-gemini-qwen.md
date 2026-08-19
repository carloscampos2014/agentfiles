# Guia de Uso — Gemini CLI e Qwen Code

## O que oferecem

Gemini CLI e Qwen Code são agentes de terminal com mecanismo de configuração muito similar:
um arquivo de instrução na raiz do projeto (`GEMINI.md` / `QWEN.md`) com hierarquia global
→ projeto → subdiretório.

Ambos suportam agents, skills, hooks e MCP — mas **apenas dentro de extensões** (pacotes
instalados separadamente). Para uso diário sem extensões customizadas, o arquivo de projeto
é o ponto de configuração.

---

## Estrutura que o harness cria

### Gemini CLI
```
GEMINI.md               ← instrução do projeto
```

### Qwen Code
```
QWEN.md                 ← instrução do projeto
```

---

## Hierarquia de GEMINI.md / QWEN.md

```
~/.gemini/GEMINI.md         ← global
    ↓ complementado por
GEMINI.md                   ← raiz do projeto
    ↓ complementado por
src/GEMINI.md               ← subdiretório (se existir)
```

Todos são carregados e concatenados. Mais próximo = mais específico.

---

## Importar outros arquivos (Gemini CLI)

O Gemini suporta `@import` para modularizar instruções:

```markdown
# GEMINI.md

[instrução principal]

@./docs/ARCHITECTURE.md
@./docs/API.md
```

Isso inclui o conteúdo desses arquivos no contexto de cada sessão.
Útil para incluir a documentação técnica do projeto automaticamente.

---

## Primeiro uso após bootstrap

### 1. Substituir placeholders

Abrir `GEMINI.md` ou `QWEN.md` e substituir:
- `__PROJECT_NAME__` → nome real
- `__PROJECT_DESCRIPTION__` → descrição real
- `__STACK_DESCRIPTION__` → stack real
- `__BUILD_COMMAND__` → comando real
- `__TEST_COMMAND__` → comando real

### 2. Adicionar contexto específico da stack

```markdown
## Stack e convenções específicas

### Backend (.NET)
- Sempre usar Dapper, nunca EF Core
- Migrations via DbUp (scripts SQL versionados)
- Resultado de use cases: Result<T> — nunca void ou throw para negócio

### Banco (PostgreSQL)
- Soft delete com coluna deleted_at
- Toda tabela tem created_at e updated_at
- Índice obrigatório em toda FK
```

---

## Instalar extensões com skills e agents

Para usar agents e skills reais no Gemini/Qwen:

```bash
# Gemini CLI — instalar extensão do Claude Code Marketplace
gemini extensions install https://github.com/usuario/minha-extensao

# Qwen Code — instalar extensão compatível
qwen extensions install https://github.com/usuario/minha-extensao

# Qwen Code — instalar extensão do Gemini Extensions Gallery
qwen extensions install https://github.com/usuario/gemini-extension
```

As extensões ficam em `~/.gemini/extensions/` ou `~/.qwen/extensions/`.

---

## Estrutura de uma extensão Gemini

```
minha-extensao/
├── gemini-extension.json   ← manifesto
├── GEMINI.md               ← contexto da extensão
├── skills/
│   └── meu-workflow/
│       └── SKILL.md
└── commands/
    └── meu-comando.toml
```

---

## Diferenças entre Gemini e Qwen

| Aspecto | Gemini CLI | Qwen Code |
|---------|-----------|-----------|
| Arquivo de projeto | `GEMINI.md` | `QWEN.md` |
| Importação | `@./arquivo.md` | similar |
| Extensões | Gemini Extensions Gallery | compatível com Gemini + Claude Marketplace |
| Agents em extensão | SKILL.md em `skills/` | YAML ou MD em `agents/` |
| Conversão | — | converte extensões Gemini automaticamente |

Qwen Code é mais extensível — instala extensões de múltiplos ecossistemas.

---

## Dicas de produtividade

- **`@import`** (Gemini) é poderoso — inclua `ARCHITECTURE.md` e `API.md` no contexto
- **GEMINI.md / QWEN.md na raiz** é commitado e beneficia todo o time
- Para trabalho mais pesado, instale extensões com agents especializados
- Arquivo global (`~/.gemini/GEMINI.md`) é ótimo para preferências pessoais
