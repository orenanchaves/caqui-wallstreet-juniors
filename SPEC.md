# SPEC: Copiloto do Atendente Caqui

**Grupo:** Victor Rosa
**URL pública:** <a definir após o deploy no Render>

> Ferramenta web interna: o atendente escolhe o cliente, cola a pergunta recebida e um agente de IA sugere a mensagem de resposta com base no histórico de conversas, nos dados da conta e na base de conhecimento. O humano revisa, edita e aprova antes de disparar. A IA nunca fala direto com o cliente.

## 1. Qual parte do problema?

**Persona:** Jonas, 24, atendente há 2 meses, ainda sem autonomia ("responder certo sem ter que chamar o supervisor a cada caso"). Hoje um atendente leva 90 dias para ter autonomia e a rotatividade é de 38% ao ano: o time está sempre cheio de Jonas.

**Motivos atacados com sugestão completa** (62% dos contatos, 5.312 h de atendente por mês):

| Motivo | Contatos/mês | Duração | Horas/mês | Recontato 7d (case) | Recontato 7d (amostra `conversas.csv`) |
| --- | ---: | ---: | ---: | ---: | ---: |
| Onde está meu dinheiro | 12.960 | 8 min | 1.728 | 34% | 44% (81 conversas) |
| Dúvida de produto ou conceito | 9.120 | 14 min | 2.128 | 18% | 25% (57) |
| Rentabilidade e extrato | 6.720 | 13 min | 1.456 | 22% | 19% (42) |

**Demais motivos:** a ferramenta só faz triagem e sugere o encaminhamento certo (golpe → segurança imediata; pedido de recomendação → especialista; reclamação/cancelamento → humano; resto → resposta só se houver fonte).

Por que esse recorte: são os motivos de maior volume e carga, cuja resposta correta depende de dado da conta (status e prazo de liquidação, saldo, IR) e de regra da base, exatamente onde o atendente novo erra ou escala para o supervisor. O recontato alto em "onde está meu dinheiro" mostra que a primeira resposta hoje não fecha o assunto.

## 2. Qual alavanca?

**Fazer o humano render mais.** Menos tempo por atendimento (a resposta chega pronta, com fonte), menos recontato (prazo e status corretos na primeira resposta) e formação mais curta (a ferramenta ensina a regra enquanto o atendente trabalha).

Não automatizamos o atendimento ao cliente: o humano continua em todo contato, o que mantém a satisfação humana (4,3) e atende ao Decreto 13.135/2026 por construção.

## 3. Quanto isso move?

Hipóteses a validar em piloto. Base de hoje: 48 mil contatos/mês, 9.560 h, 62 atendentes (≈ 154 h produtivas por atendente/mês).

| Premissa | Valor | De onde veio |
| --- | --- | --- |
| Redução do tempo médio nos 3 motivos | 30% | Brynjolfsson, Li e Raymond (NBER, 2023): copiloto em atendimento aumentou a produtividade em 14% na média e mais de 30% nos atendentes menos experientes, que são o perfil do time |
| Redução do recontato em "onde está meu dinheiro" | 1/3 (34% → 23%) | Hipótese: a resposta passa a trazer status, prazo calculado e fonte |
| Tempo até autonomia | 90 → 60 dias | Hipótese: regras e fontes aparecem em cada sugestão |
| Horas por contato humano | 12 min, R$ 31 | CASE.md |

**Conta:**

- Tempo: 5.312 h × 30% = **1.594 h/mês**
- Recontato: 12.960 × 34% × 1/3 ≈ 1.469 contatos evitados × 8 min = **196 h/mês**, ou 1.469 × R$ 31 ≈ R$ 45,5 mil/mês
- Total hoje: **≈ 1.790 h/mês ≈ 11,6 atendentes equivalentes** (18,7% das horas)
- Com 2 milhões de clientes (5× a demanda): ≈ 8.950 h/mês ≈ **58 atendentes a menos** na conta linear (de ≈ 310 para ≈ 252)

Leitura honesta: o copiloto sozinho não chega a 100 atendentes. Ele é uma peça (o humano rende mais), que precisa ser somada a autoatendimento confiável nos motivos de baixo risco. Em compensação, ataca o custo escondido da rotatividade: com 38% ao ano, encurtar a formação em 30 dias devolve capacidade todo mês.

## 4. Como a confiança aparece?

Para o **atendente**, que é quem usa a ferramenta:

- Cada sugestão vem com **fontes clicáveis**: o ID do artigo (`KB-012`, com data de revisão) ou o dado da conta (`OP-10001`, `posição P-…`). Sem fonte, a ação nunca é `responder`.
- A **ação recomendada** aparece em destaque (`responder`, `encaminhar_humano`, `encaminhar_especialista`, `seguranca_imediata`, `protocolo`, `recusar`), com o motivo.
- **Alertas** de golpe, cliente vulnerável e tentativa de injeção aparecem em vermelho no topo, antes do texto sugerido.
- O painel lateral mostra o **contexto que o agente usou**: cadastro (CPF mascarado), posições, operações recentes e as últimas 5 conversas. O atendente confere sem sair da tela.
- O atendente **sempre edita e aprova**. "Disparar" copia o texto e registra no histórico local quem aprovou, o que foi sugerido e o que foi enviado.

Para o **cliente**, a confiança aparece na resposta que ele recebe: prazo certo, com a origem ("conforme a regra de liquidação de fundos, D+1 de cotização e D+2 de pagamento"), e um humano que já leu o histórico e não pede para ele repetir a demanda.

**Saída:** a saída para humano é o próprio atendente. Golpe vira `seguranca_imediata` antes de qualquer outra coisa.

## 5. O que fica de fora?

- Integração com canais reais (WhatsApp, chat do app, e-mail, telefonia). "Disparar" = copiar e registrar.
- Login e perfis. A URL é aberta porque só há dados sintéticos; o custo é protegido por limite de requisições.
- Banco de dados. Os dados de `dados/` são carregados em memória; os disparos vão para um JSONL local, que se perde a cada novo deploy.
- Busca semântica ou RAG: a KB inteira (30 artigos curtos) vai no prompt.
- Regras 3, 7, 8 e 12 (ver tabela abaixo).
- Painel de métricas e feedback de qualidade da sugestão.

## 6. Como viabilizar esta solução?

Próximo passo para a Caqui: piloto com 10 atendentes novos por 4 semanas, medindo tempo médio de atendimento, recontato em 7 dias e taxa de edição da sugestão (quanto o atendente muda o texto) contra um grupo de controle. Depois: integração com a ferramenta de atendimento existente, login SSO e trilha de auditoria em banco, e avaliação contínua com `perguntas_teste.jsonl` ampliado a cada erro encontrado.

## Regras do case

| # | Regra | Trata? | Como vira teste | Se não trata, por quê |
| --- | --- | --- | --- | --- |
| 1 | Liquidação | Sim | Cálculo de prazo em Go (corte 16h, dias úteis do `calendario.json`, D+1/D+2 de fundos) com teste de tabela; PT da regra 1 via `make avaliar` | |
| 2 | IR regressivo | Sim | Faixa e alíquota calculadas em Go a partir de `data_aplicacao` e "agora", com bordas 180/181, 360/361, 720/721 e isenção de LCI/LCA; PT da regra 2 | |
| 3 | Comparação com a poupança | Não | | Fora do recorte do MVP; o agente explica o conceito bruto x líquido, mas não calcula a comparação |
| 4 | Sem recomendação | Sim | Barreira pós-modelo em Go (termos de recomendação bloqueiam a resposta e forçam `encaminhar_especialista`); PT da regra 4 | |
| 5 | Golpe | Sim | Barreira pré-modelo em Go (sinais de golpe forçam `seguranca_imediata` sem esperar o modelo); PT da regra 5 | |
| 6 | Cliente vulnerável | Sim | Idade ≥ 60, terceiro pressionando ou resgate atípico geram alerta e `encaminhar_humano` prioritário; PT da regra 6 | |
| 7 | Reclamação e cancelamento | Não | | Triagem apenas (sugere `encaminhar_humano`); retenção é decisão do atendente |
| 8 | Sem doom loop | Não aplica | | Não há conversa automatizada com o cliente: o humano está em todo contato |
| 9 | Não sabe, diz que não sabe | Sim | `responder` sem fonte vira `encaminhar_humano`; artigo com `revisado_em` desatualizado é sinalizado; PT da regra 9 | |
| 10 | Dados pessoais | Sim | CPF só mascarado na API e no log; contexto montado só com o `id_cliente` selecionado; teste de log | |
| 11 | Instrução escondida na conversa | Sim | Pergunta e histórico entram no prompt delimitados como dado; teste com as conversas marcadas `injecao` e PT da regra 11 | |
| 12 | Horário | Não aplica | | Ferramenta interna usada pelo atendente em turno; não promete humano ao cliente |

Itens de "O que vale para qualquer caminho" que não se aplicam: **1** (saída para humano) e **5** (cliente não repete a demanda) são atendidos por construção, porque o humano está em todo contato e vê o histórico. **3** (fonte) e **4** (golpe) se aplicam e estão tratados acima. **2** e **6** valem sempre e estão tratados (regra 4; só dados sintéticos).

## Arquitetura

```
frontend/  React + Vite + TypeScript + Tailwind + TanStack Query (SPA)
backend/   Go 1.23+ · Echo · anthropic-sdk-go
  cmd/api/                 main: carrega dados, sobe HTTP, serve o build do React
  internal/dados/          leitura de dados/ para memória (clientes, posições, operações, conversas, KB, taxas, calendário)
  internal/regras/         liquidação, IR, mascaramento: Go puro e testável, sem LLM
  internal/sugestao/       montagem do contexto, chamada à Claude API, barreiras pré e pós
  internal/api/            handlers JSON, limite de requisições, erros
  internal/disparos/       gravação do JSONL de mensagens aprovadas
Dockerfile                 multi-stage: node build → go build → distroless (um container)
render.yaml                deploy no Render a partir do GitHub
```

**Fluxo do agente de sugestão** (`POST /api/sugestoes`):

1. **Barreira pré:** sinais de golpe na pergunta → retorna `seguranca_imediata` sem chamar o modelo.
2. **Contexto:** cadastro (CPF mascarado), posições com faixa de IR já calculada, operações dos últimos 30 dias com prazo de liquidação já calculado, últimas 5 conversas do cliente, KB completa com `revisado_em`, `taxas.json` e "agora" (`NOW`, padrão `2026-11-18T10:00:00-03:00`).
3. **Modelo:** chamada única ao `claude-sonnet-5-5` com saída estruturada (`mensagem`, `fontes[]`, `acao`, `motivo_acao`, `alertas[]`). Pergunta e histórico vão delimitados como dados não confiáveis.
4. **Barreira pós:** valida o JSON e o enum de ação; `responder` sem fonte → `encaminhar_humano`; fontes citadas precisam existir no contexto; termos de recomendação → bloqueio e `encaminhar_especialista`; CPF completo na mensagem → bloqueio.

Os cálculos de prazo e IR ficam em código e chegam prontos ao modelo: ele redige, não calcula.

## Contrato da API

| Método e rota | Entrada | Saída |
| --- | --- | --- |
| `GET /api/saude` | | `{status: "ok"}` (health check do Render) |
| `GET /api/clientes` | | `[{id, nome, idade, cpf_mascarado, canal_preferido}]` |
| `GET /api/clientes/:id/contexto` | | `{cliente, posicoes[], operacoes[], conversas[]}` (últimas 5) |
| `POST /api/sugestoes` | `{id_cliente, pergunta}` | `{mensagem, fontes[{tipo: "kb"\|"conta", id, titulo}], acao, motivo_acao, alertas[{tipo: "golpe"\|"vulneravel"\|"injecao"\|"kb_desatualizada", texto}]}` |
| `POST /api/disparos` | `{id_cliente, pergunta, sugestao, mensagem_final}` | `{id, registrado_em}` |

Erros em JSON: `{erro: {codigo, mensagem}}`. Limite de requisições por IP em `/api/sugestoes` (padrão 10/min). Segredos só em variável de ambiente (`ANTHROPIC_API_KEY`); `.env` está no `.gitignore`.

## Verificação

- `go test ./...`: regras (liquidação, IR, mascaramento), barreiras e handlers, sem chamar a API real (cliente do modelo atrás de interface, com fake nos testes).
- `npm test` (Vitest): componentes do painel de sugestão, alertas e fontes.
- `make avaliar`: roda as 29 perguntas das regras 1, 2, 4, 5, 6, 9, 10 e 11 contra a API local e passa o resultado em `python3 ferramentas/checar_respostas.py respostas.jsonl --regras 1,2,4,5,6,9,10,11`. Fora do CI, porque custa chamadas. Lemos as respostas que passaram também.
- CI (GitHub Actions): lint, `go vet`, testes Go e Vitest, e `node .agents/scripts/sync-agents.mjs --check`.

## Squad de agentes

Adaptada do `sinfonia-legado`: `.agents/manifest.json` é a fonte única e `node .agents/scripts/sync-agents.mjs` gera os adapters para Claude Code (`.claude/agents/`, via symlink para `.agents/`) e Codex (`.codex/agents/`). A sessão principal orquestra.

| Agente | Skill | Responsável por |
| --- | --- | --- |
| `frontend_dev_agent` | `frontend-engineering` | SPA React/Vite/TS/Tailwind, consumo da API, painel de sugestão |
| `backend_dev_agent` | `backend-engineering` | APIs JSON em Go/Echo, regras, agente de sugestão e barreiras |
| `qa_agent` | `quality-assurance` | Testes Go e Vitest, `make avaliar`, relatório de homologação |
| `appsec_agent` | `application-security` | Injeção de prompt, dados pessoais, segredos, limite de requisições, dependências |
| `devops_agent` | `devops-sre` | Dockerfile, `render.yaml`, CI, variáveis e secrets |

Hooks (`.agents/hooks/`, ligados em `.agents/settings.json`): `secret-scan.sh`, `git-branch-guard.sh`, `go-vet-gate.sh` e `npm-audit-gate.sh`.

## Decisões

| Quando | Decisão | Por quê |
| --- | --- | --- |
| 31/10/2026 | Copiloto do atendente, não chatbot | O humano rende mais sem perder a confiança; satisfação humana 4,3 vs. bot 2,1 |
| 31/10/2026 | Histórico = últimas 5 conversas do cliente | Os dados não identificam atendente; o contexto útil para responder é o do cliente |
| 31/10/2026 | React (Vite) + Go/Echo com APIs JSON, um container | Pedido do grupo; deploy simples e sem CORS em produção |
| 31/10/2026 | Contexto montado antes, chamada única com saída estruturada | Mais previsível e barato que tool use; a KB cabe inteira no prompt |
| 31/10/2026 | Prazo e IR calculados em Go, não pelo modelo | As regras 1 e 2 são onde a IA mais erra conta |
| 31/10/2026 | Barreiras em código antes e depois do modelo | Golpe, recomendação e falta de fonte não podem depender só do prompt |
| 31/10/2026 | "Agora" fixo em 18/11/2026 10h via `NOW` | Os dados e as perguntas de teste foram calculados nessa data |
| 31/10/2026 | Sem login; limite de requisições | Só dados sintéticos; protege o custo da Claude API |
| 31/10/2026 | Deploy no Render | Deploy a partir do GitHub, sem CLI |
