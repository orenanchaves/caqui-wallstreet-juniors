#!/usr/bin/env bash
# PreToolUse/Bash — Secret scan (application-security/SKILL.md)
# Bloqueia git commit/push se detectar padrões de segredos nos staged changes.

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

# Só age em git commit ou git push
if ! echo "$CMD" | grep -qE 'git[[:space:]]+(commit|push)'; then
  exit 0
fi

# Obtém diff dos staged changes
STAGED=$(git diff --cached --diff-filter=ACM 2>/dev/null || echo "")
if [[ -z "$STAGED" ]]; then
  exit 0
fi

# Escreve conteúdo em arquivo temporário para evitar conflito pipe/heredoc
TMPFILE=$(mktemp /tmp/agent-secret-scan.XXXXXX)
echo "$STAGED" > "$TMPFILE"

RESULT=$(python3 - "$TMPFILE" << 'PYEOF'
import sys, re

patterns = [
    (r'-----BEGIN (RSA|EC|OPENSSH|PGP) PRIVATE KEY', 'Chave privada'),
    (r'sk-ant-[a-zA-Z0-9_\-]{20,}', 'Anthropic API key'),
    (r'ANTHROPIC_API_KEY\s*=\s*(?!\$\{)[^\s]{8,}', 'ANTHROPIC_API_KEY com valor real'),
    (r'AKIA[0-9A-Z]{16}', 'AWS Access Key ID'),
    (r'sk-(live|test)-[a-zA-Z0-9]{20,}', 'Stripe secret key'),
    (r'ghp_[a-zA-Z0-9]{36}', 'GitHub Personal Access Token'),
    (r'ghs_[a-zA-Z0-9]{36}', 'GitHub App token'),
    (r'xoxb-[0-9]+-[0-9A-Za-z-]+', 'Slack Bot token'),
    (r'AIza[0-9A-Za-z\-_]{35}', 'Google API key'),
    (r'generic_mcp_[a-zA-Z0-9]{20,}', 'Generic MCP key (plaintext)'),
    (r'ENCRYPTION_MASTER_KEY\s*=\s*(?!\$\{)[^\s]{8,}', 'ENCRYPTION_MASTER_KEY com valor real'),
    (r'JWT_SECRET\s*=\s*(?!\$\{)[^\s]{8,}', 'JWT_SECRET com valor real'),
    (r'SENDGRID_API_KEY\s*=\s*SG\.', 'SendGrid API key'),
    (r'APP_USR-[0-9]+-[A-Za-z0-9-]+', 'MercadoPago access token'),
]

path = sys.argv[1]
with open(path) as f:
    content = f.read()

found = []
for pattern, label in patterns:
    for line in content.splitlines():
        if re.search(pattern, line) and 'noqa-secret' not in line:
            found.append(f'  [{label}] padrao: {pattern}')
            break

if found:
    print('SECRETS_FOUND')
    for item in found:
        print(item)
PYEOF
)

rm -f "$TMPFILE"

if echo "$RESULT" | grep -q "SECRETS_FOUND"; then
  echo "" >&2
  echo "🚨 SECRET SCAN — possível segredo detectado nos staged changes!" >&2
  echo "" >&2
  echo "$RESULT" | grep -v "SECRETS_FOUND" >&2
  echo "" >&2
  echo "Ações:" >&2
  echo "  1. Remova o segredo e use variáveis de ambiente (.env local, secret no Render)." >&2
  echo "  2. Se for falso positivo, adicione '# noqa-secret' ao final da linha." >&2
  echo "  3. Execute 'git diff --cached' para revisar os staged changes." >&2
  echo "" >&2
  echo "Referência: .agents/skills/application-security/SKILL.md" >&2
  exit 2
fi

exit 0
