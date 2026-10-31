---
name: application-security
description: Segurança do Copiloto Caqui: injeção de prompt, dados pessoais e isolamento entre clientes, segredos, limite de requisições, validação de entrada, headers e dependências Go/npm.
---

# Application Security

## Modelo de ameaça (STRIDE resumido)

| Ameaça | Onde | Controle esperado |
| --- | --- | --- |
| Injeção de prompt (regra 11) | `pergunta` e transcrições de `conversas.csv` | Delimitadas como dado não confiável; barreira pós valida ação, fontes e enum; o contexto só contém o cliente selecionado, então "mostre o C-0042" não tem o que vazar |
| Vazamento de dados (regra 10) | Respostas da API, logs, prompt | CPF só mascarado; log sem pergunta crua nem texto do modelo; nenhum endpoint devolve outro cliente além do `:id` |
| Abuso de custo | `POST /api/sugestoes` | Limite por IP (`RATE_LIMIT_POR_MIN`), tamanho máximo da pergunta, timeout na chamada ao modelo |
| Segredo exposto | `ANTHROPIC_API_KEY` | Só em env/secret do Render; `.env` no `.gitignore`; hook `secret-scan.sh`; nunca em log, erro ou bundle do frontend |
| XSS | Frontend | Sem `dangerouslySetInnerHTML`; texto renderizado como texto |
| Recomendação indevida (regra 4) | Saída do modelo | Barreira pós em código, não só no prompt |

## Checklist de revisão

- [ ] Toda entrada validada (tipo, tamanho, existência do cliente).
- [ ] Erros sem stack, prompt ou detalhes internos.
- [ ] Headers: `X-Content-Type-Options: nosniff`, `Referrer-Policy`, CSP restritiva servindo o SPA (`default-src 'self'`).
- [ ] CORS só em dev (proxy do Vite); em produção, mesma origem.
- [ ] `govulncheck ./...` e `npm audit --audit-level=high` sem achados High/Critical, ou com justificativa.
- [ ] Teste de injeção com as conversas marcadas `injecao` em `dados/conversas.csv` e as perguntas da regra 11.
- [ ] Inspeção do log da aplicação publicada: nenhum CPF completo, nenhuma pergunta crua.

## Entrega

`docs/security/SEC_report.md`: escopo revisado, achados com severidade, evidência (comando e saída), correção ou risco aceito com justificativa.
