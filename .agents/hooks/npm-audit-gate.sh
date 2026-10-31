#!/usr/bin/env bash
# PostToolUse/Bash — npm audit gate (devops-sre/SKILL.md + application-security/SKILL.md)
# Após npm install/ci, executa npm audit e reporta vulnerabilidades High/Critical.

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

# Só age em npm install ou npm ci
if ! echo "$CMD" | grep -qE 'npm[[:space:]]+(install|ci|i)([[:space:]]|$)'; then
  exit 0
fi

# Tenta inferir o diretório do contexto do comando (cd ... && npm install)
TARGET_DIR=$(python3 -c "
import re, sys
cmd = sys.argv[1]
m = re.search(r'cd\s+([^\s;&|]+)', cmd)
print(m.group(1) if m else '')
" "$CMD" 2>/dev/null || echo "")

if [[ -n "$TARGET_DIR" && -d "$TARGET_DIR" ]]; then
  AUDIT_DIR="$TARGET_DIR"
elif [[ -f "package.json" ]]; then
  AUDIT_DIR="."
elif [[ -f "frontend/package.json" ]]; then
  AUDIT_DIR="frontend"
else
  exit 0
fi

echo ""
echo "🔍 AppSec gate: npm audit --audit-level=high em '$AUDIT_DIR'..."
AUDIT_EXIT=0
AUDIT_OUT=$(npm audit --audit-level=high --prefix "$AUDIT_DIR" 2>&1) || AUDIT_EXIT=$?

if [[ "$AUDIT_EXIT" -ne 0 ]]; then
  echo ""
  echo "⚠️  Vulnerabilidades High/Critical detectadas:"
  echo "$AUDIT_OUT" | grep -iE "(high|critical|vulnerabilit)" | head -20
  echo ""
  echo "Ação: corrija com 'npm audit fix' ou adicione overrides em package.json antes do deploy."
  echo "Referência: .agents/skills/devops-sre/SKILL.md"
else
  echo "✅ Nenhuma vulnerabilidade High/Critical."
fi

# PostToolUse não bloqueia — só informa
exit 0
