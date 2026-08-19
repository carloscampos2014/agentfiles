# Guia: Criar um Agent

## Quando criar um novo agent

- Você tem um domínio completo que precisa de especialização (segurança, DBA, DevOps)
- Quer delegar uma área inteira para uma "persona" especializada
- O domínio tem padrões, exemplos de código e checklists próprios
- É mais especialista que generalista — precisa de foco

Se é uma tarefa pontual → use uma **skill**. Se é comportamento permanente → use um **steering**.

---

## Método rápido — usar o wizard

```powershell
C:\Dev\agentfiles\scripts\new-agent.ps1 -ProjectPath "C:\Dev\MeuProjeto"
```

O wizard cria o agent para Claude Code, GitHub Copilot e Amazon Q com o formato correto de cada um.

---

## Método manual — passo a passo

### Passo 1 — Definir a persona

Responda:
- **Qual é o papel deste agent?** (DevSecOps Engineer, Database Administrator, etc.)
- **Qual é sua especialidade técnica?** (o que ele sabe que outros não sabem)
- **Quais ferramentas precisa?** (Read/Write/Bash/Grep/Glob/WebSearch)
- **Em que situações deve ser invocado?** (palavras-chave para a `description`)

### Passo 2 — Criar para Claude Code (`.claude/agents/`)

```markdown
---
name: nome-kebab-case
description: "Especialidade. Use para [casos de uso 1], [caso 2], [caso 3]."
tools: Read, Write, Bash, Grep, Glob, WebSearch
model: sonnet
---

Você é um [cargo] sênior especializado em [domínio].

## FILOSOFIA
[Lista ✅/❌ de princípios]

## PROCESSO
[Etapas que este agent segue para cada tipo de tarefa]

## PADRÕES
[Exemplos de código, tabelas, templates específicos do domínio]

## CHECKLIST ANTES DE ENTREGAR
[Critérios que o agent verifica antes de reportar conclusão]

## FORMATO DE RESPOSTA
[Template de como reportar resultados]
```

### Passo 3 — Criar para GitHub Copilot (`.github/agents/`)

Idêntico ao Claude Code, **sem** o campo `model`:

```markdown
---
name: nome-kebab-case
description: "Especialidade. Use para [casos]."
tools: Read, Write, Edit, Bash, Grep, Glob, WebSearch
---
[mesmo corpo]
```

### Passo 4 — Criar para Amazon Q (`.amazonq/rules/`)

Idêntico ao Claude Code, com `model` completo:

```markdown
---
name: nome-kebab-case
description: "Especialidade. Use para [casos]."
tools: Read, Write, Edit, Bash, Grep, Glob, WebSearch
model: claude-sonnet-4-5-20250929
---
[mesmo corpo]
```

---

## Exemplo completo — DevSecOps Engineer

```markdown
---
name: devsecops-engineer
description: "Engenheiro DevSecOps — segurança de código, CI/CD seguro, secrets management, OWASP. Use para revisão de segurança, pipeline, vulnerabilidades."
tools: Read, Bash, Grep, Glob, WebSearch
model: sonnet
---

Você é um engenheiro DevSecOps sênior especializado em segurança por design.

## FILOSOFIA

```
✅ Segurança por design — nunca como afterthought
✅ Menor superfície de ataque — menos é mais
✅ Defense in depth — múltiplas camadas de proteção
✅ Princípio do menor privilégio — cada componente acessa só o necessário
❌ Segurança por obscuridade — esconder não é proteger
❌ Secrets no código ou logs
❌ Dependências sem verificação de CVE
```

## CHECKLIST DE SEGURANÇA

- [ ] Inputs validados e sanitizados em todo ponto de entrada
- [ ] Queries parametrizadas — zero concatenação com input
- [ ] Secrets em variáveis de ambiente, nunca no código
- [ ] Dependências auditadas (npm audit / dotnet list package --vulnerable)
- [ ] Headers de segurança configurados (CSP, HSTS, X-Frame-Options)
- [ ] Logs sem dados sensíveis (PII, tokens, senhas)
- [ ] Auth e authz em toda rota protegida

## FORMATO DE RESPOSTA

```
🔒 Security Review — [escopo]
Crítico: [N] | Atenção: [N] | Info: [N]

🔴 [vulnerabilidade] — [arquivo:linha]
   Impacto: [descrição]
   Correção: [como resolver]
```
```

---

## Diferença de ferramentas entre agents

| Ferramenta | Quando dar |
|------------|-----------|
| `Read` | Sempre — para ler código e docs |
| `Write` | Quando o agent deve criar/modificar arquivos |
| `Bash` | Para rodar comandos (build, testes, ferramentas CLI) |
| `Grep` | Para busca de padrões no projeto |
| `Glob` | Para listar arquivos por padrão |
| `WebSearch` | Para buscar documentação atualizada |
| `Edit` | Para modificações pontuais (Amazon Q e Copilot) |

Um agent de **review/análise** não precisa de `Write`. Um agent de **implementação** sim.

---

## Checklist antes de commitar

- [ ] Nome em kebab-case
- [ ] `description` tem keywords que ativam o agent
- [ ] `tools` é o mínimo necessário (não dar mais do que precisa)
- [ ] `model` está correto (Claude: `sonnet`, Amazon Q: `claude-sonnet-4-5-20250929`)
- [ ] Corpo tem filosofia, processo, exemplos e checklist
- [ ] Criado para todas as ferramentas do projeto
