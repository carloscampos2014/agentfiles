## Descrição

<!-- Descreva o que este PR adiciona ou modifica -->

## Tipo de mudança

- [ ] Bug fix (correção que não quebra compatibilidade)
- [ ] Novo template (steering, hook, skill, agent)
- [ ] Nova ferramenta suportada
- [ ] Melhoria em template existente
- [ ] Script novo ou melhorado
- [ ] Documentação

## Ferramentas afetadas

- [ ] Kiro IDE
- [ ] Claude Code
- [ ] GitHub Copilot
- [ ] Amazon Q
- [ ] OpenAI Codex
- [ ] Gemini CLI / Qwen Code
- [ ] TRAE IDE

## Checklist

- [ ] JSON dos hooks validados (`Get-Content hook.json | ConvertFrom-Json`)
- [ ] Sem secrets ou valores reais nos templates (usar placeholders)
- [ ] Documentação atualizada se necessário (`docs/templates/` ou `docs/ferramentas/`)
- [ ] `docs/INDEX.md` atualizado se adicionou novo arquivo
- [ ] Para nova skill: criada para todas as ferramentas relevantes
- [ ] Para novo agent: frontmatter correto em cada ferramenta (campo `model`)
- [ ] CHANGELOG.md atualizado

## Issues relacionadas

Closes #
