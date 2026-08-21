# Skill: Bootstrap from Code

Analisa código-fonte existente e monta o comando `bootstrap.ps1` completo.

## Como usar

Diga: "gera o bootstrap baseado no código" e indique onde está o projeto e o agentfiles.

---

## Processo

### 1. Detectar stack

- `*.sln`, `*.csproj` → .NET | `package.json` → Node.js
- `pom.xml` → Java | `Cargo.toml` → Rust | `go.mod` → Go
- `requirements.txt` → Python | `pubspec.yaml` → Flutter
- Ler também README.md e .github/workflows/

### 2. Inferir comandos

- .NET → `dotnet build` / `dotnet test`
- Node → `npm run build` / `npm test`
- Python → `python -m build` / `pytest`
- Preferir comando exato do CI quando disponível

### 3. Detectar GitHub

Extrair owner/repo da URL do remote git.

### 4. Detectar ferramentas já presentes

Verificar .kiro/, .claude/, .github/, .amazonq/, .trae/, AGENTS.md, GEMINI.md.
Avisar quais já existem.

### 5. Apresentar resultado

```
### Stack detectada + evidências

### Parâmetros identificados
| Parâmetro | Valor | Fonte |

### Parâmetros pendentes

### Comando
\`\`\`powershell
& "C:\Dev\agentfiles\scripts\bootstrap.ps1" `
    ...
\`\`\`
```

## Regras

- Nunca executar o bootstrap diretamente
- Sempre indicar a fonte de cada parâmetro detectado
- Se projeto já tem harness parcial, sugerir update-harness.ps1
