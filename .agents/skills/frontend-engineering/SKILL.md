---
name: frontend-engineering
description: SPA React + Vite + TypeScript + Tailwind + TanStack Query do Copiloto Caqui; telas, consumo da API JSON, estados de carregamento e erro, acessibilidade e testes Vitest.
---

# Frontend Engineering

## Escopo

Tudo em `frontend/`. O backend é a fonte da verdade: o frontend não calcula prazo, IR nem decide ação.

## Stack e convenções

- React 18 + Vite + TypeScript estrito (`"strict": true`), Tailwind, TanStack Query para toda chamada HTTP.
- Tipos da API em `src/api/tipos.ts`, espelhando o contrato da seção "Contrato da API" do `SPEC.md`. Mudou o contrato? Atualize os tipos e avise o backend.
- Cliente HTTP único em `src/api/cliente.ts`, com base `/api`. Em dev, proxy do Vite para `http://localhost:8080`.
- Componentes por tela em `src/telas/`, componentes reutilizáveis em `src/componentes/`.
- Dependências mínimas: nada de biblioteca de UI pesada, roteador só se houver mais de uma tela.

## Tela do copiloto (única do MVP)

1. **Seletor de cliente** (`GET /api/clientes`) com busca por nome ou ID.
2. **Painel de contexto** (`GET /api/clientes/:id/contexto`): cadastro com CPF mascarado, posições, operações recentes e últimas 5 conversas.
3. **Caixa da pergunta** + botão "Sugerir" (`POST /api/sugestoes`).
4. **Painel de sugestão**, nesta ordem visual:
   - alertas (`golpe`, `vulneravel`, `injecao`, `kb_desatualizada`) em vermelho/âmbar no topo, com `role="alert"`;
   - ação recomendada em destaque, com `motivo_acao`;
   - texto sugerido num `textarea` editável;
   - fontes como chips (`KB-012 · revisado em …`, `OP-10001`), que abrem o item no painel de contexto.
5. **Disparar**: copia o texto final para a área de transferência e chama `POST /api/disparos`. Se a ação for `seguranca_imediata`, mostre confirmação explícita antes.

## Regras que não se negociam

- Nunca renderize HTML vindo da API (`dangerouslySetInnerHTML` proibido): texto do cliente e do modelo é dado.
- Nunca mostre CPF sem máscara nem guarde dados de cliente em `localStorage`.
- Estados de carregamento, erro (`{erro: {codigo, mensagem}}`) e 429 (limite de requisições) visíveis.
- Acessível por teclado; contraste AA; rótulos em todos os campos.

## Validação antes de entregar

- `npm run lint`, `npm run typecheck` e `npm test` (Vitest + Testing Library) passando.
- Teste de componente para: alerta de golpe aparece antes do texto; ação sem fontes não mostra o botão de disparo como primário; erro 429 mostra mensagem.
