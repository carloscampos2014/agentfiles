# Contribuindo com o agentfiles

Obrigado pelo interesse em contribuir! Este guia explica como participar.

---

## Formas de contribuir

- **Novos templates** — steering, hook, skill ou agent para uma stack específica
- **Novas ferramentas** — suporte a uma ferramenta AI ainda não coberta
- **Melhoria de templates existentes** — conteúdo mais preciso, exemplos melhores
- **Documentação** — correções, traduções, exemplos adicionais
- **Scripts** — melhorias nos wizards ou novos scripts utilitários
- **Bugs** — reportar ou corrigir comportamentos incorretos nos templates

---

## Processo

### 1. Abrir uma issue primeiro

Antes de abrir um PR para mudanças significativas (novo template, nova ferramenta),
abra uma issue descrevendo o que pretende fazer. Isso evita trabalho duplicado.

Para correções simples (typo, link quebrado, exemplo incorreto), pode abrir o PR diretamente.

### 2. Fork e branch

```bash
git clone https://github.com/carloscampos2014/agentfiles.git
cd agentfiles
git checkout -b feat/nome-descritivo
```

### 3. Fazer as mudanças

- Seguir os padrões dos templates existentes (frontmatter, estrutura, tom)
- Documentação em português
- Templates em português (termos técnicos em inglês)
- Sem conteúdo específico de empresa ou projeto real

### 4. Validar

```powershell
# Verificar se os JSON dos hooks são válidos
Get-ChildItem templates\.kiro\hooks\*.json |
    ForEach-Object { $_ | Get-Content -Raw | ConvertFrom-Json | Out-Null; Write-Host "OK: $($_.Name)" }
```

### 5. Abrir o PR

- Título descritivo seguindo Conventional Commits: `feat:`, `fix:`, `docs:`, `chore:`
- Descrever o que foi adicionado/modificado e por quê
- Referenciar a issue relacionada com `Closes #N`

---

## Padrões para templates

### Steerings

- Frontmatter com `inclusion` e `description`
- Conteúdo acionável — regras específicas, não vagas
- Exemplos ✅ correto e ❌ errado quando útil
- Um único tópico por steering

### Hooks

- JSON válido (testar antes de submeter)
- `name` e `description` descritivos
- `matcher` específico o suficiente para não disparar em excesso
- `timeout` realista para o comando

### Skills

- Frontmatter com `name` e `description` com keywords de ativação
- Processo em etapas numeradas
- Formato de saída definido
- Criada para todas as ferramentas relevantes (Kiro, Claude, Copilot, Amazon Q, TRAE)

### Agents

- Frontmatter correto por ferramenta (campo `model` para Claude e Amazon Q)
- Conteúdo denso: filosofia, processo, exemplos de código, checklist
- Ferramentas mínimas necessárias (não dar `Write` para agents de review)

---

## Estrutura do projeto

```
agentfiles/
├── templates/          ← templates que o bootstrap copia para os projetos
│   ├── .kiro/
│   ├── .claude/
│   ├── .github/
│   ├── .amazonq/
│   ├── .trae/
│   ├── codex/
│   ├── gemini/
│   └── qwen/
├── scripts/            ← scripts PowerShell utilitários
├── docs/               ← documentação completa
│   ├── conceitos/
│   ├── guias-criacao/
│   ├── ferramentas/
│   └── templates/
└── README.md
```

---

## Dúvidas

Abra uma [issue](https://github.com/carloscampos2014/agentfiles/issues) com a label `question`.
