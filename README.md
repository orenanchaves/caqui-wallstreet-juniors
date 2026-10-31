# Caqui Wallstreet Juniors: <subtítulo do case>

Case aberto do **<nome do evento>**, <data>.

<Parágrafo de contexto: quem é a empresa fictícia, qual o tamanho do desafio e o que o grupo precisa entregar.>

> Tudo aqui é fictício: a empresa, as pessoas, os documentos, os valores e as conversas. As regras são simplificadas para o desafio e não substituem a norma vigente.

## Por onde começar

1. Clique em **Use this template** para criar o repositório do grupo.
2. Leia o [CASE.md](CASE.md): contexto, números, personas e regras.
3. Explore a pasta [`dados/`](dados/). O [README dos dados](dados/README.md) descreve cada arquivo e campo.
4. Antes de qualquer código, preencha o [SPEC.md](templates/SPEC.md).
5. Construa, verifique e publique.

## O que tem aqui

```
.
├── CASE.md                    o case completo: contexto, números, personas e regras
├── dados/                     pacote de dados sintéticos, igual para todos os grupos
│   ├── README.md              descrição dos arquivos e campos
│   ├── base_conhecimento/     artigos de ajuda
│   └── perguntas_teste.jsonl  perguntas com resposta esperada, por regra
├── docs/                      materiais de apoio (PDF do case, apresentações)
├── templates/
│   ├── SPEC.md                as perguntas que a spec responde
│   └── COMO-USAMOS-IA.md      seção para colar no README do grupo
└── ferramentas/
    └── checar_respostas.py    confere as respostas da solução contra perguntas_teste.jsonl
```

**"Agora" nos dados é <data de referência>.**

## O que vale para qualquer caminho

1. <regra transversal>
2. Só dados sintéticos. Nenhum dado real de pessoa.

## Conferir as respostas

Gravem as respostas da solução num JSONL:

```json
{"id": "PT-01", "resposta": "...", "acao": "responder"}
```

Depois rodem (Python 3.9 ou mais novo, sem dependências):

```bash
python3 ferramentas/checar_respostas.py respostas.jsonl --regras 1,2
```

As pistas não substituem o critério, que é a `resposta_esperada`. Leiam as respostas que passaram também.

## Regras do dia

- Não é competição: ninguém ganha e ninguém é ranqueado.
- Nenhum segredo (chave de API, token) vai para o repositório. O `.gitignore` já ignora `.env`.
- Nada que imite marca real.
- Só dados sintéticos, sempre.

## Como o dia termina

Deixem no repositório do grupo:

- `SPEC.md` preenchido ([modelo](templates/SPEC.md))
- uma seção **Como usamos IA** no README ([modelo](templates/COMO-USAMOS-IA.md))
- o link da URL pública no topo do README

## Dúvidas e erros nos dados

Achou dado inconsistente ou regra ambígua? Abra uma issue aqui.
