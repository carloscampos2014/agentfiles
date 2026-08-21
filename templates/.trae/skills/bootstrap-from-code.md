# Skill: Bootstrap from Code

Analisa código-fonte existente e monta o comando `bootstrap.ps1` completo.

## Como usar

Diga: "gera o bootstrap baseado no código" indicando onde está o projeto e o agentfiles.

---

## Processo

### 1. Detectar stack pelos arquivos de configuração na raiz

- `*.sln`, `*.csproj` → .NET | `package.json` → Node.js
- `pom.xml` → Java | `Cargo.toml` → Rust | `go.mod` → Go
- `requirements.txt` → Python | `pubspec.yaml` → Flutter
- Ler README.md e .github/workflows/ para comandos exatos

### 2. Inferir comandos de build/test pela stack detectada

### 3. Extrair GitHub owner/repo do remote git

### 4. Detectar ferramentas já presentes (.kiro/, .claude/, etc.) e avisar

### 5. Apresentar resultado

```
### Stack + evidências | Parâmetros | Pendentes

### Comando
\`\`\`powershell
& "C:\Dev\agentfiles\scripts\bootstrap.ps1" `
    -ProjectPath "..." ...
\`\`\`
```

**Nunca executar o bootstrap diretamente. Se projeto já tem harness parcial, sugerir update-harness.ps1.**
