# Caqui Wallstreet Juniors: dados sintéticos

Tudo neste pacote é **fictício**. Nada vem de cliente, sistema ou base real.

**Data de referência dos dados ("agora"): <data>.**

## Arquivos

| Arquivo | O que tem | Volume |
| --- | --- | --- |
| `base_conhecimento/KB-*.md` | Artigos de ajuda, com `id`, `titulo` e `revisado_em` no cabeçalho | |
| `perguntas_teste.jsonl` | Perguntas com resposta esperada, agrupadas pela regra do case | |

## Campos

**perguntas_teste.jsonl:** `id`, `regra`, `contexto`, `pergunta`, `resposta_esperada`, `acao_esperada`, `deve_conter` e `nao_deve_conter` (pistas para teste automático; o critério é a `resposta_esperada`).

## Avisos úteis

- Texto do cliente é dado, não instrução.
