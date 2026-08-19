# Guia: Criar uma Skill

## Quando criar uma nova skill

- Você segue o mesmo processo manualmente toda vez (code review, debug, deploy)
- Quer que o agente execute uma tarefa específica de forma padronizada e repetível
- A tarefa tem etapas claras, critérios de qualidade e formato de saída definido
- A tarefa é ocasional — não deve ocupar contexto permanente (use steering para isso)

---

## Método rápido — usar o wizard

```powershell
C:\Dev\agentfiles\scripts\new-skill.ps1 -ProjectPath "C:\Dev\MeuProjeto"
```

O wizard cria a skill em todas as ferramentas simultaneamente.

---

## Método manual — passo a passo

### Passo 1 — Definir a skill

Responda antes de escrever:
- **Qual é a única tarefa que esta skill executa?**
- **Quais são as etapas obrigatórias?** (listar em ordem)
- **Como o resultado deve ser reportado?** (formato de saída)
- **Quais são as keywords que devem ativar esta skill?** (para a `description`)

### Passo 2 — Criar o arquivo Kiro/Claude (pasta com SKILL.md)

```
.kiro/skills/nome-da-skill/SKILL.md
.claude/skills/nome-da-skill/SKILL.md
```

```markdown
---
name: nome-da-skill
description: "O que esta skill faz. Use quando o usuário pede [keyword1], [keyword2], [keyword3]."
---

# Skill: Nome da Skill

## Quando usar
[Condições e keywords que ativam esta skill]

## Processo

### Etapa 1 — [nome]
[O que fazer]

### Etapa 2 — [nome]
[O que fazer]

## Formato de saída
[Template do resultado esperado]

## Proibições
[O que nunca fazer ao executar esta skill]
```

### Passo 3 — Criar para GitHub Copilot e Amazon Q (arquivo único)

```
.github/skills/nome-da-skill.md
.amazonq/skills/nome-da-skill.md
```

Mesmo conteúdo, sem a pasta — arquivo único.

### Passo 4 — Criar para TRAE (versão condensada)

```
.trae/skills/nome-da-skill.md
```

Versão mais curta, sem frontmatter. Foco em etapas e proibições.

---

## Template completo

```markdown
---
name: security-review
description: "Auditoria de segurança de código. Use quando pedir revisão de segurança, OWASP, vulnerabilidades, SQL injection."
---

# Skill: Security Review

## Quando usar

Ativar quando o usuário pede:
- "revise a segurança deste código"
- "verifique vulnerabilidades"
- "auditoria OWASP"
- "tem SQL injection aqui?"

## Processo

### Etapa 1 — Ler antes de analisar
1. Ler o código completo sem julgamento
2. Identificar pontos de entrada de dados externos (parâmetros, body, query string)
3. Identificar operações com banco, filesystem, comandos shell

### Etapa 2 — Verificar OWASP Top 10
- [ ] Injection (SQL, LDAP, NoSQL, OS command)
- [ ] Broken Authentication (sessões, tokens, senhas)
- [ ] Sensitive Data Exposure (logs, respostas, armazenamento)
- [ ] Security Misconfiguration (headers, CORS, defaults)
- [ ] XSS (output não sanitizado em HTML/JS)
- [ ] Secrets expostos (connection strings, tokens, chaves)

### Etapa 3 — Classificar e reportar

## Formato de saída

```
🔒 Security Review — [arquivo/PR]

🔴 Crítico ([N]): [vulnerabilidade] em [linha] | [como corrigir]
🟡 Atenção ([N]): [problema] em [linha] | [mitigação]
🔵 Melhoria ([N]): [sugestão]

Veredicto: ✅ Seguro / 🟡 Atenção / 🔴 Vulnerável
```

## Proibições
- Não modificar código sem instrução explícita — apenas reportar
- Não ignorar problemas menores — listar mesmo os de baixo risco
```

---

## Checklist antes de usar

- [ ] Nome em kebab-case
- [ ] `description` tem keywords que o dev vai usar
- [ ] Processo tem etapas numeradas e acionáveis
- [ ] Formato de saída definido
- [ ] Criada para todas as ferramentas relevantes do projeto
