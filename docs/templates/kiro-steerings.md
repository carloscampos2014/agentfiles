# Documentação: Steerings Kiro

## harness-output-formatter.md

**Inclusion:** `always`
**O que define:** Como formatar respostas no chat — o que vai no chat vs. em arquivo.

**Regra principal:** Chat = decisões, resumos e próximos passos. Arquivos = detalhes, código extenso.

**Formatos definidos:**
- Implementação de código: template com ✅, localização, decisões, testes
- Code review: template com Risk Score e severidades
- Build/testes: template com 🔨 e 🧪
- Conclusão de task: template com ✅ e próxima task

**Quando customizar:** Se quiser adicionar formato específico para resposta de um domínio
da sua stack (ex: template para resultados de migração de banco).

---

## harness-anti-patterns.md

**Inclusion:** `always`
**O que define:** Comportamentos proibidos do agente — o que nunca fazer.

**Anti-patterns cobertos (AP-01 a AP-12):**
- AP-01: Pular pesquisa prévia
- AP-02: Gerar spec sem interação
- AP-03: Implementar feature complexa sem spec
- AP-04: Workaround em vez de fix
- AP-05: Afirmar "concluído" sem evidência
- AP-06: Responder a própria pergunta
- AP-07: Re-analisar código já analisado
- AP-08: Commitar código que não compila
- AP-09: Ignorar hooks que falharam
- AP-10: Scope creep silencioso
- AP-11: Verificação teatral
- AP-12: Assumir sem verificar

**Quando customizar:** Adicionar anti-patterns específicos da sua stack ou processo.

---

## harness-agent-router.md

**Inclusion:** `always`
**O que define:** Como classificar pedidos e carregar contexto mínimo necessário.

**Tabela de roteamento:** Feature nova, bug fix, refactoring, code review, spec/planejamento,
pergunta técnica, git/PR, retomar trabalho, documentação → cada um com contexto a carregar.

**Critério de trivialidade:** Um arquivo, < 10 linhas, sem lógica nova → responder diretamente.

**Quando customizar:** Adicionar tipos de pedido específicos do seu domínio (ex: "análise de
performance" → carregar steering de profiling).

---

## harness-one-question.md

**Inclusion:** `always`
**O que define:** Protocolo de uma pergunta por vez com opções numeradas.

**Regra:** Nunca mais de uma pergunta por mensagem. Quando precisar de múltiplas informações,
fazer a mais bloqueante primeiro.

**Formato:** Contexto → pergunta → opções numeradas → recomendação.

**Quando customizar:** Raramente — é universal. Só se quiser alterar o formato das opções.

---

## harness-verification-report.md

**Inclusion:** `auto`
**O que define:** Como reportar conclusão com evidência observada.

**Checklist antes de reportar:** Build passou? Testes passando? Comportamento verificado?
Arquivos fora do escopo modificados?

**Twin Check:** Ao corrigir bug, buscar o mesmo padrão em todo o projeto.

**Hard Bound:** Após 3 ciclos fix-verify sem progresso, parar e reportar ao usuário.

---

## method-development.md

**Inclusion:** `manual` — ativar com `#method-development`
**O que define:** Loop estruturado de 7 passos para implementação.

**Passos:**
- Gate de trivialidade
- Step 0: Classificar o pedido
- Step 1: Definir "done"
- Step 2: Coletar evidência (leitura, não suposição)
- Step 3: Decidir e comprometer
- Step 4: Implementar (com Intent Gate, Recall Gate, proibições)
- Step 5: Verificar por observação (+ Twin Check)
- Step 6: Reportar outcome-first

**14 failure modes** documentados com prevenção.

**Quando usar:** Ativar para features complexas ou quando o agente está iterando sem progresso.

---

## git-commits.md

**Inclusion:** `auto`
**O que define:** Conventional Commits, granularidade por task, sequência segura e proibições.

**Formato:** `tipo(escopo): #N descrição concisa`

**Proibições:** `git add .`, commitar com build quebrado, secrets no commit, `--no-verify`,
`--amend` em commits publicados, `push --force`.

**Quando customizar:** Se o projeto usa formato diferente de mensagem de commit.
