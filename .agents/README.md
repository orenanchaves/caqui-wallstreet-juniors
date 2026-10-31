# `.agents`: fonte canônica da squad

Adaptado do `sinfonia-legado`, enxuto para o Copiloto do Atendente Caqui.

- `manifest.json`: única fonte de IDs, descrições e skills dos agentes.
- `scripts/sync-agents.mjs`: gera os adapters. Rode `node .agents/scripts/sync-agents.mjs` após mudar o manifesto; no CI, `--check`.
- `agents/<slug>.md`: adapter Claude Code (gerado). `.claude` é um symlink para `.agents`.
- `../.codex/agents/<slug>.toml`: adapter Codex (gerado).
- `skills/<skill>/SKILL.md`: instruções de cada especialidade, específicas desta stack.
- `hooks/`: guardas ligadas em `settings.json` (segredos, branch protegida, `go vet`, `npm audit`).

Não edite adapters à mão.
