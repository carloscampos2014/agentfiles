#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# agentfiles · install-deps.sh
# Instala todas as dependências necessárias para usar o agentfiles
# no macOS e Linux (Ubuntu/Debian, Fedora/RHEL, Arch).
#
# Uso:
#   chmod +x scripts/install-deps.sh
#   ./scripts/install-deps.sh
#
# Flags:
#   --skip-node    Pular instalação do Node.js
#   --skip-python  Pular instalação do Python/uv
#   --skip-gh      Pular instalação do GitHub CLI
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ─── Cores ───────────────────────────────────────────────────────────────────

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; GRAY='\033[0;90m'; RESET='\033[0m'; BOLD='\033[1m'

ok()    { echo -e "  ${GREEN}✅ $*${RESET}"; }
skip()  { echo -e "  ${GRAY}⏭  $* — pulado${RESET}"; }
warn()  { echo -e "  ${YELLOW}⚠  $*${RESET}"; }
fail()  { echo -e "  ${RED}❌ $*${RESET}"; }
title() { echo -e "\n  ${CYAN}── $*${RESET}"; }

# ─── Flags ───────────────────────────────────────────────────────────────────

SKIP_NODE=false; SKIP_PYTHON=false; SKIP_GH=false
for arg in "$@"; do
    case $arg in
        --skip-node)   SKIP_NODE=true ;;
        --skip-python) SKIP_PYTHON=true ;;
        --skip-gh)     SKIP_GH=true ;;
    esac
done

# ─── Detectar OS e package manager ───────────────────────────────────────────

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then echo "macos"
    elif [[ -f /etc/debian_version ]]; then echo "debian"
    elif [[ -f /etc/fedora-release ]] || [[ -f /etc/redhat-release ]]; then echo "fedora"
    elif [[ -f /etc/arch-release ]]; then echo "arch"
    else echo "unknown"
    fi
}

OS=$(detect_os)

install_pkg() {
    case $OS in
        macos)  brew install "$1" ;;
        debian) sudo apt-get install -y "$1" ;;
        fedora) sudo dnf install -y "$1" ;;
        arch)   sudo pacman -S --noconfirm "$1" ;;
        *)      warn "OS não reconhecido. Instale '$1' manualmente." ;;
    esac
}

command_exists() { command -v "$1" &>/dev/null; }

# ─── Header ──────────────────────────────────────────────────────────────────

echo ""
echo -e "  ${BOLD}╔═════════════════════════════════════════════╗${RESET}"
echo -e "  ${BOLD}║   agentfiles · install-deps (macOS/Linux)   ║${RESET}"
echo -e "  ${BOLD}╚═════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  OS detectado: ${CYAN}$OS${RESET}"

# ─── Homebrew (macOS) ─────────────────────────────────────────────────────────

if [[ "$OS" == "macos" ]]; then
    title "Homebrew"
    if command_exists brew; then
        ok "Homebrew já instalado: $(brew --version | head -1)"
    else
        echo "  Instalando Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        ok "Homebrew instalado"
    fi
fi

# ─── apt update (Debian/Ubuntu) ───────────────────────────────────────────────

if [[ "$OS" == "debian" ]]; then
    title "Atualizando apt"
    sudo apt-get update -qq
    ok "apt atualizado"
fi

# ─── Git ─────────────────────────────────────────────────────────────────────

title "Git"
if command_exists git; then
    ok "Git já instalado: $(git --version)"
else
    install_pkg git
    ok "Git instalado: $(git --version)"
fi

# ─── Node.js ─────────────────────────────────────────────────────────────────

title "Node.js"
if $SKIP_NODE; then
    skip "Node.js"
elif command_exists node; then
    ok "Node.js já instalado: $(node --version)"
    ok "npm: $(npm --version)"
else
    echo "  Instalando Node.js LTS via nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    # shellcheck source=/dev/null
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
    ok "Node.js instalado: $(node --version)"
fi

# ─── Python + uv ─────────────────────────────────────────────────────────────

title "Python + uv"
if $SKIP_PYTHON; then
    skip "Python/uv"
else
    if ! command_exists python3; then
        case $OS in
            macos)  brew install python ;;
            debian) sudo apt-get install -y python3 python3-pip ;;
            fedora) sudo dnf install -y python3 python3-pip ;;
            arch)   sudo pacman -S --noconfirm python python-pip ;;
        esac
    else
        ok "Python já instalado: $(python3 --version)"
    fi

    if command_exists uv; then
        ok "uv já instalado: $(uv --version)"
    else
        echo "  Instalando uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        # Adicionar ao PATH da sessão atual
        export PATH="$HOME/.local/bin:$PATH"
        if command_exists uv; then
            ok "uv instalado: $(uv --version)"
        else
            warn "uv instalado. Reinicie o terminal ou execute: source ~/.bashrc (ou ~/.zshrc)"
        fi
    fi
fi

# ─── GitHub CLI ───────────────────────────────────────────────────────────────

title "GitHub CLI"
if $SKIP_GH; then
    skip "GitHub CLI"
elif command_exists gh; then
    ok "GitHub CLI já instalado: $(gh --version | head -1)"
else
    case $OS in
        macos)
            brew install gh ;;
        debian)
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
                sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
                sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt-get update -qq && sudo apt-get install -y gh ;;
        fedora)
            sudo dnf install -y gh ;;
        arch)
            sudo pacman -S --noconfirm github-cli ;;
        *)
            warn "Instale o GitHub CLI manualmente: https://cli.github.com/" ;;
    esac
    command_exists gh && ok "GitHub CLI instalado: $(gh --version | head -1)"
fi

# ─── PowerShell 7 (opcional para rodar scripts .ps1) ─────────────────────────

title "PowerShell 7 (para rodar scripts do agentfiles)"
if command_exists pwsh; then
    ok "PowerShell já instalado: $(pwsh --version)"
else
    warn "PowerShell não encontrado. Os scripts .ps1 requerem pwsh."
    case $OS in
        macos)
            echo -e "  ${GRAY}Instalar com: brew install --cask powershell${RESET}" ;;
        debian)
            echo -e "  ${GRAY}Instalar: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux${RESET}" ;;
        fedora)
            echo -e "  ${GRAY}Instalar: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux${RESET}" ;;
        arch)
            echo -e "  ${GRAY}Instalar com: sudo pacman -S powershell${RESET}" ;;
    esac
fi

# ─── Verificação final ────────────────────────────────────────────────────────

title "Verificação final"

ALL_OK=true
for tool in git node npm npx uv uvx gh; do
    if command_exists "$tool"; then
        VERSION=$(${tool} --version 2>&1 | head -1)
        ok "$tool: $VERSION"
    else
        fail "$tool: não encontrado"
        ALL_OK=false
    fi
done

echo ""
if $ALL_OK; then
    echo -e "  ${GREEN}${BOLD}✅ Todas as dependências instaladas!${RESET}"
    echo ""
    echo -e "  Próximo passo:"
    echo -e "  ${YELLOW}pwsh scripts/bootstrap.ps1 -ProjectPath ~/Dev/MeuProjeto -ProjectName MeuProjeto ...${RESET}"
else
    echo -e "  ${YELLOW}⚠  Algumas dependências não foram encontradas.${RESET}"
    echo -e "  ${GRAY}Reinicie o terminal e execute novamente: ./scripts/install-deps.sh${RESET}"
fi
echo ""
