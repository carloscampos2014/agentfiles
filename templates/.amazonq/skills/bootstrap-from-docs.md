# Skill: Bootstrap from Docs

Lê documentos de ideia/requisitos e monta o comando `bootstrap.ps1` completo e pronto para executar.

## Como usar

Diga: "gera o bootstrap baseado nesses documentos" e indique onde estão os documentos, o agentfiles e o destino do projeto.

---

## Processo

### 1. Ler os documentos

Procurar por: nome do projeto, descrição, stack, plataforma, GitHub owner/repo, comandos de build/test.

### 2. Inferir o que não está explícito

- Mobile → MAUI/.NET ou React Native
- Twilio → .NET ou Node
- Se não for possível inferir com segurança, perguntar antes de gerar

### 3. Detectar ferramentas

- `-Kiro` sempre
- `-Claude`, `-Copilot`, `-AmazonQ`, outros — conforme mencionado

### 4. Apresentar resultado

```
### Parâmetros identificados
| Parâmetro | Valor | Fonte |

### Parâmetros inferidos
| Parâmetro | Valor | Raciocínio |

### Parâmetros pendentes
- [o que precisa ser preenchido]

### Comando
\`\`\`powershell
& "C:\Dev\agentfiles\scripts\bootstrap.ps1" `
    -ProjectPath "..." `
    -ProjectName "..." `
    -ProjectDescription "..." `
    -StackDescription "..." `
    -GithubOwner "..." `
    -GithubRepo "..." `
    -BuildCommand "..." `
    -TestCommand "..." `
    -Kiro -Claude
\`\`\`
```

## Regras

- Nunca executar o bootstrap — apenas gerar para o usuário executar
- Se documentos vagos, listar o que precisa ser definido antes
