<#
.SYNOPSIS
    Wizard para criar um novo agent especializado para Claude Code, GitHub Copilot e Amazon Q.

.PARAMETER ProjectPath
    Caminho do projeto. Padrão: diretório atual.

.EXAMPLE
    .\new-agent.ps1 -ProjectPath "C:\Dev\MeuProjeto"
#>
param(
    [string]$ProjectPath = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Title([string]$msg) { Write-Host "`n  $msg" -ForegroundColor Cyan }
function Write-Ok([string]$msg)    { Write-Host "    ✅ $msg" -ForegroundColor Green }
function Write-Skip([string]$msg)  { Write-Host "    ⏭  $msg" -ForegroundColor DarkGray }
function Ask([string]$prompt, [string]$default = "") {
    if ($default) {
        Write-Host "  $prompt " -NoNewline -ForegroundColor White
        Write-Host "[$default]" -NoNewline -ForegroundColor DarkGray
        Write-Host ": " -NoNewline
    } else {
        Write-Host "  ${prompt}: " -NoNewline -ForegroundColor White
    }
    $value = Read-Host
    if ([string]::IsNullOrWhiteSpace($value) -and $default) { return $default }
    return $value
}
function Choose([string]$prompt, [string[]]$options, [int]$default = 0) {
    Write-Host "`n  $prompt" -ForegroundColor White
    for ($i = 0; $i -lt $options.Length; $i++) {
        $m = if ($i -eq $default) { ">" } else { " " }
        $c = if ($i -eq $default) { "Cyan" } else { "Gray" }
        Write-Host "  $m $($i+1). $($options[$i])" -ForegroundColor $c
    }
    Write-Host "  Escolha [$($default+1)]: " -NoNewline -ForegroundColor White
    $choice = Read-Host
    if ([string]::IsNullOrWhiteSpace($choice)) { return $default }
    $idx = [int]$choice - 1
    if ($idx -lt 0 -or $idx -ge $options.Length) { return $default }
    return $idx
}

Write-Host ""
Write-Host "  ╔════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║   agentfiles · new-agent       ║" -ForegroundColor Magenta
Write-Host "  ╚════════════════════════════════════╝" -ForegroundColor Magenta

# ─── Coleta ───────────────────────────────────────────────────────────────────

Write-Title "1. Identificação"
$name = Ask "Nome do agent (kebab-case, ex: devsecops-engineer)"
while ($name -notmatch '^[a-z0-9][a-z0-9-]*$') {
    Write-Host "  ⚠  Use apenas letras minúsculas, números e hífens." -ForegroundColor Yellow
    $name = Ask "Nome do agent (kebab-case)"
}

$role        = Ask "Cargo/papel (ex: Engenheiro DevSecOps)"
$domain      = Ask "Domínio de especialidade (ex: segurança, testes de carga)"
$useCases    = Ask "Casos de uso — quando invocar (ex: revisão de segurança, auditoria)"
$description = "$role especializado em $domain. Use para $useCases."

Write-Title "2. Ferramentas que o agent pode usar"
Write-Host "  Selecione todas que se aplicam (recomendado: mínimo necessário)" -ForegroundColor DarkGray
$allTools = @("Read","Write","Edit","Bash","Grep","Glob","WebSearch")
$selectedTools = @("Read","Grep","Glob")  # padrão conservador

Write-Host ""
foreach ($t in $allTools) {
    $included = $t -in $selectedTools
    $marker   = if ($included) { "[x]" } else { "[ ]" }
    $color    = if ($included) { "Cyan" } else { "Gray" }
    Write-Host "  $marker $t" -ForegroundColor $color
}
Write-Host ""
Write-Host "  Digite ferramentas separadas por vírgula " -NoNewline -ForegroundColor White
Write-Host "[Read,Grep,Glob]" -NoNewline -ForegroundColor DarkGray
Write-Host ": " -NoNewline
$toolsInput = Read-Host
if (-not [string]::IsNullOrWhiteSpace($toolsInput)) {
    $selectedTools = $toolsInput -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -in $allTools }
}
$toolsStr = $selectedTools -join ", "

# ─── Gerar conteúdo do agent ──────────────────────────────────────────────────

$agentBody = @"
Você é um $role especializado em $domain.

## FILOSOFIA

``````
✅ [Princípio 1 — específico deste domínio]
✅ [Princípio 2]
✅ [Princípio 3]

❌ [Anti-pattern 1]
❌ [Anti-pattern 2]
``````

## PROCESSO

### Antes de começar
1. Ler o contexto relevante (código, docs, configurações)
2. Identificar o escopo exato da tarefa
3. Verificar padrões existentes no projeto

### Durante a execução
- [Etapa específica do domínio]
- Seguir as regras definidas nas rules do projeto
- Documentar decisões importantes

### Ao concluir
- Verificar que o trabalho está completo e correto
- Reportar com evidência observada (não inferida)
- Listar o que foi feito e o que ficou pendente

## CHECKLIST DE QUALIDADE

- [ ] [Critério específico 1]
- [ ] [Critério específico 2]
- [ ] [Critério específico 3]

## FORMATO DE RESPOSTA

``````
[Ícone] [Tipo de resultado] — [escopo]
[Resultado principal]
[Evidência]
[Próximos passos]
``````
"@

# ─── Detectar ferramentas disponíveis ────────────────────────────────────────

$hasClaude  = Test-Path (Join-Path $ProjectPath ".claude\agents")
$hasCopilot = Test-Path (Join-Path $ProjectPath ".github\agents")
$hasAmazonQ = Test-Path (Join-Path $ProjectPath ".amazonq\rules")

Write-Title "3. Criando agent"

# Claude Code
if ($hasClaude) {
    $fm = "---`nname: $name`ndescription: `"$description`"`ntools: $toolsStr`nmodel: sonnet`n---`n`n"
    Set-Content -Path (Join-Path $ProjectPath ".claude\agents\$name.md") -Value ($fm + $agentBody) -Encoding UTF8
    Write-Ok "Claude Code: .claude/agents/$name.md"
} else { Write-Skip "Claude Code (pasta agents/ não encontrada)" }

# GitHub Copilot
if ($hasCopilot) {
    $fm = "---`nname: $name`ndescription: `"$description`"`ntools: $toolsStr`n---`n`n"
    Set-Content -Path (Join-Path $ProjectPath ".github\agents\$name.md") -Value ($fm + $agentBody) -Encoding UTF8
    Write-Ok "GitHub Copilot: .github/agents/$name.md"
} else { Write-Skip "GitHub Copilot (pasta agents/ não encontrada)" }

# Amazon Q
if ($hasAmazonQ) {
    $fm = "---`nname: $name`ndescription: `"$description`"`ntools: $toolsStr`nmodel: claude-sonnet-4-5-20250929`n---`n`n"
    Set-Content -Path (Join-Path $ProjectPath ".amazonq\rules\$name.md") -Value ($fm + $agentBody) -Encoding UTF8
    Write-Ok "Amazon Q: .amazonq/rules/$name.md"
} else { Write-Skip "Amazon Q (pasta rules/ não encontrada)" }

Write-Host ""
Write-Host "  ✅ Agent '$name' criado" -ForegroundColor Green
Write-Host ""
Write-Host "  Próximos passos:" -ForegroundColor White
Write-Host "  1. Edite o conteúdo do agent com a especialização real:" -ForegroundColor Yellow
if ($hasClaude) {
    Write-Host "     notepad `"$(Join-Path $ProjectPath ".claude\agents\$name.md")`"" -ForegroundColor DarkGray
}
Write-Host "  2. Copie o corpo para as demais ferramentas (ou use sync-tools.ps1)" -ForegroundColor Yellow
Write-Host "  3. Invoke no Claude Code com: @$name" -ForegroundColor Yellow
Write-Host ""
