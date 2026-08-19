<#
.SYNOPSIS
    Wizard interativo para criar um novo steering para o Kiro IDE.

.PARAMETER ProjectPath
    Caminho do projeto onde o steering será criado. Padrão: diretório atual.

.EXAMPLE
    .\new-steering.ps1 -ProjectPath "C:\Dev\MeuProjeto"
    .\new-steering.ps1   # usa diretório atual
#>
param(
    [string]$ProjectPath = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ─── Funções ──────────────────────────────────────────────────────────────────

function Write-Title([string]$msg) {
    Write-Host "`n  $msg" -ForegroundColor Cyan
}

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
    Write-Host "  Escolha [1-$($options.Length)] " -NoNewline -ForegroundColor White
    Write-Host "[$($default+1)]" -NoNewline -ForegroundColor DarkGray
    Write-Host ": " -NoNewline
    $choice = Read-Host
    if ([string]::IsNullOrWhiteSpace($choice)) { return $default }
    $idx = [int]$choice - 1
    if ($idx -lt 0 -or $idx -ge $options.Length) { return $default }
    return $idx
}

# ─── Header ───────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "  ╔═══════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║   agentfiles · new-steering   ║" -ForegroundColor Magenta
Write-Host "  ╚═══════════════════════════════════╝" -ForegroundColor Magenta

$steeringDir = Join-Path $ProjectPath ".kiro\steering"
if (-not (Test-Path $steeringDir)) {
    Write-Host "`n  ⚠  .kiro/steering/ não encontrado em: $ProjectPath" -ForegroundColor Yellow
    Write-Host "     Execute bootstrap.ps1 primeiro ou verifique o caminho." -ForegroundColor DarkGray
    exit 1
}

# ─── Coleta de informações ─────────────────────────────────────────────────────

Write-Title "1. Identificação"
$name = Ask "Nome do steering (kebab-case, ex: csharp-patterns)"
while ($name -notmatch '^[a-z0-9][a-z0-9-]*$') {
    Write-Host "  ⚠  Use apenas letras minúsculas, números e hífens." -ForegroundColor Yellow
    $name = Ask "Nome do steering (kebab-case)"
}

$description = Ask "Descrição em 1 frase (o agente usa para decidir quando carregar)"

Write-Title "2. Modo de inclusão"
$modes    = @(
    "auto   — Kiro detecta relevância pelo contexto (recomendado para a maioria)",
    "always — Carregado em TODA interação (reservar para regras críticas)",
    "manual — Ativado pelo dev com #$name no chat",
    "fileMatch — Ativado ao editar arquivos com padrão específico"
)
$modeIdx  = Choose "Quando este steering deve ser ativado?" $modes 0
$modeMap  = @("auto", "always", "manual", "fileMatch")
$inclusion = $modeMap[$modeIdx]

$fileMatchPattern = ""
if ($inclusion -eq "fileMatch") {
    $fileMatchPattern = Ask "Padrão de arquivo (ex: **/*.cs,**/*.tsx)" "**/*.cs"
}

Write-Title "3. Conteúdo"
$contentType = @(
    "Padrões de código (SOLID, Clean Code, nomenclatura)",
    "Workflow (git, commits, PR, deploy)",
    "Regras de arquitetura (camadas, dependências)",
    "Segurança (secrets, validação, autenticação)",
    "Testes (cobertura, nomenclatura, frameworks)",
    "Personalizado (começa em branco)"
)
$ctIdx = Choose "Tipo de conteúdo inicial" $contentType 0

# ─── Gerar conteúdo inicial por tipo ──────────────────────────────────────────

$frontmatter = "---`ninclusion: $inclusion"
if ($fileMatchPattern) { $frontmatter += "`nfileMatchPattern: `"$fileMatchPattern`"" }
$frontmatter += "`ndescription: `"$description`"`n---"

$contentMap = @(
    # 0 — Padrões de código
    @"
$frontmatter

# $name

## Nomenclatura

- Classes: PascalCase
- Métodos: PascalCase (C#) / camelCase (TS/JS)
- Variáveis: camelCase
- Constantes: UPPER_SNAKE_CASE

## Regras

- [Regra 1 — acionável e específica]
- [Regra 2]

## ✅ Correto

```
[exemplo de código ou comportamento correto]
```

## ❌ Errado

```
[exemplo do que não fazer]
```
"@,
    # 1 — Workflow
    @"
$frontmatter

# $name

## Fluxo

[Descreva o fluxo aqui]

## Etapas obrigatórias

1. [Etapa 1]
2. [Etapa 2]
3. [Etapa 3]

## Proibições

- [O que nunca fazer]
"@,
    # 2 — Arquitetura
    @"
$frontmatter

# $name

## Regra de dependência

[Descreva as regras de dependência entre camadas]

## Proibições

- [Camada X] nunca referencia [Camada Y]
- [Exemplo específico do projeto]

## Estrutura de pastas

```
[estrutura]
```
"@,
    # 3 — Segurança
    @"
$frontmatter

# $name

## Obrigatório

- Sem secrets no código — usar variáveis de ambiente
- Queries parametrizadas — zero concatenação com input do usuário
- [Regra específica do projeto]

## Proibido

- [Padrão proibido 1]
- [Padrão proibido 2]
"@,
    # 4 — Testes
    @"
$frontmatter

# $name

## Cobertura mínima

| Camada | Cobertura |
|--------|-----------|
| Domain | 95% |
| Application | 80% |

## Nomenclatura

Formato: `Metodo_Cenario_ResultadoEsperado`

## Obrigatório

- Testar caminhos de erro, não apenas o caminho feliz
- [Regra específica do projeto]
"@,
    # 5 — Personalizado
    @"
$frontmatter

# $name

[Escreva o conteúdo do steering aqui]
"@
)

$content = $contentMap[$ctIdx]

# ─── Criar arquivo ────────────────────────────────────────────────────────────

$filePath = Join-Path $steeringDir "$name.md"

if (Test-Path $filePath) {
    Write-Host "`n  ⚠  Arquivo já existe: $filePath" -ForegroundColor Yellow
    $overwrite = Ask "Sobrescrever? (s/n)" "n"
    if ($overwrite -ne "s") {
        Write-Host "  Operação cancelada." -ForegroundColor DarkGray
        exit 0
    }
}

Set-Content -Path $filePath -Value $content -Encoding UTF8
Write-Host ""
Write-Host "  ✅ Steering criado: $filePath" -ForegroundColor Green

# ─── Próximos passos ──────────────────────────────────────────────────────────

Write-Host ""
Write-Host "  Próximos passos:" -ForegroundColor White
Write-Host "  1. Edite o arquivo e complete o conteúdo:" -ForegroundColor Yellow
Write-Host "     notepad `"$filePath`"" -ForegroundColor DarkGray
if ($inclusion -eq "manual") {
    Write-Host "  2. Para ativar no Kiro, digite no chat: #$name" -ForegroundColor Yellow
} elseif ($inclusion -eq "always") {
    Write-Host "  2. Este steering será carregado em TODA sessão." -ForegroundColor Yellow
} else {
    Write-Host "  2. Este steering será carregado automaticamente pelo Kiro quando relevante." -ForegroundColor Yellow
}
Write-Host "  3. Para adicionar em outras ferramentas, use sync-tools.ps1" -ForegroundColor Yellow
Write-Host ""
