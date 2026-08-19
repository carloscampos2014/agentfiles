<#
.SYNOPSIS
    Wizard interativo para criar um novo hook para o Kiro IDE.

.PARAMETER ProjectPath
    Caminho do projeto. Padrão: diretório atual.

.EXAMPLE
    .\new-hook.ps1 -ProjectPath "C:\Dev\MeuProjeto"
#>
param(
    [string]$ProjectPath = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Title([string]$msg) { Write-Host "`n  $msg" -ForegroundColor Cyan }
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
        $marker = if ($i -eq $default) { ">" } else { " " }
        $color  = if ($i -eq $default) { "Cyan" } else { "Gray" }
        Write-Host "  $marker $($i+1). $($options[$i])" -ForegroundColor $color
    }
    Write-Host "  Escolha [1-$($options.Length)] [$($default+1)]: " -NoNewline -ForegroundColor White
    $choice = Read-Host
    if ([string]::IsNullOrWhiteSpace($choice)) { return $default }
    $idx = [int]$choice - 1
    if ($idx -lt 0 -or $idx -ge $options.Length) { return $default }
    return $idx
}

# ─── Header ───────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "  ╔════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║   agentfiles · new-hook   ║" -ForegroundColor Magenta
Write-Host "  ╚════════════════════════════════╝" -ForegroundColor Magenta

$hooksDir = Join-Path $ProjectPath ".kiro\hooks"
if (-not (Test-Path $hooksDir)) {
    Write-Host "`n  ⚠  .kiro/hooks/ não encontrado. Execute bootstrap.ps1 primeiro." -ForegroundColor Yellow
    exit 1
}

# ─── Coleta ───────────────────────────────────────────────────────────────────

Write-Title "1. Identificação"
$name        = Ask "Nome do hook (kebab-case, ex: build-on-ts-save)"
$description = Ask "Descrição em 1 frase"

Write-Title "2. Evento que dispara o hook"
$triggers = @(
    "PostFileSave     — ao salvar arquivo",
    "PostFileCreate   — ao criar arquivo novo",
    "PreToolUse       — antes de executar ferramenta (pode bloquear)",
    "PostToolUse      — após executar ferramenta",
    "Stop             — ao encerrar sessão do agente",
    "PreTaskExec      — antes de iniciar task de spec",
    "PostTaskExec     — após concluir task de spec",
    "UserPromptSubmit — ao enviar mensagem no chat"
)
$trigIdx = Choose "Quando deve disparar?" $triggers 0
$trigMap = @("PostFileSave","PostFileCreate","PreToolUse","PostToolUse","Stop","PreTaskExec","PostTaskExec","UserPromptSubmit")
$trigger = $trigMap[$trigIdx]

$needsMatcher = $trigger -in @("PostFileSave","PostFileCreate","PostFileDelete","PreToolUse","PostToolUse")
$matcher = ""
if ($needsMatcher) {
    Write-Title "3. Filtro (matcher)"
    Write-Host "  Deixar vazio para disparar em qualquer arquivo/ferramenta." -ForegroundColor DarkGray
    Write-Host "  Exemplos: \.cs$  |  src\\\\.*\.ts$  |  execute_pwsh|execute_bash" -ForegroundColor DarkGray
    $matcher = Ask "Padrão regex (opcional)"
}

Write-Title "4. Tipo de ação"
$actionTypes = @(
    "command — executa um comando shell (build, lint, testes)",
    "agent   — instrui o agente a verificar/analisar algo"
)
$actIdx     = Choose "Tipo de ação" $actionTypes 0
$actionType = if ($actIdx -eq 0) { "command" } else { "agent" }

$command = ""
$timeout = "60"
$prompt  = ""

if ($actionType -eq "command") {
    Write-Title "5. Comando"
    Write-Host "  Exemplos:" -ForegroundColor DarkGray
    Write-Host "    dotnet build --no-restore -v quiet 2>&1 | Select-Object -Last 5" -ForegroundColor DarkGray
    Write-Host "    npx eslint `"`${file}`" --max-warnings 0 2>&1 | tail -10" -ForegroundColor DarkGray
    $command = Ask "Comando shell"
    $timeout = Ask "Timeout em segundos" "60"
} else {
    Write-Title "5. Instrução para o agente"
    Write-Host "  O que o agente deve verificar/analisar quando este hook disparar?" -ForegroundColor DarkGray
    Write-Host "  Inclua: o que verificar, como reportar e o que não fazer." -ForegroundColor DarkGray
    $prompt = Ask "Instrução (prompt)"
}

# ─── Gerar JSON ───────────────────────────────────────────────────────────────

$actionBlock = if ($actionType -eq "command") {
    @"
      "type": "command",
      "command": "$($command -replace '"','\"')",
      "timeout": $timeout
"@
} else {
    @"
      "type": "agent",
      "prompt": "$($prompt -replace '"','\"')"
"@
}

$matcherLine = if ($matcher) { "`n      `"matcher`": `"$($matcher -replace '\\','\\\\' -replace '"','\"')`"," } else { "" }

$json = @"
{
  "version": "v1",
  "hooks": [
    {
      "name": "$name",
      "description": "$($description -replace '"','\"')",
      "trigger": "$trigger",$matcherLine
      "action": {
$actionBlock
      },
      "enabled": true
    }
  ]
}
"@

# ─── Criar arquivo ────────────────────────────────────────────────────────────

$filePath = Join-Path $hooksDir "$name.json"

if (Test-Path $filePath) {
    Write-Host "`n  ⚠  Arquivo já existe: $filePath" -ForegroundColor Yellow
    $overwrite = Ask "Sobrescrever? (s/n)" "n"
    if ($overwrite -ne "s") { Write-Host "  Cancelado." -ForegroundColor DarkGray; exit 0 }
}

# Validar JSON antes de salvar
try {
    $null = $json | ConvertFrom-Json
} catch {
    Write-Host "`n  ⚠  JSON inválido gerado. Verifique aspas e caracteres especiais." -ForegroundColor Red
    Write-Host $json
    exit 1
}

Set-Content -Path $filePath -Value $json -Encoding UTF8
Write-Host ""
Write-Host "  ✅ Hook criado: $filePath" -ForegroundColor Green
Write-Host ""
Write-Host "  Próximos passos:" -ForegroundColor White
Write-Host "  1. Revise o arquivo gerado: notepad `"$filePath`"" -ForegroundColor Yellow
Write-Host "  2. Reinicie a sessão do Kiro para ativar o hook." -ForegroundColor Yellow
Write-Host ""
