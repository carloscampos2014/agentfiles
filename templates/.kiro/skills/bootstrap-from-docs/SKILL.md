---
name: bootstrap-from-docs
description: Le documentos de ideia/requisitos e gera o comando bootstrap.ps1 completo e pronto para executar. Ativar com /bootstrap-from-docs ou "gerar bootstrap a partir dos documentos".
---

# Skill: Bootstrap from Docs

Lê documentos de ideia, requisitos ou briefing de um projeto e monta o comando `bootstrap.ps1` mais adequado, com todos os parâmetros preenchidos.

## Como ativar

`/bootstrap-from-docs` ou dizer "gera o bootstrap baseado nesses documentos" / "lê a documentação e monta o bootstrap"

O usuário deve indicar:
- Onde estão os documentos (pasta ou arquivos via `#File`)
- Onde está o agentfiles (ex: `C:\Dev\agentfiles`)
- Onde será criado o projeto (ex: `C:\Dev\NovoProjeto`)

---

## Processo

### Etapa 1 — Ler os documentos

Ler todos os arquivos indicados. Procurar por:

- **Nome do projeto** — título do documento, nome da pasta, nome do sistema
- **Descrição** — objetivo principal em 1-2 frases
- **Stack tecnológica** — linguagens, frameworks, bancos de dados, serviços externos mencionados
- **Plataforma** — web, mobile, desktop, API, CLI
- **Repositório GitHub** — owner e nome do repo se mencionados
- **Comandos de build/test** — se houver referência ao processo de build

### Etapa 2 — Inferir o que não está explícito

Se a stack não estiver clara nos documentos, inferir com base em:
- Plataforma alvo (mobile → MAUI/.NET ou React Native; web → ASP.NET, Next.js, etc.)
- Requisitos de integração mencionados (Twilio → .NET ou Node; ML → Python)
- Referências implícitas (mention de "API REST" + "banco relacional" → inferir stack adequada)

Se não for possível inferir com segurança, **perguntar ao usuário** antes de gerar o comando.

### Etapa 3 — Detectar ferramentas adequadas

Com base no contexto do usuário e dos documentos, recomendar quais flags usar:
- `-Kiro` — sempre (IDE principal)
- `-Claude` — se o usuário mencionar Claude Code
- `-Copilot` — se houver `.github` ou menção ao GitHub Copilot
- `-AmazonQ` — se houver menção à AWS ou Amazon Q
- `-Codex` — se houver menção ao OpenAI Codex
- `-Gemini` — se houver menção ao Gemini CLI
- `-Trae` — se houver menção ao TRAE IDE

### Etapa 4 — Montar o comando

Gerar o comando completo no seguinte formato:

```powershell
& "C:\Dev\agentfiles\scripts\bootstrap.ps1" `
    -ProjectPath "C:\Dev\__NOME_PROJETO__" `
    -ProjectName "__NOME_PROJETO__" `
    -ProjectDescription "__DESCRICAO__" `
    -StackDescription "__STACK__" `
    -GithubOwner "__OWNER__" `
    -GithubRepo "__REPO__" `
    -BuildCommand "__BUILD_COMMAND__" `
    -TestCommand "__TEST_COMMAND__" `
    -Kiro -Claude -Copilot
```

### Etapa 5 — Apresentar resultado

Exibir:
1. **Parâmetros identificados** — tabela com o que foi encontrado e de onde veio
2. **Parâmetros inferidos** — o que foi deduzido e por quê
3. **Parâmetros pendentes** — o que ficou como placeholder e precisa ser preenchido depois
4. **O comando pronto** — em bloco de código PowerShell, pronto para copiar e colar

---

## Formato de saída

```
## Bootstrap gerado a partir dos documentos

### Parâmetros identificados
| Parâmetro | Valor | Fonte |
|-----------|-------|-------|
| ProjectName | NomeDoProjeto | Título do documento X |
| StackDescription | .NET 10, PostgreSQL | Seção "Tecnologias" |
| ...

### Parâmetros inferidos
| Parâmetro | Valor | Raciocínio |
|-----------|-------|-----------|
| BuildCommand | dotnet build | Stack .NET detectada |
| ...

### Parâmetros pendentes (preencher depois)
- GithubOwner — não mencionado nos documentos
- TestCommand — estrutura de testes não definida ainda

### Comando

\`\`\`powershell
& "C:\Dev\agentfiles\scripts\bootstrap.ps1" `
    -ProjectPath "..." `
    ...
\`\`\`

> Revise os parâmetros pendentes antes de executar.
```

---

## Regras

- Nunca executar o bootstrap diretamente — apenas gerar o comando para o usuário revisar e executar
- Se houver dúvida sobre stack, perguntar antes de inferir
- Se os documentos estiverem vagos demais, listar o que precisa ser definido antes de continuar
