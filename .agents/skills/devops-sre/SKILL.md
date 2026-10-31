---
name: devops-sre
description: Build e deploy do Copiloto Caqui: Dockerfile multi-stage (Node → Go → distroless), render.yaml, GitHub Actions, variáveis de ambiente e secrets.
---

# DevOps / SRE

## Build (um container)

`Dockerfile` na raiz, multi-stage:

1. `node:22-alpine`: `npm ci` e `npm run build` em `frontend/` → `frontend/dist`.
2. `golang:1.23-alpine`: `go build` de `backend/cmd/api` com `CGO_ENABLED=0 -trimpath -ldflags="-s -w"`.
3. `gcr.io/distroless/static-debian12:nonroot`: copia o binário, `frontend/dist` e `dados/`. Usuário não root, `EXPOSE 8080`.

Versões de imagem fixadas por tag (de preferência digest). `.dockerignore` exclui `.git`, `node_modules`, `.env*`, `respostas*.jsonl`, `disparos.jsonl`.

## Deploy no Render

- `render.yaml` (Blueprint): web service Docker, plano gratuito, `healthCheckPath: /api/saude`, auto-deploy da `main`.
- Variáveis: `MODELO`, `NOW`, `RATE_LIMIT_POR_MIN`, `DADOS_DIR=/app/dados`, `DISPAROS_PATH=/tmp/disparos.jsonl` (volátil, aceito no MVP). `ANTHROPIC_API_KEY` com `sync: false`: valor só no painel do Render, nunca no repositório.
- Plano gratuito hiberna: o primeiro acesso demora. Documente no README.

## CI (GitHub Actions)

`.github/workflows/ci.yml` em push e PR:

- backend: `gofmt -l`, `go vet ./...`, `go test ./...`, `govulncheck ./...`;
- frontend: `npm ci`, `npm run lint`, `npm run typecheck`, `npm test`, `npm audit --audit-level=high`;
- squad: `node .agents/scripts/sync-agents.mjs --check`;
- build da imagem Docker (sem push).

`make avaliar` não roda no CI: chama a Claude API e custa.

## Desenvolvimento local

`Makefile` com `dev-backend`, `dev-frontend`, `test`, `build`, `avaliar`. `.env.example` com todas as variáveis e valores vazios para segredos.

## Entrega

Comandos executados com saída, URL pública verificada (`/api/saude` e a tela), e o link no topo do README.
