#!/usr/bin/env bash
# PostToolUse/Bash — go vet gate (backend-engineering/SKILL.md + quality-assurance/SKILL.md)
# Após comandos de modificação Go, executa go vet para alertar sobre erros potenciais.

set -uo pipefail

INPUT=$(cat)

CMD=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', d).get('command', ''))
except Exception:
    print('')
" 2>/dev/null || echo "")

# Só age em comandos go mod tidy, go get, go build ou go test
if ! echo "$CMD" | grep -qE '(go[[:space:]]+(get|mod[[:space:]]+tidy|build)|go[[:space:]]+test)'; then
  exit 0
fi

if [[ -f "backend/go.mod" ]]; then
  cd backend
elif [[ ! -f "go.mod" ]]; then
  exit 0
fi

echo ""
echo "🔍 QA/Backend gate: executando go vet ./... no repositório..."
VET_EXIT=0
VET_OUT=$(go vet ./... 2>&1) || VET_EXIT=$?

if [[ "$VET_EXIT" -ne 0 ]]; then
  echo ""
  echo "⚠️  Alertas de go vet detectados:"
  echo "$VET_OUT" | head -20
  echo ""
  echo "Ação: Verifique e corrija os alertas acima antes de prosseguir."
else
  echo "✅ go vet executado com sucesso sem pendências."
fi

exit 0
