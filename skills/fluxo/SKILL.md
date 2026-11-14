---
name: fluxo
description: Menu para escolher como tocar um trabalho de código (direto, ciclo completo, uma etapa só ou apoio para entender), com submenus e escolha por clique ou número, conduzindo as skills do pacote do Matt Pocock (plugin mattpocock-skills) sem o usuário precisar decorar comandos. Use quando o usuário digitar /fluxo, pedir "abre o menu", "qual fluxo seguir", "como a gente toca isso", e também quando ele pedir uma funcionalidade nova, uma correção grande ou uma mudança de arquitetura num projeto de código e ainda não tiver dito como quer seguir.
---

# Fluxo: menu de trabalho

O objetivo é que o usuário escolha o caminho num menu curto e eu conduza o resto, chamando as skills certas na hora certa. Ninguém precisa decorar comando. Ajuste pequeno (texto, configuração, correção pontual) não passa por aqui: segue direto.

Depende do plugin `mattpocock-skills` (https://github.com/mattpocock/skills). Se ele não estiver instalado, avise e mostre como instalar:

```
/plugin marketplace add mattpocock/skills
/plugin install mattpocock-skills@mattpocock
```

Sem o plugin, as opções "Direto" e "Entender ou aprender" ainda funcionam com o que o Claude já sabe fazer.

## Como mostrar o menu

- Use a ferramenta de perguntas com opções clicáveis (`AskUserQuestion`), uma pergunta por vez, no máximo 4 opções. Escreva cada opção começando pelo número ("1. Direto") para o usuário poder responder digitando só o número.
- Sem essa ferramenta, mostre a lista numerada em texto e espere o número.
- Antes do menu, diga em uma linha o que entendi do pedido. Se o pedido ainda não estiver claro o suficiente para escolher, pergunte o que falta primeiro.
- Dois níveis no máximo. "Voltar" não precisa de opção: o usuário pode escrever "voltar" no campo livre.

### Menu principal: "Como quer tocar isso?"

1. **Direto**: eu faço e te mostro o resultado.
2. **Ciclo completo**: afinar a ideia, spec, tarefas, implementar com teste e revisar.
3. **Só uma etapa**: abre o submenu de etapas.
4. **Entender ou aprender**: abre o submenu de apoio.

### Submenu de etapas: "Qual etapa?"

1. **Afinar a ideia**: entrevista para achar os buracos do plano (`grill-me`; se o usuário quiser registrar as decisões, `grill-with-docs`).
2. **Planejar**: spec e tarefas (`to-spec`, depois `to-tickets`; se for grande demais para uma sessão, `wayfinder`).
3. **Implementar**: `tdd` quando houver comportamento testável, `implement` a partir de spec ou tarefas prontas, `prototype` para testar uma ideia descartável.
4. **Revisar e entregar**: `code-review` do Matt (padrões e spec), descrição do PR (`pr`) e retrospectiva (`retro`).

Quando a etapa tiver mais de uma skill possível, recomende uma pelo contexto e siga, sem abrir terceiro nível de menu.

### Submenu de apoio: "O que você precisa?"

1. **Me explica um conceito** (`teach`).
2. **Pesquisa isso para mim** (`research`, que grava as fontes num .md do repositório; para pesquisa ampla de mercado ou tema geral, prefira uma pesquisa profunda nativa, se houver).
3. **Como está a arquitetura deste projeto?** (`improve-codebase-architecture`).
4. **Não sei por onde ir** (`ask-matt`).

## Como acionar cada skill do Matt

O próprio Matt deixou parte das skills só para chamada manual (`disable-model-invocation`). Como o usuário escolheu no menu, a escolha dele vale como chamada manual:

1. **Skills automáticas** (`grilling`, `tdd`, `diagnosing-bugs`, `prototype`, `research`, `code-review`, `pr`, `domain-modeling`, `codebase-design`, `wizard`, `writing-for-agents`): chame pela ferramenta de skills, com o nome `mattpocock-skills:<nome>`.
2. **Skills manuais** (as demais): localize o arquivo com uma busca por `~/.claude/plugins/cache/mattpocock/mattpocock-skills/*/skills/*/<nome>/SKILL.md`. Se houver mais de uma versão, use a de número mais alto. Leia o `SKILL.md` e siga as instruções como se a skill tivesse sido chamada, lendo também os arquivos de apoio da mesma pasta quando ele mandar.
3. Se o nome não existir mais (o Matt reorganiza o pacote de vez em quando), diga isso, sugira a skill mais próxima da versão instalada e avise que o `/fluxo` precisa de ajuste.

## Ciclo completo

Etapas, nesta ordem:

1. Afinar a ideia (`grill-me`).
2. Spec (`to-spec`).
3. Tarefas (`to-tickets`).
4. Implementar tarefa por tarefa, com `tdd` quando couber.
5. Revisar: `code-review` do Matt e, para caçar bugs, sugerir o `/code-review` nativo do Claude Code.
6. Opcional: descrição do PR (`pr`) e retrospectiva (`retro`).

Regras do ciclo:

- No começo de cada etapa, diga onde estamos ("Etapa 2 de 5: spec") e o que vai sair dela.
- Ao terminar uma etapa, mostre o resultado em poucas linhas e pergunte se segue para a próxima ou para por aqui. Uma pergunta só, sem novo menu.
- Antes do primeiro `to-spec` ou `to-tickets` num repositório, verifique se existe `docs/agents/issue-tracker.md`. Se não existir, rode o setup do pacote (`setup-matt-pocock-skills`) e recomende o rastreador em **markdown local** (pasta `.scratch/`), que não escreve em nenhum serviço externo. GitHub, GitLab, Azure DevOps ou Jira só com escolha explícita do usuário.
- Criar issues, etiquetas, work items, commits, push ou PR em serviço externo sempre pede confirmação, mesmo dentro do ciclo, e segue as regras do projeto.

## Linguagem

- Explique decisões de arquitetura, banco de dados e APIs em linguagem simples: o que é, as opções, prós e contras e uma recomendação. A decisão é do usuário.
- Se o usuário disser que não entendeu, explique de outro jeito antes de seguir (o espírito da `wait-what`).
