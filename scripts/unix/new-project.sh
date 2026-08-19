#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# agentfiles · new-project.sh
# Wizard interativo multiplataforma para inicializar um novo projeto.
# Equivalente ao bootstrap.ps1 mas com interface de perguntas no terminal Unix.
# Requer: pwsh (PowerShell 7+)
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; RESET='\033[0m'; BOLD='\033[1m'

ask() {
    local prompt="$1" default="${2:-}"
    if [[ -n "$default" ]]; then
        printf "  %b%s%b [%b%s%b]: " "$CYAN" "$prompt" "$RESET" "\033[0;90m" "$default" "$RESET"
    else
        printf "  %b%s%b: " "$CYAN" "$prompt" "$RESET"
    fi
    read -r value
    echo "${value:-$default}"
}

choose_tools() {
    echo -e "\n  ${BOLD}Ferramentas a inicializar:${RESET}"
    echo -e "  (espaço para selecionar, enter para confirmar)"
    echo ""

    local tools=("Kiro" "Claude" "Copilot" "AmazonQ" "Codex" "Gemini" "Qwen" "Trae")
    local selected=("true" "false" "false" "false" "false" "false" "false" "false")
    local current=0

    # Fallback simples se não tiver terminal interativo
    echo -e "  ${YELLOW}Selecione as ferramentas (s/n para cada uma):${RESET}"
    TOOL_FLAGS=""
    for i in "${!tools[@]}"; do
        printf "  %s? [s/n] " "${tools[$i]}"
        read -r ans
        if [[ "${ans,,}" == "s" || "${ans,,}" == "sim" || "${ans,,}" == "y" || "$ans" == "" && $i == 0 ]]; then
            TOOL_FLAGS="$TOOL_FLAGS -$( [[ ${tools[$i]} == "AmazonQ" ]] && echo AmazonQ || echo ${tools[$i]} )"
        fi
    done
}

# ─── Header ───────────────────────────────────────────────────────────────────

echo ""
echo -e "  ${BOLD}╔═══════════════════════════════════════╗${RESET}"
echo -e "  ${BOLD}║   agentfiles · new-project (Unix)     ║${RESET}"
echo -e "  ${BOLD}╚═══════════════════════════════════════╝${RESET}"

if ! command -v pwsh &>/dev/null; then
    echo -e "\n  ${YELLOW}⚠  PowerShell (pwsh) não encontrado.${RESET}"
    echo -e "  Instale com: ${CYAN}./scripts/unix/install-deps.sh${RESET}"
    exit 1
fi

# ─── Coleta ───────────────────────────────────────────────────────────────────

echo ""
PROJECT_PATH=$(ask "Caminho do projeto" "$HOME/Dev/MeuProjeto")
PROJECT_NAME=$(ask "Nome do projeto" "$(basename "$PROJECT_PATH")")
PROJECT_DESC=$(ask "Descrição (1-2 frases)")
STACK=$(ask "Stack tecnológica" "Node.js, TypeScript")
GH_OWNER=$(ask "GitHub owner (usuário/organização)" "$(git config user.name 2>/dev/null || echo '')")
GH_REPO=$(ask "GitHub repo name" "$PROJECT_NAME")
BUILD_CMD=$(ask "Comando de build" "npm run build")
TEST_CMD=$(ask "Comando de testes" "npm test")
DB_CONN=$(ask "Connection string Postgres (opcional, Enter para pular)" "")

choose_tools

# ─── Criar diretório se não existir ──────────────────────────────────────────

mkdir -p "$PROJECT_PATH"

# ─── Montar argumentos PowerShell ────────────────────────────────────────────

PS_CMD=(
    pwsh -NonInteractive -File "$SCRIPT_DIR/../bootstrap.ps1"
    -ProjectPath "$PROJECT_PATH"
    -ProjectName "$PROJECT_NAME"
    -ProjectDescription "$PROJECT_DESC"
    -StackDescription "$STACK"
    -GithubOwner "$GH_OWNER"
    -GithubRepo "$GH_REPO"
    -BuildCommand "$BUILD_CMD"
    -TestCommand "$TEST_CMD"
)

[[ -n "$DB_CONN" ]] && PS_CMD+=(-DbConnectionString "$DB_CONN")

# Adicionar flags de ferramentas
for flag in $TOOL_FLAGS; do
    PS_CMD+=("$flag")
done

# ─── Executar ─────────────────────────────────────────────────────────────────

echo ""
echo -e "  ${CYAN}Executando bootstrap...${RESET}"
echo ""

"${PS_CMD[@]}"
