<#
.SYNOPSIS
    Atualiza o harness de um projeto comparando com os templates do agentfiles.
    So sobrescreve arquivos que vieram do harness e que estao diferentes do template.
    Nunca toca em arquivos especificos do projeto.

.PARAMETER ProjectPath
    Caminho do projeto a atualizar. Padrao: diretorio atual.

.PARAMETER WhatIf
    Mostra o que seria atualizado sem fazer nenhuma alteracao.

.EXAMPLE
    .\update-harness.ps1 -ProjectPath "C:\Dev\MeuProjeto"
    .\update-harness.ps1 -ProjectPath "C:\Dev\MeuProjeto" -WhatIf
#>
param(
    [string]$ProjectPath = (Get-Location).Path,
    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$HarnessRoot  = Split-Path -Parent $PSScriptRoot
$TemplatesDir = Join-Path $HarnessRoot "templates"
$ProjectDir   = $ProjectPath.TrimEnd('\', '/')

# Arquivos que pertencem ao projeto (nunca atualizar)
$ProjectOwnedFiles = @(
    ".kiro\harness-config.json",
    ".kiro\settings\mcp.json",
    ".kiro\steering\project-standards.md",
    ".kiro\knowledge\INDEX.md",
    ".kiro\quality\history.json",
    ".kiro\quality\tech-debt.json",
    ".mcp.json",
    "AGENTS.md",
    "GEMINI.md",
    "QWEN.md"
)

$updated = [System.Collections.Generic.List[string]]::new()
$skipped = [System.Collections.Generic.List[string]]::new()
$missing = [System.Collections.Generic.List[string]]::new()

function Get-NormalizedHash([string]$path) {
    $content = Get-Content $path -Raw -Encoding UTF8
    $content = $content -replace "`r`n", "`n" -replace "`r", "`n"
    $bytes   = [System.Text.Encoding]::UTF8.GetBytes($content)
    $hash    = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
    return [System.BitConverter]::ToString($hash) -replace '-', ''
}

function Compare-AndUpdate([string]$templatePath, [string]$projectRelPath) {
    $projectFull = Join-Path $ProjectDir $projectRelPath

    if ($ProjectOwnedFiles -contains $projectRelPath) {
        return
    }

    if (-not (Test-Path $projectFull)) {
        $script:missing.Add($projectRelPath)
        return
    }

    $hashTemplate = Get-NormalizedHash $templatePath
    $hashProject  = Get-NormalizedHash $projectFull

    if ($hashTemplate -eq $hashProject) {
        $script:skipped.Add($projectRelPath)
        return
    }

    if ($WhatIf) {
        $script:updated.Add("[WhatIf] $projectRelPath")
    } else {
        $content = Get-Content $templatePath -Raw -Encoding UTF8
        Set-Content -Path $projectFull -Value $content -Encoding UTF8 -NoNewline
        $script:updated.Add($projectRelPath)
    }
}

# Header
Write-Host ""
Write-Host "  agentfiles - update-harness" -ForegroundColor Magenta
Write-Host ""
Write-Host "  Projeto : $ProjectDir" -ForegroundColor White
if ($WhatIf) {
    Write-Host "  Modo    : WhatIf (simulacao - nada sera alterado)" -ForegroundColor Yellow
}
Write-Host ""

if (-not (Test-Path $ProjectDir)) {
    Write-Host "  ERRO: Projeto nao encontrado: $ProjectDir" -ForegroundColor Red
    exit 1
}

# Detectar ferramentas
$hasKiro    = Test-Path (Join-Path $ProjectDir ".kiro")
$hasClaude  = Test-Path (Join-Path $ProjectDir ".claude")
$hasCopilot = Test-Path (Join-Path $ProjectDir ".github")
$hasAmazonQ = Test-Path (Join-Path $ProjectDir ".amazonq")
$hasTrae    = Test-Path (Join-Path $ProjectDir ".trae")

# Kiro
if ($hasKiro) {
    Write-Host "  -- Kiro IDE" -ForegroundColor Cyan

    $steeringSrc = Join-Path $TemplatesDir ".kiro\steering"
    Get-ChildItem -Path $steeringSrc -Filter "*.md" | ForEach-Object {
        Compare-AndUpdate $_.FullName ".kiro\steering\$($_.Name)"
    }

    $hooksSrc = Join-Path $TemplatesDir ".kiro\hooks"
    Get-ChildItem -Path $hooksSrc -Filter "*.json" | ForEach-Object {
        Compare-AndUpdate $_.FullName ".kiro\hooks\$($_.Name)"
    }
}

# Claude Code
if ($hasClaude) {
    Write-Host "  -- Claude Code" -ForegroundColor Cyan

    $rulesSrc = Join-Path $TemplatesDir ".claude\rules"
    Get-ChildItem -Path $rulesSrc -Filter "*.md" | ForEach-Object {
        Compare-AndUpdate $_.FullName ".claude\rules\$($_.Name)"
    }
}

# GitHub Copilot
if ($hasCopilot) {
    Write-Host "  -- GitHub Copilot" -ForegroundColor Cyan

    $instrSrc = Join-Path $TemplatesDir ".github\instructions"
    if (Test-Path $instrSrc) {
        Get-ChildItem -Path $instrSrc -Filter "*.md" | ForEach-Object {
            Compare-AndUpdate $_.FullName ".github\instructions\$($_.Name)"
        }
    }
}

# Amazon Q
if ($hasAmazonQ) {
    Write-Host "  -- Amazon Q" -ForegroundColor Cyan

    $rulesSrc = Join-Path $TemplatesDir ".amazonq\rules"
    Get-ChildItem -Path $rulesSrc -Filter "*.md" | ForEach-Object {
        Compare-AndUpdate $_.FullName ".amazonq\rules\$($_.Name)"
    }
}

# TRAE
if ($hasTrae) {
    Write-Host "  -- TRAE IDE" -ForegroundColor Cyan

    $rulesSrc = Join-Path $TemplatesDir ".trae\rules"
    Get-ChildItem -Path $rulesSrc -Filter "*.md" | ForEach-Object {
        Compare-AndUpdate $_.FullName ".trae\rules\$($_.Name)"
    }
}

# Resumo
Write-Host ""
Write-Host "  ============================================" -ForegroundColor White
Write-Host "  Resultado" -ForegroundColor White
Write-Host "  ============================================" -ForegroundColor White
Write-Host ""

if ($updated.Count -gt 0) {
    $label = if ($WhatIf) { "Seriam atualizados ($($updated.Count))" } else { "Atualizados ($($updated.Count))" }
    Write-Host "  OK $label" -ForegroundColor Green
    $updated | ForEach-Object { Write-Host "     * $_" -ForegroundColor Green }
    Write-Host ""
}

if ($missing.Count -gt 0) {
    Write-Host "  AUSENTES no projeto ($($missing.Count)) - rode bootstrap para adicionar:" -ForegroundColor Cyan
    $missing | ForEach-Object { Write-Host "     * $_" -ForegroundColor Cyan }
    Write-Host ""
}

if ($skipped.Count -gt 0) {
    Write-Host "  Sem alteracoes: $($skipped.Count) arquivos" -ForegroundColor DarkGray
    Write-Host ""
}

if ($updated.Count -eq 0 -and $missing.Count -eq 0) {
    Write-Host "  Projeto ja esta atualizado com o harness." -ForegroundColor Green
    Write-Host ""
}

if ($WhatIf -and $updated.Count -gt 0) {
    Write-Host "  Rode sem -WhatIf para aplicar as atualizacoes." -ForegroundColor Yellow
    Write-Host ""
}
