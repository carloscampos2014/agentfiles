# Documentação: Agents e Skills

## Agents

### senior-developer

**Disponível em:** Claude Code (`agents/`), GitHub Copilot (`agents/`), Amazon Q (`rules/`)
**Invocar:** `@senior-developer`

**Especialidade:** Implementação de features, correção de bugs, refactoring.

**Conteúdo:** Filosofia ✅/❌ (SOLID, Result Pattern, zero warnings, menor mudança),
processo completo antes/durante/ao concluir, tabela de nomenclatura C#/TS/Python,
exemplos de Result Pattern, Service Layer, Repository Pattern segregado, mapeamento
manual, checklist de 8 itens, formato de resposta com INTENT/TWINS/PENDING.

**Quando usar:** Qualquer tarefa que envolva escrever ou modificar código.

---

### solutions-architect

**Disponível em:** Claude Code, GitHub Copilot, Amazon Q
**Invocar:** `@solutions-architect`

**Especialidade:** Arquitetura, ADRs, decisões técnicas, diagramas, design de sistemas.

**Conteúdo:** Filosofia arquitetural, Clean Architecture com nomenclatura e estrutura completa,
tabela quando usar Layered/CQRS/DDD/Microserviços, 3 tipos de diagramas Mermaid (dependências,
sequência, ER), template ADR completo com justificativa e consequências, checklist arquitetural.

**Quando usar:** Decisões de design, escolha de tecnologia, planejamento de feature complexa.

---

### qa-engineer

**Disponível em:** Claude Code, GitHub Copilot, Amazon Q
**Invocar:** `@qa-engineer`

**Especialidade:** Estratégia de testes, cobertura, validação de critérios de aceite.

**Conteúdo:** Filosofia de qualidade, pirâmide de testes com tabela, cobertura mínima por camada,
nomenclatura `Metodo_Cenario_Resultado`, estrutura AAA com exemplos, cenários obrigatórios
por categoria (validação, regras, persistência, segurança), Testcontainers completo,
como mapear critérios de aceite para testes, formato de relatório de cobertura.

**Quando usar:** Planejar testes, revisar cobertura, validar que spec foi implementada.

---

### business-analyst

**Disponível em:** Claude Code, GitHub Copilot, Amazon Q
**Invocar:** `@business-analyst`

**Especialidade:** Elicitação de requisitos, user stories, priorização, documentação.

**Conteúdo:** Critério INVEST para user stories, template completo de US com critérios
de aceite, priorização MoSCoW, técnicas de quebra de stories grandes, template de
documento de requisitos, perguntas de elicitação por categoria (problema, solução,
dados, volumes), template de tabela de regras de negócio.

**Quando usar:** Criar specs, detalhar requisitos, discutir escopo de feature.

---

## Skills

### code-review

**Disponível em:** Kiro, Claude Code, GitHub Copilot, Amazon Q, TRAE
**Invocar:** `/code-review` ou "revisar código"

**O que faz:** Revisão estruturada com checklist por categoria e classificação por severidade.

**Categorias do checklist:** Arquitetura (Dependency Rule, SRP, Result Pattern), Clean Code
(nomes, tamanho, magic numbers, nesting), Segurança (secrets, queries, validação, tenant),
Testes (cobertura, nomenclatura, caminhos de erro), Performance (N+1, paginação, async).

**Severidades:** 🔴 Crítico (bloquear), 🟡 Atenção (corrigir antes merge), 🔵 Sugestão, ✅ Elogio.

---

### spec-driven-development

**Disponível em:** Kiro, Claude Code, GitHub Copilot, Amazon Q, TRAE
**Invocar:** `/spec` ou "criar spec"

**O que faz:** Guia o processo requirements → design → tasks com aprovação em cada etapa.

**Templates incluídos:** requirements.md (user stories + CAs + RNs), design.md (componentes +
diagramas + decisões), tasks.md (tasks priorizadas com critérios e estimativas).

**Regra principal:** Nunca implementar sem requirements e design aprovados.

---

### systematic-debugging

**Disponível em:** Kiro, Claude Code, GitHub Copilot, Amazon Q, TRAE
**Invocar:** `/debug` ou "investigar bug"

**O que faz:** Diagnóstico estruturado em 6 etapas do problema à correção verificada.

**Etapas:** Definir precisamente → Reproduzir isoladamente → Formular hipóteses → Testar
uma por vez → Aplicar correção mínima → Twin Check.

**Hard bound:** 3 hipóteses sem progresso → reportar ao usuário.

**Tipos cobertos:** Lógica (resultado errado), concorrência, performance, intermitente.

---

### architecture-design

**Disponível em:** Kiro, Claude Code, GitHub Copilot, Amazon Q, TRAE
**Invocar:** `/arch` ou "decisão de arquitetura"

**O que faz:** Processo estruturado para decisões arquiteturais com alternativas, ADR e checklist.

**Tabela de padrões:** Layered, CQRS, DDD, Event-Driven, Microserviços — quando usar e não usar.

**Inclui:** Diagramas C4 Level 1/2, sequência de use case, template ADR completo, checklist
de 7 critérios para validar a decisão.
