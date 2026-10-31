---
name: backend-engineering
description: APIs JSON em Go/Echo do Copiloto Caqui; carga de dados em memória, regras de liquidação e IR, agente de sugestão com a Claude API, barreiras pré e pós-modelo e registro de disparos.
---

# Backend Engineering

## Escopo

Tudo em `backend/`. Contrato e fluxo do agente estão no `SPEC.md` (seções "Arquitetura" e "Contrato da API"): siga-os ou proponha a mudança na spec antes de codar.

## Stack e layout

- Go 1.23+, Echo v4, `github.com/anthropics/anthropic-sdk-go`. Sem ORM, sem banco.
- `cmd/api/main.go`: lê config do ambiente, carrega `dados/`, sobe o Echo e serve o build do React (`frontend/dist`) com fallback para `index.html` fora de `/api`.
- `internal/dados`: structs e leitura de `clientes.json`, `posicoes.csv`, `operacoes.csv`, `conversas.csv`, `base_conhecimento/*.md` (frontmatter `id`, `titulo`, `revisado_em`), `taxas.json`, `calendario.json`. Carrega uma vez no boot; falha de leitura derruba o boot.
- `internal/regras`: funções puras, sem LLM e sem I/O:
  - `PrazoLiquidacao(op, calendario)`: corte das 16h em dia útil para CDB de liquidez diária; fundos D+1 de cotização e D+2 úteis de pagamento.
  - `FaixaIR(produto, dataAplicacao, agora)`: 22,5% / 20% / 17,5% / 15% sobre o rendimento; LCI/LCA isentas.
  - `MascararCPF`.
- `internal/sugestao`: monta o contexto, chama o modelo, aplica barreiras. O cliente do modelo fica atrás de uma interface (`Modelo`) para ter fake nos testes.
- `internal/api`: handlers, validação de entrada, limite de requisições, erros.
- `internal/disparos`: append em JSONL (`DISPAROS_PATH`, padrão `./disparos.jsonl`).

## Configuração (variáveis de ambiente)

`ANTHROPIC_API_KEY` (obrigatória), `MODELO` (padrão `claude-sonnet-5-5`), `NOW` (padrão `2026-11-18T10:00:00-03:00`), `DADOS_DIR` (padrão `../dados`), `PORT` (padrão `8080`), `RATE_LIMIT_POR_MIN` (padrão `10`). Nunca logue o valor da chave.

## Agente de sugestão

1. **Barreira pré**: sinais de golpe (código/SMS/senha pedidos por terceiro, "gerente ligou", PIX para terceiro sob pressão) → `seguranca_imediata` sem chamar o modelo.
2. **Contexto**: só do `id_cliente` pedido. Posições com faixa de IR e operações com prazo já calculados por `internal/regras`. Últimas 5 conversas. KB inteira com `revisado_em`. "Agora" = `NOW`.
3. **Prompt**: system com as regras 1, 2, 4, 5, 6, 9, 10 e 11 do case; pergunta e transcrições dentro de tags (`<pergunta_cliente>`, `<historico>`) declaradas como dados não confiáveis. Saída estruturada via tool/JSON schema: `mensagem`, `fontes[]`, `acao`, `motivo_acao`, `alertas[]`.
4. **Barreira pós**: JSON válido e `acao` no enum; toda fonte citada existe no contexto; `responder` sem fonte → `encaminhar_humano`; termos de recomendação ("recomendo", "invista em", "melhor opção", "no seu lugar eu") → bloqueio e `encaminhar_especialista`; CPF completo → bloqueio; cliente com 60+ anos, terceiro pressionando ou resgate atípico → alerta `vulneravel`.
5. Timeout de 30 s na chamada; erro do modelo vira `502` com `{erro}`, nunca sugestão inventada.

## Regras de código

- Erros sempre `{"erro": {"codigo": "...", "mensagem": "..."}}`; nunca vaze stack ou prompt.
- Valide `id_cliente` (existe?) e `pergunta` (não vazia, até 2.000 caracteres).
- Log estruturado (`log/slog`) sem pergunta crua, sem CPF e sem texto do modelo; registre `id_cliente`, ação, latência e tokens.

## Validação antes de entregar

`gofmt -l .` vazio, `go vet ./...` e `go test ./...` passando (sem rede: use o fake do `Modelo`).
