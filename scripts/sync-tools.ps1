<#
.SYNOPSIS
    Sincroniza um template editado (skill ou agent) para todas as ferramentas do projeto.
    Útil quando você edita a skill no Kiro e quer propagar a mudança para Copilot, Amazon Q e TRAE.

.PARAMETER ProjectPath
    Caminho do projeto. Padrão: diretório atual.

.PARAMETER Type
    Tipo do artefato: skill, agent

.PARAMETER Name
    Nome do artefato (kebab-case). Se omitido, lista os disponíveis.

.PARAMETER SourceTool
    Ferramenta fonte da sincronização. Padrão: kiro

.EXAMPLE
    # Sincronizar skill code-review a partir do Kiro
    .\sync-tools.ps1 -ProjectPath "C:\Dev\MeuProjeto" -Type skill -Name code-review

    # Sincronizar agent devsecops-engineer a partir do Claude
    .\sync-tools.ps1 -ProjectPath "C:\Dev\MeuProjeto" -Type agent -Name devsecops-engineer -SourceTool claude

    # Listar skills disponíveis
    .\sync-tools.ps1 -ProjectPath "C:\Dev\MeuProjeto" -Type skill
#>
param(
    [string]$ProjectPath  = (Get-Location).Path,
    [ValidateSet("skill","agent")][string]$Type,
    [string]$Name         = "",
    [ValidateSet("kiro","claude","copilot","amazonq","trae")][string]$SourceTool = "kiro"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Ok([string]$msg)   { Write-Host "  ✅ $msg" -ForegroundColor Green }
function Write-Skip([string]$msg) { Write-Host "  ⏭  $msg" -ForegroundColor DarkGray }
function Write-Warn([string]$msg) { Write-Host "  ⚠  $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "  ╔══════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║   agentfiles · sync-tools        ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════╝" -ForegroundColor Magenta

# ─── Validação de entrada ─────────────────────────────────────────────────────

if (-not $Type) {
    Write-Host "`n  Uso: sync-tools.ps1 -Type skill|agent [-Name <nome>] [-SourceTool kiro|claude|copilot|amazonq|trae]" -ForegroundColor White
    exit 0
}

# ─── Localizar arquivo fonte ──────────────────────────────────────────────────

function Get-SourcePath([string]$tool, [string]$type, [string]$name) {
    switch ("$tool|$type") {
        "kiro|skill"    { return Join-Path $ProjectPath ".kiro\skills\$name\SKILL.md" }
        "claude|skill"  { return Join-Path $ProjectPath ".claude\skills\$name\SKILL.md" }
        "copilot|skill" { return Join-Path $ProjectPath ".github\skills\$name.md" }
        "amazonq|skill" { return Join-Path $ProjectPath ".amazonq\skills\$name.md" }
        "trae|skill"    { return Join-Path $ProjectPath ".trae\skills\$name.md" }
        "kiro|agent"    { return $null }  # Kiro não tem agents como arquivos de projeto
        "claude|agent"  { return Join-Path $ProjectPath ".claude\agents\$name.md" }
        "copilot|agent" { return Join-Path $ProjectPath ".github\agents\$name.md" }
        "amazonq|agent" { return Join-Path $ProjectPath ".amazonq\rules\$name.md" }
        "trae|agent"    { return $null }  # TRAE agents são via UI
    }
}

# ─── Listar artefatos disponíveis se Name não fornecido ──────────────────────

if (-not $Name) {
    Write-Host "`n  ${Type}s disponíveis para sincronizar:" -ForegroundColor White

    # Procurar em todas as ferramentas
    $found = @{}
    $searchPaths = @{
        kiro    = if ($Type -eq "skill") { ".kiro\skills" }    else { $null }
        claude  = if ($Type -eq "skill") { ".claude\skills" }  else { ".claude\agents" }
        copilot = if ($Type -eq "skill") { ".github\skills" }  else { ".github\agents" }
        amazonq = if ($Type -eq "skill") { ".amazonq\skills" } else { ".amazonq\rules" }
        trae    = if ($Type -eq "skill") { ".trae\skills" }    else { $null }
    }

    foreach ($entry in $searchPaths.GetEnumerator()) {
        if (-not $entry.Value) { continue }
        $dir = Join-Path $ProjectPath $entry.Value
        if (-not (Test-Path $dir)) { continue }

        Get-ChildItem -Path $dir | ForEach-Object {
            $n = if ($_.PSIsContainer) { $_.Name } else { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) }
            if (-not $found[$n]) { $found[$n] = @() }
            $found[$n] += $entry.Key
        }
    }

    if ($found.Count -eq 0) {
        Write-Host "  Nenhum encontrado." -ForegroundColor DarkGray
    } else {
        $found.GetEnumerator() | Sort-Object Key | ForEach-Object {
            Write-Host "  • $($_.Key)" -ForegroundColor Cyan -NoNewline
            Write-Host " ($($_.Value -join ', '))" -ForegroundColor DarkGray
        }
    }

    Write-Host ""
    Write-Host "  Uso: .\sync-tools.ps1 -Type $Type -Name <nome>" -ForegroundColor White
    exit 0
}

# ─── Sincronizar ──────────────────────────────────────────────────────────────

$srcPath = Get-SourcePath $SourceTool $Type $Name
if (-not $srcPath -or -not (Test-Path $srcPath)) {
    Write-Warn "Arquivo fonte não encontrado: $srcPath"
    Write-Host "  Verifique se o artefato existe na ferramenta '$SourceTool'." -ForegroundColor DarkGray
    exit 1
}

$rawContent = Get-Content $srcPath -Raw -Encoding UTF8

# Extrair corpo sem frontmatter
$body = $rawContent -replace '(?s)^---.*?---\s*', ''
$body = $body.TrimStart()

Write-Host "`n  Sincronizando: $Type '$Name' a partir de '$SourceTool'" -ForegroundColor White

if ($Type -eq "skill") {
    # Kiro
    if ($SourceTool -ne "kiro") {
        $dir = Join-Path $ProjectPath ".kiro\skills\$Name"
        if (Test-Path (Join-Path $ProjectPath ".kiro\skills")) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            $fm = "---`nname: $Name`ndescription: `"Sincronizado de $SourceTool`"`n---`n`n"
            Set-Content -Path (Join-Path $dir "SKILL.md") -Value ($fm + $body) -Encoding UTF8
            Write-Ok "Kiro: .kiro/skills/$Name/SKILL.md"
        } else { Write-Skip "Kiro (não inicializado)" }
    }
    # Claude
    if ($SourceTool -ne "claude") {
        $dir = Join-Path $ProjectPath ".claude\skills\$Name"
        if (Test-Path (Join-Path $ProjectPath ".claude\skills")) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            $fm = "---`nname: $Name`ndescription: `"Sincronizado de $SourceTool`"`n---`n`n"
            Set-Content -Path (Join-Path $dir "SKILL.md") -Value ($fm + $body) -Encoding UTF8
            Write-Ok "Claude: .claude/skills/$Name/SKILL.md"
        } else { Write-Skip "Claude Code (não inicializado)" }
    }
    # Copilot
    if ($SourceTool -ne "copilot") {
        $dst = Join-Path $ProjectPath ".github\skills\$Name.md"
        if (Test-Path (Join-Path $ProjectPath ".github\skills")) {
            Set-Content -Path $dst -Value $body -Encoding UTF8
            Write-Ok "Copilot: .github/skills/$Name.md"
        } else { Write-Skip "GitHub Copilot (não inicializado)" }
    }
    # Amazon Q
    if ($SourceTool -ne "amazonq") {
        $dst = Join-Path $ProjectPath ".amazonq\skills\$Name.md"
        if (Test-Path (Join-Path $ProjectPath ".amazonq\skills")) {
            Set-Content -Path $dst -Value $body -Encoding UTF8
            Write-Ok "Amazon Q: .amazonq/skills/$Name.md"
        } else { Write-Skip "Amazon Q (não inicializado)" }
    }
    # TRAE
    if ($SourceTool -ne "trae") {
        $dst = Join-Path $ProjectPath ".trae\skills\$Name.md"
        if (Test-Path (Join-Path $ProjectPath ".trae\skills")) {
            Set-Content -Path $dst -Value $body -Encoding UTF8
            Write-Ok "TRAE: .trae/skills/$Name.md"
        } else { Write-Skip "TRAE (não inicializado)" }
    }

} elseif ($Type -eq "agent") {
    # Claude
    if ($SourceTool -ne "claude") {
        $dst = Join-Path $ProjectPath ".claude\agents\$Name.md"
        if (Test-Path (Join-Path $ProjectPath ".claude\agents")) {
            $fm = "---`nname: $Name`ndescription: `"Sincronizado de $SourceTool`"`ntools: Read, Write, Bash, Grep, Glob, WebSearch`nmodel: sonnet`n---`n`n"
            Set-Content -Path $dst -Value ($fm + $body) -Encoding UTF8
            Write-Ok "Claude: .claude/agents/$Name.md"
        } else { Write-Skip "Claude Code (não inicializado)" }
    }
    # Copilot
    if ($SourceTool -ne "copilot") {
        $dst = Join-Path $ProjectPath ".github\agents\$Name.md"
        if (Test-Path (Join-Path $ProjectPath ".github\agents")) {
            $fm = "---`nname: $Name`ndescription: `"Sincronizado de $SourceTool`"`ntools: Read, Write, Edit, Bash, Grep, Glob, WebSearch`n---`n`n"
            Set-Content -Path $dst -Value ($fm + $body) -Encoding UTF8
            Write-Ok "Copilot: .github/agents/$Name.md"
        } else { Write-Skip "GitHub Copilot (não inicializado)" }
    }
    # Amazon Q
    if ($SourceTool -ne "amazonq") {
        $dst = Join-Path $ProjectPath ".amazonq\rules\$Name.md"
        if (Test-Path (Join-Path $ProjectPath ".amazonq\rules")) {
            $fm = "---`nname: $Name`ndescription: `"Sincronizado de $SourceTool`"`ntools: Read, Write, Edit, Bash, Grep, Glob, WebSearch`nmodel: claude-sonnet-4-5-20250929`n---`n`n"
            Set-Content -Path $dst -Value ($fm + $body) -Encoding UTF8
            Write-Ok "Amazon Q: .amazonq/rules/$Name.md"
        } else { Write-Skip "Amazon Q (não inicializado)" }
    }
}

Write-Host ""
Write-Host "  ✅ Sincronização concluída" -ForegroundColor Green
Write-Host ""
