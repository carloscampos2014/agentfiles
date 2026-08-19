<#
.SYNOPSIS
    Instala todas as dependências necessárias para usar o agentfiles no Windows.
    Node.js, npm, Python, uv/uvx, Git e GitHub CLI.

.PARAMETER SkipNode
    Pular instalação do Node.js (se já instalado).

.PARAMETER SkipPython
    Pular instalação do Python/uv (se já instalado).

.PARAMETER SkipGh
    Pular instalação do GitHub CLI (se já instalado).

.EXAMPLE
    .\install-deps.ps1
    .\install-deps.ps1 -SkipNode -SkipGh
#>
param(
    [switch]$SkipNode,
    [switch]$SkipPython,
    [switch]$SkipGh
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Title([string]$msg) {
    Write-Host "`n  ── $msg" -ForegroundColor Cyan
}
function Write-Ok([string]$msg)   { Write-Host "  ✅ $msg" -ForegroundColor Green }
function Write-Skip([string]$msg) { Write-Host "  ⏭  $msg" -ForegroundColor DarkGray }
function Write-Warn([string]$msg) { Write-Host "  ⚠  $msg" -ForegroundColor Yellow }
function Write-Fail([string]$msg) { Write-Host "  ❌ $msg" -ForegroundColor Red }

function Test-Command([string]$cmd) {
    return $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue)
}

function Get-Version([string]$cmd, [string]$args = "--version") {
    try { return (& $cmd $args 2>&1 | Select-Object -First 1).ToString().Trim() }
    catch { return "desconhecido" }
}

# ─── Header ───────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║   agentfiles · install-deps (Windows)    ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# Verificar se winget está disponível
$hasWinget = Test-Command "winget"
if (-not $hasWinget) {
    Write-Warn "winget não encontrado. Instale o App Installer pelo Microsoft Store e tente novamente."
    Write-Host "  Ou instale as dependências manualmente — veja docs/guias-criacao/05-criar-mcp.md"
    exit 1
}

# ─── Git ──────────────────────────────────────────────────────────────────────

Write-Title "Git"
if (Test-Command "git") {
    Write-Ok "Git já instalado: $(Get-Version 'git')"
} else {
    Write-Host "  Instalando Git..." -ForegroundColor White
    winget install --id Git.Git -e --silent
    Write-Ok "Git instalado"
}

# ─── Node.js ─────────────────────────────────────────────────────────────────

Write-Title "Node.js (necessário para servidores MCP via npx)"
if ($SkipNode) {
    Write-Skip "Node.js — pulado por -SkipNode"
} elseif (Test-Command "node") {
    Write-Ok "Node.js já instalado: $(Get-Version 'node')"
    Write-Ok "npm: $(Get-Version 'npm')"
} else {
    Write-Host "  Instalando Node.js LTS..." -ForegroundColor White
    winget install --id OpenJS.NodeJS.LTS -e --silent
    # Recarregar PATH
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
    Write-Ok "Node.js instalado: $(Get-Version 'node')"
}

# ─── Python + uv ─────────────────────────────────────────────────────────────

Write-Title "Python + uv (necessário para servidores MCP via uvx)"
if ($SkipPython) {
    Write-Skip "Python/uv — pulado por -SkipPython"
} else {
    if (-not (Test-Command "python")) {
        Write-Host "  Instalando Python..." -ForegroundColor White
        winget install --id Python.Python.3.12 -e --silent
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
    } else {
        Write-Ok "Python já instalado: $(Get-Version 'python')"
    }

    if (Test-Command "uv") {
        Write-Ok "uv já instalado: $(Get-Version 'uv')"
    } else {
        Write-Host "  Instalando uv (gerenciador Python moderno)..." -ForegroundColor White
        # Instalador oficial do uv
        Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
        $env:PATH = "$env:USERPROFILE\.local\bin;$env:PATH"
        if (Test-Command "uv") {
            Write-Ok "uv instalado: $(Get-Version 'uv')"
        } else {
            Write-Warn "uv instalado mas não encontrado no PATH. Reinicie o terminal."
        }
    }
}

# ─── GitHub CLI ───────────────────────────────────────────────────────────────

Write-Title "GitHub CLI (necessário para workflows de PR e issues)"
if ($SkipGh) {
    Write-Skip "GitHub CLI — pulado por -SkipGh"
} elseif (Test-Command "gh") {
    Write-Ok "GitHub CLI já instalado: $(Get-Version 'gh')"
} else {
    Write-Host "  Instalando GitHub CLI..." -ForegroundColor White
    winget install --id GitHub.cli -e --silent
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
    Write-Ok "GitHub CLI instalado: $(Get-Version 'gh')"
}

# ─── PowerShell 7+ ────────────────────────────────────────────────────────────

Write-Title "PowerShell 7+"
$psVersion = $PSVersionTable.PSVersion
if ($psVersion.Major -ge 7) {
    Write-Ok "PowerShell $psVersion (compatível)"
} else {
    Write-Warn "PowerShell $psVersion detectado. Os scripts do agentfiles funcionam melhor com PS 7+."
    Write-Host "  Instalar com: winget install --id Microsoft.PowerShell -e --silent" -ForegroundColor DarkGray
}

# ─── Verificação final ────────────────────────────────────────────────────────

Write-Title "Verificação final"

$checks = @(
    @{ Name = "git";    Label = "Git" },
    @{ Name = "node";   Label = "Node.js" },
    @{ Name = "npm";    Label = "npm" },
    @{ Name = "npx";    Label = "npx" },
    @{ Name = "uv";     Label = "uv" },
    @{ Name = "uvx";    Label = "uvx" },
    @{ Name = "gh";     Label = "GitHub CLI" }
)

$allOk = $true
foreach ($c in $checks) {
    if (Test-Command $c.Name) {
        Write-Ok "$($c.Label): $(Get-Version $c.Name)"
    } else {
        Write-Fail "$($c.Label): não encontrado"
        $allOk = $false
    }
}

Write-Host ""
if ($allOk) {
    Write-Host "  ✅ Todas as dependências instaladas!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Próximo passo:" -ForegroundColor White
    Write-Host "  .\scripts\bootstrap.ps1 -ProjectPath C:\Dev\MeuProjeto -ProjectName MeuProjeto ..." -ForegroundColor Yellow
} else {
    Write-Host "  ⚠  Algumas dependências não foram encontradas." -ForegroundColor Yellow
    Write-Host "     Reinicie o terminal e execute novamente: .\scripts\windows\install-deps.ps1" -ForegroundColor DarkGray
}
Write-Host ""
