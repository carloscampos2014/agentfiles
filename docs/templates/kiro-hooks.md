# Documentação: Hooks Kiro

## guardrails-pre-write.json

**Evento:** `PreToolUse`
**Tipo:** `agent`
**Quando dispara:** Antes de qualquer execução de shell (`execute_pwsh`, `execute_bash`)

**O que verifica:**
- `git push --force` ou `git push -f`
- `git reset --hard`
- `git clean -fd`
- `git push origin main` ou `git push origin master`
- `rm -rf` em diretórios de código
- Sobrescrever arquivos `.env`, `secrets`, `credentials`

**Ação ao detectar:** Bloqueia (instrui o agente a não executar) e explica o problema.

**Como customizar:** Editar o `prompt` do hook para adicionar ou remover padrões proibidos.

---

## build-test-on-stop.json

**Evento:** `Stop`
**Tipo:** `agent`
**Quando dispara:** Ao encerrar cada sessão do agente

**O que faz:** Verifica se houve modificações de código na sessão. Se sim, roda os
comandos de build e teste configurados em `harness-config.json` (`build.command` e
`build.test_command`). Reporta o resultado.

**Dependência:** Requer `harness-config.json` com `build.command` e `build.test_command` preenchidos.

**Como customizar:** Editar `harness-config.json` com os comandos corretos da sua stack.

---

## pre-task-spec-check.json

**Evento:** `PreTaskExec`
**Tipo:** `agent`
**Quando dispara:** Antes de iniciar uma task de spec

**O que faz:**
1. Localiza o `requirements.md` da spec atual em `.kiro/specs/`
2. Lê os critérios de aceite da task que será executada
3. Confirma o escopo exato (o que deve e o que não deve ser modificado)
4. Verifica dependências com tasks anteriores

**Reporta:** Resumo de 3-5 linhas com o que a task deve entregar.

**Como customizar:** Alterar o `prompt` para adicionar verificações específicas do projeto.

---

## validate-task-completion.json

**Evento:** `PostTaskExec`
**Tipo:** `agent`
**Quando dispara:** Após concluir uma task de spec

**O que faz:**
1. Lê os critérios de aceite da task concluída
2. Verifica se há evidência de implementação para cada critério
3. Verifica se build e testes estão passando
4. Registra o resultado em `.kiro/quality/history.json` (se `quality_reporting` ativo)

**Formato de saída:**
```
✅ Task N — Validação
Critérios atendidos: N/total
Build: ✅ | Testes: ✅ N passando
```

---

## session-summary.json

**Evento:** `Stop`
**Tipo:** `agent`
**Quando dispara:** Ao encerrar cada sessão

**O que faz:** Gera um resumo da sessão e salva em `.kiro/knowledge/sessions/YYYY-MM-DD-HH-resumo.md`

**Conteúdo do resumo:**
- O que foi feito (lista de implementações)
- Arquivos modificados
- Decisões tomadas com rationale
- Problemas encontrados e soluções
- Estado atual e próximos passos
- Conhecimento a ser capturado

**Não cria arquivo** se a sessão foi apenas perguntas sem código.

---

## missing-test-alert.json

**Evento:** `PostFileCreate`
**Tipo:** `agent`
**Matcher:** `src\\\\.*\\.(cs|ts|tsx|py|java|go|rb)$`
**Quando dispara:** Ao criar arquivo de implementação em `src/`

**O que faz:** Verifica se existe arquivo de teste correspondente em `tests/` (ou `__tests__/`, `spec/`).
Se não existe, alerta o usuário com o nome do arquivo criado e o caminho esperado do teste.

**Não alerta para:** Interfaces, DTOs, enums, configurações, recursos, barrel files, migrações.

**Como customizar:** Ajustar o `matcher` para o padrão de pastas do projeto.
