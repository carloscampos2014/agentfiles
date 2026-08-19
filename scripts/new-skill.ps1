<#
.SYNOPSIS
    Wizard para criar uma nova skill em todas as ferramentas simultaneamente.
    Cria o SKILL.md para Kiro/Claude e arquivos .md para Copilot, Amazon Q e TRAE.

.PARAMETER ProjectPath
    Caminho do projeto. Padrão: diretório atual.

.EXAMPLE
    .\new-skill.ps1 -ProjectPath "C:\Dev\MeuProjeto"
#>
param(
    [string]$ProjectPath = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Title([string]$msg) { Write-Host "`n  $msg" -ForegroundColor Cyan }
function Write-Ok([string]$msg) { Write-Host "    ✅ $msg" -ForegroundColor Green }
function Write-Skip([string]$msg) { Write-Host "    ⏭  $msg" -ForegroundColor DarkGray }
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

Write-Host ""
Write-Host "  ╔═══════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║   agentfiles · new-skill      ║" -ForegroundColor Magenta
Write-Host "  ╚═══════════════════════════════════╝" -ForegroundColor Magenta

# ─── Coleta ───────────────────────────────────────────────────────────────────

Write-Title "1. Identificação"
$name = Ask "Nome da skill (kebab-case, ex: security-review)"
while ($name -notmatch '^[a-z0-9][a-z0-9-]*$') {
    Write-Host "  ⚠  Use apenas letras minúsculas, números e hífens." -ForegroundColor Yellow
    $name = Ask "Nome da skill (kebab-case)"
}

$description = Ask "Descrição (inclua as keywords que ativam a skill)"

Write-Title "2. Conteúdo da skill"
Write-Host "  O conteúdo será gerado com um template. Você editará depois." -ForegroundColor DarkGray

$keywords = Ask "Keywords de ativação (separadas por vírgula)" "revisar, analisar, verificar"

# ─── Template de conteúdo ─────────────────────────────────────────────────────

$skillContent = @"
# Skill: $name

## Quando usar

Ativar quando o usuário pede: $keywords

## Processo

### Etapa 1 — [Nome da etapa]
[Descreva o que fazer]

### Etapa 2 — [Nome da etapa]
[Descreva o que fazer]

### Etapa 3 — Verificar e reportar
[Como verificar que a skill foi executada corretamente]

## Formato de saída

``````
[Template do resultado esperado]
``````

## Proibições

- [O que nunca fazer ao executar esta skill]
"@

$skillMd = @"
---
name: $name
description: "$description"
---

$skillContent
"@

# ─── Detectar ferramentas disponíveis ────────────────────────────────────────

$tools = @{}
$tools["kiro"]    = Test-Path (Join-Path $ProjectPath ".kiro\skills")
$tools["claude"]  = Test-Path (Join-Path $ProjectPath ".claude\skills")
$tools["copilot"] = Test-Path (Join-Path $ProjectPath ".github\skills")
$tools["amazonq"] = Test-Path (Join-Path $ProjectPath ".amazonq\skills")
$tools["trae"]    = Test-Path (Join-Path $ProjectPath ".trae\skills")

Write-Title "3. Ferramentas detectadas"
$tools.GetEnumerator() | ForEach-Object {
    $status = if ($_.Value) { "✅" } else { "❌ (não inicializada)" }
    Write-Host "  $status $($_.Key)" -ForegroundColor $(if ($_.Value) { "Green" } else { "DarkGray" })
}

# ─── Criar skill em cada ferramenta ──────────────────────────────────────────

Write-Title "4. Criando skill"

# Kiro — pasta com SKILL.md
if ($tools["kiro"]) {
    $dir = Join-Path $ProjectPath ".kiro\skills\$name"
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Set-Content -Path (Join-Path $dir "SKILL.md") -Value $skillMd -Encoding UTF8
    Write-Ok "Kiro: .kiro/skills/$name/SKILL.md"
} else { Write-Skip "Kiro (não inicializado)" }

# Claude Code — pasta com SKILL.md
if ($tools["claude"]) {
    $dir = Join-Path $ProjectPath ".claude\skills\$name"
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Set-Content -Path (Join-Path $dir "SKILL.md") -Value $skillMd -Encoding UTF8
    Write-Ok "Claude: .claude/skills/$name/SKILL.md"
} else { Write-Skip "Claude Code (não inicializado)" }

# GitHub Copilot — arquivo único
if ($tools["copilot"]) {
    Set-Content -Path (Join-Path $ProjectPath ".github\skills\$name.md") -Value $skillContent -Encoding UTF8
    Write-Ok "Copilot: .github/skills/$name.md"
} else { Write-Skip "GitHub Copilot (não inicializado)" }

# Amazon Q — arquivo único
if ($tools["amazonq"]) {
    Set-Content -Path (Join-Path $ProjectPath ".amazonq\skills\$name.md") -Value $skillContent -Encoding UTF8
    Write-Ok "Amazon Q: .amazonq/skills/$name.md"
} else { Write-Skip "Amazon Q (não inicializado)" }

# TRAE — arquivo único sem frontmatter
if ($tools["trae"]) {
    Set-Content -Path (Join-Path $ProjectPath ".trae\skills\$name.md") -Value $skillContent -Encoding UTF8
    Write-Ok "TRAE: .trae/skills/$name.md"
} else { Write-Skip "TRAE (não inicializado)" }

# ─── Resumo ───────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "  ✅ Skill '$name' criada" -ForegroundColor Green
Write-Host ""
Write-Host "  Próximos passos:" -ForegroundColor White
Write-Host "  1. Edite o conteúdo real da skill:" -ForegroundColor Yellow

if ($tools["kiro"]) {
    Write-Host "     notepad `"$(Join-Path $ProjectPath ".kiro\skills\$name\SKILL.md")`"" -ForegroundColor DarkGray
}
Write-Host "  2. Copie o conteúdo editado para as demais ferramentas (ou use sync-tools.ps1)" -ForegroundColor Yellow
Write-Host "  3. Teste no Kiro com: /$name" -ForegroundColor Yellow
Write-Host ""
