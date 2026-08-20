<#
.SYNOPSIS
    Valida se o harness de um projeto está completo e atualizado.
    Verifica arquivos esperados, placeholders não substituídos e JSON inválido.

.PARAMETER ProjectPath
    Caminho do projeto a validar. Padrão: diretório atual.

.PARAMETER Fix
    Tentar corrigir problemas simples automaticamente (como criar pastas ausentes).

.EXAMPLE
    .\validate-harness.ps1 -ProjectPath "C:\Dev\MeuProjeto"
    .\validate-harness.ps1 -ProjectPath "C:\Dev\MeuProjeto" -Fix
#>
param(
    [string]$ProjectPath = (Get-Location).Path,
    [switch]$Fix
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$errors   = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()
$oks      = [System.Collections.Generic.List[string]]::new()

function Check-File([string]$path, [string]$label, [bool]$required = $true) {
    $full = Join-Path $ProjectPath $path
    if (Test-Path $full) {
        $script:oks.Add("$label")
        return $full
    } else {
        if ($required) { $script:errors.Add("Ausente: $path ($label)") }
        else { $script:warnings.Add("Opcional ausente: $path ($label)") }
        return $null
    }
}

function Check-Placeholders([string]$path, [string]$label) {
    $full = Join-Path $ProjectPath $path
    if (-not (Test-Path $full)) { return }
    $content = Get-Content $full -Raw -Encoding UTF8
    $placeholders = @([regex]::Matches($content, '__[A-Z_]+__') | Select-Object -Unique)
    if ($placeholders.Count -gt 0) {
        $list = ($placeholders | ForEach-Object { $_.Value }) -join ", "
        $script:warnings.Add("Placeholders não substituídos em ${path}: $list")
    }
}

function Check-Json([string]$path, [string]$label) {
    $full = Join-Path $ProjectPath $path
    if (-not (Test-Path $full)) { return }
    try {
        Get-Content $full -Raw | ConvertFrom-Json | Out-Null
        $script:oks.Add("JSON válido: $label")
    } catch {
        $script:errors.Add("JSON inválido: $path — $($_.Exception.Message)")
    }
}

# ─── Header ───────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║   agentfiles · validate-harness      ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "  Projeto: $ProjectPath" -ForegroundColor White
Write-Host ""

# ─── Detectar ferramentas ─────────────────────────────────────────────────────

$hasKiro    = Test-Path (Join-Path $ProjectPath ".kiro")
$hasClaude  = Test-Path (Join-Path $ProjectPath ".claude")
$hasCopilot = Test-Path (Join-Path $ProjectPath ".github")
$hasAmazonQ = Test-Path (Join-Path $ProjectPath ".amazonq")
$hasCodex   = Test-Path (Join-Path $ProjectPath "AGENTS.md")
$hasGemini  = Test-Path (Join-Path $ProjectPath "GEMINI.md")
$hasQwen    = Test-Path (Join-Path $ProjectPath "QWEN.md")
$hasTrae    = Test-Path (Join-Path $ProjectPath ".trae")

Write-Host "  Ferramentas detectadas:" -ForegroundColor White
@{
    "Kiro"           = $hasKiro
    "Claude Code"    = $hasClaude
    "GitHub Copilot" = $hasCopilot
    "Amazon Q"       = $hasAmazonQ
    "Codex"          = $hasCodex
    "Gemini CLI"     = $hasGemini
    "Qwen Code"      = $hasQwen
    "TRAE"           = $hasTrae
}.GetEnumerator() | ForEach-Object {
    $icon  = if ($_.Value) { "✅" } else { "○ " }
    $color = if ($_.Value) { "Green" } else { "DarkGray" }
    Write-Host "  $icon $($_.Key)" -ForegroundColor $color
}
Write-Host ""

# ─── Validar Kiro ─────────────────────────────────────────────────────────────

if ($hasKiro) {
    Write-Host "  ── Kiro IDE ──────────────────────────────" -ForegroundColor Cyan

    $hcPath = Check-File ".kiro\harness-config.json" "harness-config.json"
    if ($hcPath) {
        Check-Json ".kiro\harness-config.json" "harness-config.json"
        Check-Placeholders ".kiro\harness-config.json" "harness-config.json"
    }

    Check-File ".kiro\settings\mcp.json" "mcp.json"
    Check-Placeholders ".kiro\settings\mcp.json" "mcp.json"

    # Steerings obrigatórios
    $requiredSteerings = @("harness-output-formatter","harness-anti-patterns","harness-agent-router","harness-one-question","git-commits")
    foreach ($s in $requiredSteerings) {
        Check-File ".kiro\steering\$s.md" "steering/$s"
    }

    # Steering de projeto (opcional mas recomendado)
    $hasProjStandards = Test-Path (Join-Path $ProjectPath ".kiro\steering\project-standards.md")
    if (-not $hasProjStandards) {
        $warnings.Add("Recomendado: .kiro/steering/project-standards.md (padrões específicos do projeto)")
    }

    # Hooks obrigatórios
    $requiredHooks = @("guardrails-pre-write","build-test-on-stop","pre-task-spec-check","validate-task-completion","session-summary","harness-retrospective")
    foreach ($h in $requiredHooks) {
        $hookPath = Check-File ".kiro\hooks\$h.json" "hook/$h"
        if ($hookPath) { Check-Json ".kiro\hooks\$h.json" "hook/$h" }
    }

    # Knowledge e quality
    Check-File ".kiro\knowledge\INDEX.md" "knowledge/INDEX.md" $false
    Check-File ".kiro\quality\history.json" "quality/history.json" $false

    # Build commands preenchidos
    $hcFull = Join-Path $ProjectPath ".kiro\harness-config.json"
    if (Test-Path $hcFull) {
        $hc = Get-Content $hcFull -Raw | ConvertFrom-Json
        if ($hc.build.command -match '__BUILD_COMMAND__') {
            $warnings.Add("harness-config.json: build.command não configurado")
        }
        if ($hc.build.test_command -match '__TEST_COMMAND__') {
            $warnings.Add("harness-config.json: build.test_command não configurado")
        }
    }
}

# ─── Validar Claude Code ──────────────────────────────────────────────────────

if ($hasClaude) {
    Write-Host "`n  ── Claude Code ───────────────────────────" -ForegroundColor Cyan

    Check-File ".claude\CLAUDE.md" "CLAUDE.md"
    Check-Placeholders ".claude\CLAUDE.md" "CLAUDE.md"
    Check-File ".claude\settings.json" "settings.json"

    $requiredRules = @("engineering-standards","workflow","01-result-pattern","02-logging-observability","03-testing-requirements","04-database-best-practices")
    foreach ($r in $requiredRules) {
        Check-File ".claude\rules\$r.md" "rule/$r"
    }

    $requiredAgents = @("senior-developer","solutions-architect","qa-engineer","business-analyst")
    foreach ($a in $requiredAgents) {
        Check-File ".claude\agents\$a.md" "agent/$a"
    }

    $requiredSkills = @("code-review","spec-driven-development","systematic-debugging","architecture-design")
    foreach ($s in $requiredSkills) {
        Check-File ".claude\skills\$s\SKILL.md" "skill/$s"
    }

    # .mcp.json na raiz
    $hasMcp = Test-Path (Join-Path $ProjectPath ".mcp.json")
    if (-not $hasMcp) {
        $warnings.Add("Recomendado: .mcp.json na raiz do projeto (MCP compartilhado com o time)")
    } else {
        Check-Placeholders ".mcp.json" ".mcp.json"
    }
}

# ─── Validar GitHub Copilot ───────────────────────────────────────────────────

if ($hasCopilot) {
    Write-Host "`n  ── GitHub Copilot ────────────────────────" -ForegroundColor Cyan

    Check-File ".github\copilot-instructions.md" "copilot-instructions.md"
    Check-Placeholders ".github\copilot-instructions.md" "copilot-instructions.md"

    foreach ($a in @("senior-developer","solutions-architect","qa-engineer","business-analyst")) {
        Check-File ".github\agents\$a.md" "agent/$a" $false
    }
    foreach ($s in @("code-review","spec-driven-development","systematic-debugging","architecture-design")) {
        Check-File ".github\skills\$s.md" "skill/$s" $false
    }
}

# ─── Validar Amazon Q ─────────────────────────────────────────────────────────

if ($hasAmazonQ) {
    Write-Host "`n  ── Amazon Q ──────────────────────────────" -ForegroundColor Cyan

    foreach ($r in @("senior-developer","solutions-architect","qa-engineer","business-analyst")) {
        $rPath = Check-File ".amazonq\rules\$r.md" "rule/$r" $false
        if ($rPath) {
            $content = Get-Content $rPath -Raw
            if ($content -notmatch 'model:') {
                $warnings.Add(".amazonq/rules/$r.md: campo 'model' ausente no frontmatter")
            }
        }
    }
}

# ─── Validar Codex ────────────────────────────────────────────────────────────

if ($hasCodex) {
    Write-Host "`n  ── OpenAI Codex ──────────────────────────" -ForegroundColor Cyan
    Check-Placeholders "AGENTS.md" "AGENTS.md"
    Check-File ".codex\config.toml" ".codex/config.toml" $false
}

# ─── Validar Gemini / Qwen ────────────────────────────────────────────────────

if ($hasGemini) {
    Write-Host "`n  ── Gemini CLI ────────────────────────────" -ForegroundColor Cyan
    Check-Placeholders "GEMINI.md" "GEMINI.md"
}

if ($hasQwen) {
    Write-Host "`n  ── Qwen Code ─────────────────────────────" -ForegroundColor Cyan
    Check-Placeholders "QWEN.md" "QWEN.md"
}

# ─── Validar TRAE ─────────────────────────────────────────────────────────────

if ($hasTrae) {
    Write-Host "`n  ── TRAE IDE ──────────────────────────────" -ForegroundColor Cyan
    foreach ($r in @("01-engineering-standards","02-git-workflow","03-architecture","04-testing-requirements")) {
        Check-File ".trae\rules\$r.md" "rule/$r"
    }
    foreach ($s in @("code-review","systematic-debugging","spec-driven-development")) {
        Check-File ".trae\skills\$s.md" "skill/$s" $false
    }
}

# ─── Resumo ───────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "  ════════════════════════════════════════════" -ForegroundColor White
Write-Host "  Resultado da validação" -ForegroundColor White
Write-Host "  ════════════════════════════════════════════" -ForegroundColor White
Write-Host ""

if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "  ✅ Harness completo e sem problemas!" -ForegroundColor Green
} else {
    if ($errors.Count -gt 0) {
        Write-Host "  🔴 Erros ($($errors.Count)):" -ForegroundColor Red
        $errors | ForEach-Object { Write-Host "     • $_" -ForegroundColor Red }
        Write-Host ""
    }
    if ($warnings.Count -gt 0) {
        Write-Host "  🟡 Avisos ($($warnings.Count)):" -ForegroundColor Yellow
        $warnings | ForEach-Object { Write-Host "     • $_" -ForegroundColor Yellow }
        Write-Host ""
    }
}

Write-Host "  Verificados: $($oks.Count) itens" -ForegroundColor DarkGray
Write-Host ""

if ($errors.Count -gt 0) { exit 1 } else { exit 0 }
