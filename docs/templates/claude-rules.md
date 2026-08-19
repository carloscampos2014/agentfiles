# Documentação: Rules Claude Code

## engineering-standards.md

**O que define:** Padrões universais de engenharia — SOLID, Clean Code, segurança, testes.

Conteúdo: SOLID com exemplos ✅/❌, Clean Code (naming, tamanho de método, magic numbers,
deep nesting), separação de responsabilidades por camada, requisitos de segurança, regras gerais.

**Quando customizar:** Adicionar restrições específicas da empresa (libs proibidas, padrões
de nomenclatura corporativos).

---

## workflow.md

**O que define:** Ciclo completo de desenvolvimento — branch, briefing, aprovação, commits, PR.

Conteúdo: Diagrama do ciclo completo, comandos git, critérios de briefing obrigatório,
formato de commit, template de PR, limpeza pós-merge.

**Quando customizar:** Substituir `master` por `main` se o projeto usa main, ajustar padrão
de nome de branch.

---

## senior-developer.md (rule)

**O que define:** Persona e processo do desenvolvedor sênior — implementação, nomenclatura,
patterns de código com exemplos C# e TypeScript.

Conteúdo: Filosofia ✅/❌, processo antes/durante/após implementar, tabela de nomenclatura
por linguagem, Result Pattern com exemplos, Service Layer, Repository Pattern segregado,
mapeamento manual, checklist antes de entregar, formato de resposta.

**Diferença do agent:** A rule é carregada automaticamente. O agent `@senior-developer` é
invocado explicitamente e tem mais contexto isolado.

---

## solutions-architect.md (rule)

**O que define:** Persona e padrões do arquiteto — Clean Architecture, nomenclatura de projetos,
estrutura de diretórios, quando usar cada abordagem, diagramas, ADR template, checklist.

Conteúdo: Filosofia arquitetural, nomenclatura `NomeProjeto.NomeCamada`, estrutura de pastas
completa, tabela de quando usar Layered/CQRS/DDD/Microserviços, 3 tipos de diagramas Mermaid,
template ADR completo, checklist arquitetural.

---

## 01-result-pattern.md

**O que define:** Result Pattern obrigatório — implementação C# e TypeScript, NotificationContext.

Conteúdo: Implementação genérica de `Result<T>` em C#, equivalente TypeScript, NotificationContext
para acumular todos os erros antes de retornar, mapeamento Controller → HTTP, regras.

---

## 02-logging-observability.md

**O que define:** Logging estruturado, rotação e expurgo, auditoria, GlobalExceptionMiddleware.

Conteúdo: Níveis de log, FileLoggingService completo com Timer de expurgo, equivalente TypeScript,
operações que geram auditoria obrigatória, GlobalExceptionMiddleware, regras de proibição.

---

## 03-testing-requirements.md

**O que define:** Cobertura mínima por camada, nomenclatura AAA, frameworks por stack.

Conteúdo: Tabela de cobertura (Domain 95%, Application 80%...), formato de nome obrigatório,
estrutura AAA com exemplos, stack .NET (xUnit + FluentAssertions + NSubstitute + Testcontainers),
stack TypeScript (Jest), proibições.

---

## 04-database-best-practices.md

**O que define:** Práticas obrigatórias de banco — índices, soft delete, auditoria, paginação.

Conteúdo: Regras fundamentais, estrutura de tabela padrão com SQL, trigger de auditoria
PostgreSQL, query paginada com Dapper, prevenção de N+1, padrão de migration, connection
string via variável de ambiente.
