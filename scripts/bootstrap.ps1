<#
.SYNOPSIS
    Inicializa o ambiente de desenvolvimento AI para um novo projeto.

.DESCRIPTION
    Copia e personaliza os templates do agentfiles para um novo projeto,
    substituindo todos os placeholders com os dados reais.
    Suporta Kiro, Claude Code, GitHub Copilot e Amazon Q.

.PARAMETER ProjectPath
    Caminho absoluto do projeto a inicializar. Padrão: diretório atual.

.PARAMETER ProjectName
    Nome do projeto (ex: "MeuSistema"). Obrigatório.

.PARAMETER ProjectDescription
    Descrição curta do projeto em 1-2 frases. Obrigatório.

.PARAMETER StackDescription
    Stack tecnológica principal (ex: ".NET 10, C#, PostgreSQL, Blazor WASM").

.PARAMETER GithubOwner
    Owner do repositório GitHub (ex: "carloscampos2014").

.PARAMETER GithubRepo
    Nome do repositório GitHub (ex: "MeuSistema").

.PARAMETER BuildCommand
    Comando de build (ex: "dotnet build MeuSistema.sln -c Debug").

.PARAMETER TestCommand
    Comando de testes (ex: "dotnet test tests/ --logger console;verbosity=minimal").

.PARAMETER LintCommand
    Comando de lint (ex: "dotnet format --verify-no-changes"). Opcional.

.PARAMETER DbConnectionString
    Connection string do banco de dados para o MCP postgres. Opcional.

.PARAMETER Kiro
    Inicializar templates para Kiro IDE. Padrão: true.

.PARAMETER Claude
    Inicializar templates para Claude Code.

.PARAMETER Copilot
    Inicializar templates para GitHub Copilot.

.PARAMETER AmazonQ
    Inicializar templates para Amazon Q.

.PARAMETER All
    Inicializar templates para todas as ferramentas.

.EXAMPLE
    .\bootstrap.ps1 `
        -ProjectPath "C:\Dev\MeuProjeto" `
        -ProjectName "MeuProjeto" `
        -ProjectDescription "Sistema de gestao de contratos com .NET e Blazor." `
        -StackDescription ".NET 10, C#, PostgreSQL, Blazor WASM" `
        -GithubOwner "meuusuario" `
        -GithubRepo "MeuProjeto" `
        -BuildCommand "dotnet build MeuProjeto.sln -c Debug" `
        -TestCommand "dotnet test tests/ --logger console;verbosity=minimal" `
        -Kiro -Claude -Copilot
#>

[CmdletBinding()]
param(
    [string]$ProjectPath   = (Get-Location).Path,
    [Parameter(Mandatory)][string]$ProjectName,
    [Parameter(Mandatory)][string]$ProjectDescription,
    [string]$StackDescription    = "__STACK_DESCRIPTION__",
    [string]$GithubOwner         = "__GITHUB_OWNER__",
    [string]$GithubRepo          = "__GITHUB_REPO__",
    [string]$BuildCommand        = "__BUILD_COMMAND__",
    [string]$TestCommand         = "__TEST_COMMAND__",
    [string]$LintCommand         = "",
    [string]$DbConnectionString  = "",
    [switch]$Kiro,
    [switch]$Claude,
    [switch]$Copilot,
    [switch]$AmazonQ,
    [switch]$Codex,
    [switch]$Gemini,
    [switch]$Qwen,
    [switch]$Trae,
    [switch]$All
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ─── Configuração ────────────────────────────────────────────────────────────

$HarnessRoot  = Split-Path -Parent $PSScriptRoot   # c:\Dev\agentfiles
$TemplatesDir = Join-Path $HarnessRoot "templates"
$ProjectDir   = $ProjectPath.TrimEnd('\','/')

# Ativar todas as ferramentas se -All foi passado
if ($All) { $Kiro = $Claude = $Copilot = $AmazonQ = $Codex = $Gemini = $Qwen = $Trae = $true }

# Se nenhuma flag passada, ativar Kiro por padrão
if (-not ($Kiro -or $Claude -or $Copilot -or $AmazonQ -or $Codex -or $Gemini -or $Qwen -or $Trae)) { $Kiro = $true }

# Calcular caminho relativo do projeto (ex: "MeuProjeto" a partir de C:\Dev\MeuProjeto)
$ProjectDirName = Split-Path -Leaf $ProjectDir

# ─── Funções utilitárias ──────────────────────────────────────────────────────

function Write-Step([string]$msg) {
    Write-Host "`n  → $msg" -ForegroundColor Cyan
}

function Write-Ok([string]$msg) {
    Write-Host "    ✅ $msg" -ForegroundColor Green
}

function Write-Skip([string]$msg) {
    Write-Host "    ⏭  $msg" -ForegroundColor DarkGray
}

function Write-Warn([string]$msg) {
    Write-Host "    ⚠  $msg" -ForegroundColor Yellow
}

function Replace-Placeholders([string]$content) {
    $content = $content -replace '__PROJECT_NAME__',        $ProjectName
    $content = $content -replace '__PROJECT_DIR__',         $ProjectDir
    $content = $content -replace '__PROJECT_DESCRIPTION__', $ProjectDescription
    $content = $content -replace '__STACK_DESCRIPTION__',   $StackDescription
    $content = $content -replace '__GITHUB_OWNER__',        $GithubOwner
    $content = $content -replace '__GITHUB_REPO__',         $GithubRepo
    $content = $content -replace '__BUILD_COMMAND__',       $BuildCommand
    $content = $content -replace '__TEST_COMMAND__',        $TestCommand
    $content = $content -replace '__LINT_COMMAND__',        $LintCommand
    $content = $content -replace '__PROJECT_DIRNAME__',     $ProjectDirName
    return $content
}

function Copy-Template([string]$src, [string]$dst, [bool]$replace = $true) {
    $dstDir = Split-Path -Parent $dst
    if (-not (Test-Path $dstDir)) {
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }
    if ((Test-Path $dst) -and -not $replace) {
        Write-Skip "Já existe: $(Split-Path -Leaf $dst) — pulando"
        return
    }
    $content = Get-Content $src -Raw -Encoding UTF8
    $content = Replace-Placeholders $content
    Set-Content -Path $dst -Value $content -Encoding UTF8 -NoNewline
    Write-Ok "$(Split-Path -Leaf $dst)"
}

function Copy-TemplateDir([string]$srcDir, [string]$dstDir) {
    if (-not (Test-Path $srcDir)) { return }
    Get-ChildItem -Path $srcDir -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($srcDir.Length).TrimStart('\','/')
        $dst = Join-Path $dstDir $rel
        Copy-Template $_.FullName $dst
    }
}

# ─── Validações ───────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║          agentfiles  bootstrap                   ║" -ForegroundColor Magenta
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

if (-not (Test-Path $ProjectDir)) {
    Write-Error "Projeto não encontrado: $ProjectDir"
    exit 1
}

if (-not (Test-Path $TemplatesDir)) {
    Write-Error "Templates não encontrados: $TemplatesDir`nVerifique se o agentfiles está em: $HarnessRoot"
    exit 1
}

Write-Host "  Projeto    : $ProjectName" -ForegroundColor White
Write-Host "  Caminho    : $ProjectDir"  -ForegroundColor White
Write-Host "  Stack      : $StackDescription" -ForegroundColor White
Write-Host "  GitHub     : $GithubOwner/$GithubRepo" -ForegroundColor White
Write-Host ""
Write-Host "  Ferramentas:" -ForegroundColor White
if ($Kiro)    { Write-Host "    • Kiro IDE"        -ForegroundColor Cyan }
if ($Claude)  { Write-Host "    • Claude Code"     -ForegroundColor Cyan }
if ($Copilot) { Write-Host "    • GitHub Copilot"  -ForegroundColor Cyan }
if ($AmazonQ) { Write-Host "    • Amazon Q"        -ForegroundColor Cyan }
if ($Codex)   { Write-Host "    • OpenAI Codex"    -ForegroundColor Cyan }
if ($Gemini)  { Write-Host "    • Gemini CLI"      -ForegroundColor Cyan }
if ($Qwen)    { Write-Host "    • Qwen Code"       -ForegroundColor Cyan }
if ($Trae)    { Write-Host "    • TRAE IDE"        -ForegroundColor Cyan }

# ─── Kiro IDE ─────────────────────────────────────────────────────────────────

if ($Kiro) {
    Write-Step "Inicializando Kiro IDE (.kiro/)"

    $kiroSrc = Join-Path $TemplatesDir ".kiro"
    $kiroDst = Join-Path $ProjectDir   ".kiro"

    # harness-config.json
    Copy-Template `
        (Join-Path $kiroSrc "harness-config.json") `
        (Join-Path $kiroDst "harness-config.json")

    # Steerings universais
    $steeringSrc = Join-Path $kiroSrc "steering"
    $steeringDst = Join-Path $kiroDst "steering"

    $steeringsUniversais = @(
        "harness-output-formatter.md",
        "harness-anti-patterns.md",
        "harness-agent-router.md",
        "harness-one-question.md",
        "harness-verification-report.md",
        "method-development.md",
        "git-commits.md"
    )
    foreach ($f in $steeringsUniversais) {
        Copy-Template (Join-Path $steeringSrc $f) (Join-Path $steeringDst $f)
    }

    # Copiar steerings do ~/.kiro/steering (globais já instalados)
    $globalSteering = "$env:USERPROFILE\.kiro\steering"
    if (Test-Path $globalSteering) {
        Write-Ok "Steerings globais em ~/.kiro/steering já disponíveis automaticamente"
    }

    # Hooks
    $hooksSrc = Join-Path $kiroSrc "hooks"
    $hooksDst = Join-Path $kiroDst "hooks"
    $hooksUniversais = @(
        "guardrails-pre-write.json",
        "build-test-on-stop.json",
        "pre-task-spec-check.json",
        "validate-task-completion.json",
        "session-summary.json",
        "missing-test-alert.json"
    )
    foreach ($f in $hooksUniversais) {
        Copy-Template (Join-Path $hooksSrc $f) (Join-Path $hooksDst $f)
    }

    # MCP settings — substituir __PROJECT_DIR__ pelo caminho real
    $mcpSrc = Join-Path $kiroSrc  "settings\mcp.json"
    $mcpDst = Join-Path $kiroDst  "settings\mcp.json"
    if (-not (Test-Path $mcpDst)) {
        Copy-Template $mcpSrc $mcpDst
        # Adicionar postgres se connection string foi informada
        if ($DbConnectionString -ne "") {
            $mcpContent = Get-Content $mcpDst -Raw
            $postgresEntry = @"
    ,
    "postgres": {
      "command": "cmd",
      "args": [
        "/c", "npx", "-y",
        "@modelcontextprotocol/server-postgres",
        "$DbConnectionString"
      ]
    }
"@
            # Inserir antes do último }
            $mcpContent = $mcpContent -replace '(\s*}\s*)$', "$postgresEntry`$1"
            Set-Content -Path $mcpDst -Value $mcpContent -Encoding UTF8 -NoNewline
            Write-Ok "mcp.json (com postgres)"
        }
    } else {
        Write-Skip "mcp.json já existe — não sobrescrito"
    }

    # Knowledge base e quality — estrutura vazia
    $emptyDirs = @(
        (Join-Path $kiroDst "knowledge\patterns"),
        (Join-Path $kiroDst "knowledge\sessions"),
        (Join-Path $kiroDst "quality\retrospectives"),
        (Join-Path $kiroDst "specs"),
        (Join-Path $kiroDst "skills")
    )
    foreach ($d in $emptyDirs) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
    }

    Copy-Template `
        (Join-Path $kiroSrc "knowledge\INDEX.md") `
        (Join-Path $kiroDst "knowledge\INDEX.md")
    Copy-Template `
        (Join-Path $kiroSrc "quality\history.json") `
        (Join-Path $kiroDst "quality\history.json") -replace $false
    Copy-Template `
        (Join-Path $kiroSrc "quality\tech-debt.json") `
        (Join-Path $kiroDst "quality\tech-debt.json") -replace $false

    Write-Ok "Estrutura .kiro/ pronta"
}

# ─── Claude Code ──────────────────────────────────────────────────────────────

if ($Claude) {
    Write-Step "Inicializando Claude Code (.claude/)"

    $claudeSrc = Join-Path $TemplatesDir ".claude"
    $claudeDst = Join-Path $ProjectDir   ".claude"

    Copy-Template `
        (Join-Path $claudeSrc "CLAUDE.md") `
        (Join-Path $claudeDst "CLAUDE.md")

    Copy-Template `
        (Join-Path $claudeSrc "settings.local.json") `
        (Join-Path $claudeDst "settings.local.json") -replace $false

    # Rules
    @("engineering-standards.md","senior-developer.md","solutions-architect.md",
      "workflow.md","01-result-pattern.md","02-logging-observability.md",
      "03-testing-requirements.md","04-database-best-practices.md") | ForEach-Object {
        Copy-Template (Join-Path $claudeSrc "rules\$_") (Join-Path $claudeDst "rules\$_")
    }

    # Agents (subagentes — invocar com @nome)
    @("senior-developer.md","solutions-architect.md","qa-engineer.md","business-analyst.md") | ForEach-Object {
        Copy-Template (Join-Path $claudeSrc "agents\$_") (Join-Path $claudeDst "agents\$_")
    }

    # Skills (pastas com SKILL.md — invocar com /nome)
    @("code-review","spec-driven-development","systematic-debugging","architecture-design") | ForEach-Object {
        Copy-Template `
            (Join-Path $claudeSrc "skills\$_\SKILL.md") `
            (Join-Path $claudeDst "skills\$_\SKILL.md")
    }

    # Commands
    Copy-Template `
        (Join-Path $claudeSrc "commands\generate-docs.md") `
        (Join-Path $claudeDst "commands\generate-docs.md")

    # settings.json (hooks + permissões)
    Copy-Template `
        (Join-Path $claudeSrc "settings.json") `
        (Join-Path $claudeDst "settings.json") -replace $false

    # .mcp.json na raiz do projeto (MCP scoped para o projeto — Claude Code)
    Copy-Template `
        (Join-Path $TemplatesDir ".mcp.json") `
        (Join-Path $ProjectDir ".mcp.json") -replace $false

    Write-Ok "Estrutura .claude/ pronta"
}

# ─── GitHub Copilot ───────────────────────────────────────────────────────────

if ($Copilot) {
    Write-Step "Inicializando GitHub Copilot (.github/)"

    $copilotSrc = Join-Path $TemplatesDir ".github"
    $copilotDst = Join-Path $ProjectDir   ".github"

    @("agents","commands","skills") | ForEach-Object {
        New-Item -ItemType Directory -Path (Join-Path $copilotDst $_) -Force | Out-Null
    }

    Copy-Template `
        (Join-Path $copilotSrc "copilot-instructions.md") `
        (Join-Path $copilotDst "copilot-instructions.md")

    # Agents
    @("senior-developer.md","solutions-architect.md","qa-engineer.md","business-analyst.md") | ForEach-Object {
        Copy-Template (Join-Path $copilotSrc "agents\$_") (Join-Path $copilotDst "agents\$_")
    }

    # Skills
    @("code-review.md","spec-driven-development.md","systematic-debugging.md","architecture-design.md","README.md") | ForEach-Object {
        Copy-Template (Join-Path $copilotSrc "skills\$_") (Join-Path $copilotDst "skills\$_")
    }

    # Commands
    Copy-Template `
        (Join-Path $copilotSrc "commands\generate-docs.md") `
        (Join-Path $copilotDst "commands\generate-docs.md")

    Write-Ok "Estrutura .github/ pronta"
}

# ─── Amazon Q ─────────────────────────────────────────────────────────────────

if ($AmazonQ) {
    Write-Step "Inicializando Amazon Q (.amazonq/)"

    $qSrc = Join-Path $TemplatesDir ".amazonq"
    $qDst = Join-Path $ProjectDir   ".amazonq"

    @("rules","skills") | ForEach-Object {
        New-Item -ItemType Directory -Path (Join-Path $qDst $_) -Force | Out-Null
    }

    # Rules com frontmatter Amazon Q (name + description + tools + model)
    @("senior-developer.md","solutions-architect.md","qa-engineer.md","business-analyst.md") | ForEach-Object {
        Copy-Template (Join-Path $qSrc "rules\$_") (Join-Path $qDst "rules\$_")
    }

    # Skills (mesmo conteúdo do GitHub Copilot)
    @("code-review.md","spec-driven-development.md","systematic-debugging.md","architecture-design.md","README.md") | ForEach-Object {
        Copy-Template (Join-Path $qSrc "skills\$_") (Join-Path $qDst "skills\$_")
    }

    Write-Ok "Estrutura .amazonq/ pronta"
}

# ─── Codex (OpenAI) ───────────────────────────────────────────────────────────

if ($Codex) {
    Write-Step "Inicializando Codex (AGENTS.md + .codex/config.toml)"

    $codexSrc = Join-Path $TemplatesDir "codex"

    Copy-Template `
        (Join-Path $codexSrc "AGENTS.md") `
        (Join-Path $ProjectDir "AGENTS.md")

    # MCP via config.toml (escopo de projeto)
    $codexConfigDst = Join-Path $ProjectDir ".codex"
    New-Item -ItemType Directory -Path $codexConfigDst -Force | Out-Null
    Copy-Template `
        (Join-Path $codexSrc ".codex\config.toml") `
        (Join-Path $codexConfigDst "config.toml")

    Write-Ok "AGENTS.md + .codex/config.toml prontos"
}

# ─── Gemini CLI ───────────────────────────────────────────────────────────────

if ($Gemini) {
    Write-Step "Inicializando Gemini CLI (GEMINI.md)"

    $geminiSrc = Join-Path $TemplatesDir "gemini"
    Copy-Template `
        (Join-Path $geminiSrc "GEMINI.md") `
        (Join-Path $ProjectDir "GEMINI.md")

    Write-Ok "GEMINI.md pronto"
}

# ─── Qwen Code ────────────────────────────────────────────────────────────────

if ($Qwen) {
    Write-Step "Inicializando Qwen Code (QWEN.md)"

    $qwenSrc = Join-Path $TemplatesDir "qwen"
    Copy-Template `
        (Join-Path $qwenSrc "QWEN.md") `
        (Join-Path $ProjectDir "QWEN.md")

    Write-Ok "QWEN.md pronto"
}

# ─── TRAE ─────────────────────────────────────────────────────────────────────

if ($Trae) {
    Write-Step "Inicializando TRAE (.trae/)"

    $traeSrc = Join-Path $TemplatesDir ".trae"
    $traeDst = Join-Path $ProjectDir   ".trae"

    # Rules
    @("01-engineering-standards.md","02-git-workflow.md","03-architecture.md","04-testing-requirements.md") | ForEach-Object {
        Copy-Template (Join-Path $traeSrc "rules\$_") (Join-Path $traeDst "rules\$_")
    }

    # Skills
    @("code-review.md","systematic-debugging.md","spec-driven-development.md") | ForEach-Object {
        Copy-Template (Join-Path $traeSrc "skills\$_") (Join-Path $traeDst "skills\$_")
    }

    Write-Ok "Estrutura .trae/ pronta"
}

# ─── Resumo final ─────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║   Harness inicializado com sucesso!                  ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Projeto: $ProjectName" -ForegroundColor White
Write-Host "  Em:      $ProjectDir"  -ForegroundColor White
Write-Host ""
Write-Host "  Próximos passos:" -ForegroundColor White

if ($Kiro) {
    Write-Host "  1. Edite .kiro\harness-config.json para ajustar build/test commands" -ForegroundColor Yellow
    Write-Host "     se ainda não passou -BuildCommand e -TestCommand ao bootstrap."
}
if ($Kiro -or $Claude) {
    Write-Host "  2. Crie .kiro\steering\project-standards.md com padrões específicos" -ForegroundColor Yellow
    Write-Host "     da stack deste projeto (estrutura de pastas, libs proibidas, etc.)."
}
if ($Copilot) {
    Write-Host "  3. Revise .github\copilot-instructions.md e ajuste a seção de stack." -ForegroundColor Yellow
}
if ($AmazonQ) {
    Write-Host "  4. Adicione rules específicas de stack em .amazonq\rules\ se necessário." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  Dica: adicione um project-standards.md (Kiro) ou uma rule de stack" -ForegroundColor DarkGray
Write-Host "  específica (.claude/rules/, .amazonq/rules/) para completar o harness." -ForegroundColor DarkGray
Write-Host ""
