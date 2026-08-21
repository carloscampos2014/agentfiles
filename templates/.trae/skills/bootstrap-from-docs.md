# Skill: Bootstrap from Docs

Lê documentos de ideia/requisitos e monta o comando `bootstrap.ps1` completo.

## Como usar

Diga: "gera o bootstrap baseado nesses documentos" indicando onde estão os documentos, o agentfiles e o destino do projeto.

---

## Processo

### 1. Ler os documentos

Procurar por: nome, descrição, stack, plataforma, GitHub owner/repo, comandos de build/test.

### 2. Inferir o que falta

Mobile → MAUI/.NET ou React Native. Se não for possível inferir, perguntar antes.

### 3. Detectar ferramentas: `-Kiro` sempre + outros conforme mencionado

### 4. Apresentar resultado

```
### Parâmetros identificados | inferidos | pendentes

### Comando
\`\`\`powershell
& "C:\Dev\agentfiles\scripts\bootstrap.ps1" `
    -ProjectPath "..." -ProjectName "..." `
    -ProjectDescription "..." -StackDescription "..." `
    -GithubOwner "..." -GithubRepo "..." `
    -BuildCommand "..." -TestCommand "..." `
    -Kiro -Claude
\`\`\`
```

**Nunca executar o bootstrap — apenas gerar para o usuário executar.**
