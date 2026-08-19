# Política de Segurança

## Versões suportadas

| Versão | Suporte |
|--------|---------|
| 1.x | ✅ Ativa |

---

## Reportar uma vulnerabilidade

Se você encontrou um problema de segurança nos templates ou scripts deste repositório:

1. **Não abra uma issue pública** — vulnerabilidades de segurança devem ser reportadas de forma privada
2. Envie um e-mail para o mantenedor descrevendo:
   - O arquivo/template afetado
   - A natureza do problema
   - Passos para reproduzir (se aplicável)
   - Impacto potencial

---

## Escopo de segurança

Este repositório contém **templates de configuração** para agentes AI. Os principais riscos a considerar:

### Secrets nos templates

Nenhum template deve conter valores reais de tokens, senhas ou connection strings.
Todos os valores sensíveis usam placeholders (`${env:NOME_DA_VAR}`) ou `__PLACEHOLDER__`.

Se encontrar um template com secret real commitado, reporte imediatamente.

### Scripts PowerShell

Os scripts em `scripts/` são executados localmente na máquina do desenvolvedor.
Eles não fazem chamadas de rede (exceto o `bootstrap.ps1` que baixa pacotes npm via `npx`
ao configurar MCPs — o que é esperado e documentado).

### MCPs e servidores externos

Os servidores MCP configurados nos templates se comunicam com serviços externos
(GitHub, Figma, etc.). Revisar quais servidores estão habilitados e quais permissões
cada um requer antes de usar em projetos sensíveis.

---

## Boas práticas ao usar os templates

- Nunca commitar `.env`, `secrets`, `credentials` ou arquivos de chave
- Usar `${env:NOME}` para todas as variáveis sensíveis no mcp.json
- Adicionar `settings.local.json` ao `.gitignore` do projeto
- Revisar o `.gitignore` gerado pelo bootstrap antes do primeiro commit
