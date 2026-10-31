# Claude Code

> O contrato canônico é `AGENTS.md`; o que construir está em `SPEC.md`. Em conflito, prevalece `AGENTS.md`.

`.claude` é um symlink para `.agents`: subagentes em `.agents/agents/*.md`, hooks em `.agents/hooks/` ligados por `.agents/settings.json`.

| Subagente | Quando acionar |
| --- | --- |
| `frontend_dev_agent` | SPA React/Vite/TS/Tailwind em `frontend/` |
| `backend_dev_agent` | APIs JSON Go/Echo, regras, agente de sugestão em `backend/` |
| `qa_agent` | `go test`, Vitest, `make avaliar` |
| `appsec_agent` | Injeção de prompt, dados pessoais, segredos, dependências |
| `devops_agent` | Dockerfile, `render.yaml`, GitHub Actions |

Não edite os adapters gerados: altere `.agents/manifest.json` e rode `node .agents/scripts/sync-agents.mjs` (no CI, `--check`).

Hooks ativos: `git-branch-guard.sh` bloqueia commit/push/merge/reset em `main`; `secret-scan.sh` bloqueia commit com segredo; `go-vet-gate.sh` e `npm-audit-gate.sh` avisam após build ou install.
