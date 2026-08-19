#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# agentfiles · bootstrap.sh
# Wrapper para rodar o bootstrap.ps1 no macOS e Linux via PowerShell 7 (pwsh).
# Requer: pwsh (PowerShell 7+) — instale com install-deps.sh
#
# Uso:
#   ./scripts/unix/bootstrap.sh \
#       --ProjectPath "$HOME/Dev/MeuProjeto" \
#       --ProjectName "MeuProjeto" \
#       --ProjectDescription "Descrição do projeto" \
#       --StackDescription ".NET 10, C#, PostgreSQL" \
#       --GithubOwner "meuusuario" \
#       --GithubRepo "MeuProjeto" \
#       --BuildCommand "dotnet build MeuProjeto.sln" \
#       --TestCommand "dotnet test tests/" \
#       --All
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP_PS1="$SCRIPT_DIR/../bootstrap.ps1"

if ! command -v pwsh &>/dev/null; then
    echo ""
    echo "  ❌ PowerShell (pwsh) não encontrado."
    echo "  Instale com: ./scripts/unix/install-deps.sh"
    echo ""
    echo "  Ou instale manualmente:"
    echo "    macOS:  brew install --cask powershell"
    echo "    Linux:  https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux"
    exit 1
fi

# Converter flags estilo --FlagName para PowerShell -FlagName
PS_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --*)
            # --ProjectPath "/caminho" → -ProjectPath "/caminho"
            flag="${1/--/-}"
            if [[ $# -gt 1 && "$2" != --* ]]; then
                PS_ARGS+=("$flag" "$2")
                shift 2
            else
                PS_ARGS+=("$flag")
                shift
            fi
            ;;
        *)
            PS_ARGS+=("$1")
            shift
            ;;
    esac
done

pwsh -NonInteractive -File "$BOOTSTRAP_PS1" "${PS_ARGS[@]}"
