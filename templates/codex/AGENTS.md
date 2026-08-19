# __PROJECT_NAME__

__PROJECT_DESCRIPTION__

Stack: __STACK_DESCRIPTION__
Repositório: __GITHUB_OWNER__/__GITHUB_REPO__

---

## Contexto do projeto

Este arquivo é lido pelo Codex antes de qualquer tarefa. Ele define as expectativas
do projeto, convenções e comandos que o agente deve seguir em toda sessão.

Para adicionar instruções específicas de subdiretório, crie um `AGENTS.md` dentro
da pasta correspondente. Instruções mais próximas do diretório atual têm precedência.

---

## Comandos do projeto

```bash
# Build
__BUILD_COMMAND__

# Testes
__TEST_COMMAND__

# Lint
__LINT_COMMAND__
```

Sempre rodar build e testes após qualquer modificação de código.
Nunca commitar com build quebrado ou testes falhando.

---

## Padrões de engenharia

- SOLID obrigatório em toda implementação
- Nomes revelam intenção — sem variáveis genéricas (`data`, `temp`, `manager`)
- Métodos com responsabilidade única e menos de 30 linhas
- Result Pattern para erros previsíveis — nunca `throw` para fluxo de negócio
- Sem magic numbers — usar constantes nomeadas
- Sem secrets ou connection strings no código
- Zero warnings — build configurado com warnings como erros
- Testes unitários para toda nova lógica de negócio

---

## Workflow de Git

1. Criar branch a partir do master atualizado: `feature/<descricao>`
2. Nunca commitar diretamente em `main` ou `master`
3. Formato de commit: `tipo(escopo): #N descrição`
   - `feat`, `fix`, `docs`, `refactor`, `tests`, `chore`
4. Push apenas para branches de feature
5. Criar PR via `gh pr create` com `Closes #N`

**Proibido:**
- `git push --force` ou `git push -f`
- `git reset --hard`
- `git push origin main` ou `git push origin master` diretamente
- `rm -rf` em diretórios de código

---

## Arquitetura

Stack e estrutura de pastas em `project-standards.md` (se existir) ou conforme
padrões do projeto descritos no README.

Regra de dependência (Clean Architecture):
- `Domain` → sem dependências externas
- `Application` → depende apenas de `Domain`
- `Infrastructure` → implementa interfaces de `Application`
- `Api/Presentation` → camada fina, delega para `Application`

---

## Comportamento esperado do agente

- Ler o código existente antes de escrever — nunca inventar assinaturas
- Declarar intenção ao mudar comportamento existente
- Rodar build e testes e mostrar output real antes de afirmar "concluído"
- Ao corrigir bug: buscar o mesmo padrão em todo o projeto (Twin Check)
- Fazer briefing e aguardar aprovação para features não triviais (3+ arquivos)
- Uma mudança coesa por commit — não aglomerar mudanças não relacionadas
