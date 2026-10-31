#!/usr/bin/env bash
# PreToolUse/Bash — Git Flow Protection (git-flow-governance/SKILL.md)
# Bloqueia operações destrutivas do git enquanto na branch main ou master.

set -euo pipefail

INPUT=$(cat)

CMD=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', d).get('command', ''))
except Exception:
    print('')
" 2>/dev/null || echo "")

# Só age em comandos git
if ! echo "$CMD" | grep -qE '(^|;|&&|\|\|)\s*git\s'; then
  exit 0
fi

# Só age em operações destrutivas / de escrita no repositório
if ! echo "$CMD" | grep -qE 'git\s+(commit|push|merge|rebase|reset|clean|branch\s+-[Dd])'; then
  exit 0
fi

BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  echo "" >&2
  echo "🚫 GIT FLOW GUARD — operação bloqueada na branch '$BRANCH'." >&2
  echo "" >&2
  echo "Crie ou troque para uma branch de trabalho:" >&2
  echo "  git checkout -b feature/<slug>   # nova funcionalidade" >&2
  echo "  git checkout -b fix/<slug>       # correção de bug" >&2
  echo "  git checkout -b chore/<slug>     # manutenção / refactor" >&2
  echo "  git checkout -b docs/<slug>      # documentação" >&2
  echo "  git checkout -b security/<slug>  # correção de segurança" >&2
  echo "  git checkout -b infra/<slug>     # infraestrutura" >&2
  echo "" >&2
  echo "Referência: AGENTS.md (regra 3)" >&2
  exit 2
fi

exit 0
