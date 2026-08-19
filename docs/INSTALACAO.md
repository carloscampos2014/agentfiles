# Instalação e Pré-requisitos

## Dependências

| Dependência | Para que serve | Obrigatório |
|-------------|---------------|-------------|
| **Git** | Versionamento | ✅ Sim |
| **Node.js LTS + npm** | Servidores MCP via `npx` | ✅ Sim |
| **Python 3.10+** | Servidores MCP via `uvx` | ✅ Sim |
| **uv** | Gerenciador Python moderno (instala `uvx`) | ✅ Sim |
| **GitHub CLI (`gh`)** | Workflows de PR, issues e projetos | ✅ Sim |
| **PowerShell 7+ (`pwsh`)** | Rodar os scripts `.ps1` | ✅ Sim (macOS/Linux) |

---

## Windows

### Instalar automaticamente

```powershell
# No PowerShell como Administrador
.\scripts\windows\install-deps.ps1
```

O script usa `winget` (App Installer — nativo no Windows 11, disponível no Windows 10).

### Instalar manualmente

```powershell
# Git
winget install --id Git.Git -e

# Node.js LTS
winget install --id OpenJS.NodeJS.LTS -e

# Python
winget install --id Python.Python.3.12 -e

# uv (instala uvx junto)
Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression

# GitHub CLI
winget install --id GitHub.cli -e
```

### Verificar instalação

```powershell
git --version
node --version
npm --version
uv --version
uvx --version
gh --version
```

---

## macOS

### Instalar automaticamente

```bash
chmod +x scripts/unix/install-deps.sh
./scripts/unix/install-deps.sh
```

O script usa Homebrew (instalado automaticamente se ausente).

### Instalar manualmente

```bash
# Homebrew (se não tiver)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Dependências
brew install git node gh
brew install --cask powershell

# uv
curl -LsSf https://astral.sh/uv/install.sh | sh
```

---

## Linux (Ubuntu/Debian)

### Instalar automaticamente

```bash
chmod +x scripts/unix/install-deps.sh
./scripts/unix/install-deps.sh
```

### Instalar manualmente

```bash
# Git, Node.js, Python
sudo apt-get update
sudo apt-get install -y git nodejs npm python3 python3-pip

# uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
    sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt-get update && sudo apt-get install -y gh

# PowerShell 7
# Ver: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux
```

---

## Configurar GitHub CLI

Após instalar, autenticar:

```bash
gh auth login
# Escolher: GitHub.com → HTTPS → Login with a web browser
```

---

## Uso no macOS/Linux

Os scripts do agentfiles são PowerShell (`.ps1`). No macOS/Linux:

```bash
# Inicializar um projeto
./scripts/unix/bootstrap.sh \
    --ProjectPath "$HOME/Dev/MeuProjeto" \
    --ProjectName "MeuProjeto" \
    --ProjectDescription "Descrição do projeto" \
    --All

# Ou usar o wizard interativo
./scripts/unix/new-project.sh

# Criar novo steering
pwsh scripts/new-steering.ps1 -ProjectPath "$HOME/Dev/MeuProjeto"
```

---

## Variáveis de ambiente necessárias

Configurar antes de usar os MCPs:

```bash
# Adicionar ao ~/.bashrc ou ~/.zshrc
export GITHUB_PAT="ghp_seu_token_aqui"
export FIGMA_API_KEY="figd_seu_token_aqui"  # opcional
```

No Windows (PowerShell):

```powershell
# Adicionar ao $PROFILE ou configurar no sistema
$env:GITHUB_PAT = "ghp_seu_token_aqui"
```

Criar token em: https://github.com/settings/tokens
Escopos necessários: `repo`, `read:org`, `read:project`
