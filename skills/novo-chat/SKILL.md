---
name: novo-chat
description: Cria um novo chat (sessão) de um projeto já no padrão estrutural, na pasta certa, com arquivo de contexto, índice atualizado e grupo da barra lateral do app do Claude. Use quando o usuário pedir "cria um chat para X", "novo chat do módulo X", "abre um chat para tratar de X" ou digitar /novo-chat, e também quando um chat aberto manualmente começar com /novo-chat para se registrar.
---

# Novo chat no padrão do projeto

Todo chat nasce igual aos demais: na pasta do projeto (que carrega `CLAUDE.md`, `.claude/rules/`, skills e conectores), com um arquivo de contexto próprio, registrado no índice e agrupado na barra lateral do projeto.

Requer o app desktop do Claude (aba Code), que oferece as ferramentas de sessão e de barra lateral usadas no passo 4.

## 1. Identificar projeto e assunto

- Projeto: pelo pedido ou pela pasta da sessão atual. Se o usuário mantém uma lista de projetos (no `CLAUDE.md` global, por exemplo), use-a. Se o projeto não estiver claro, pergunte uma vez.
- Leia a seção **"Novo chat"** do `CLAUDE.md` daquele projeto: pasta de contextos, numeração, modelo, índice e grupo da barra lateral. Se o projeto não tiver essa seção, proponha uma ao usuário (pasta `contextos/`, numeração `NN-slug.md`, índice `00-indice.md`, grupo com o nome do projeto) e grave no `CLAUDE.md` antes de seguir.
- Assunto: o título do chat no estilo dos existentes (por exemplo "Módulo Financeiro"). Confira no índice se já existe chat para o assunto; se existir, diga qual é e pergunte se o usuário quer usar o existente.

## 2. Criar o arquivo de contexto

- Próximo número livre do índice; nome `NN-slug-sem-acento.md`.
- Use as 10 seções do modelo: 1. Identificação, 2. Objetivo e escopo, 3. Contexto de negócio essencial, 4. Decisões vigentes e substituições, 5. Onde estamos, 6. Pendências em ordem, 7. Ponto exato de retomada, 8. O que não refazer e armadilhas, 9. Referências, 10. Prompt de abertura.
- Preencha com o que o usuário disse e com um levantamento inicial leve, só em leitura e no máximo cerca de 5 consultas: arquivos do projeto sobre o assunto, contextos vizinhos que o citem e, se o projeto usar um rastreador de tarefas com conector (Azure DevOps, Jira, GitHub Issues), os itens ligados ao assunto (só IDs, títulos e estados). Marque o que não foi confirmado. Não invente decisões: seção sem conteúdo fica "A definir com o usuário".
- Estado inicial "novo". Data no formato DD/MM/AAAA.

## 3. Registrar no índice

Acrescente a linha no `00-indice.md` do projeto, no mesmo formato das existentes (número, link, estado, resumo, prioridade sugerida, motivo). Prioridade: pergunte só se não der para inferir; o padrão é "média".

## 4. Abrir ou registrar a sessão

**A. Pedido feito de outro chat:** inicie uma sessão nova com `start_session` (`initiation` "user_asked", `context` "fresh", `cwd` igual à pasta do projeto quando ela não for a desta sessão, `use_worktree` false, título igual ao do chat). O `prompt` manda ler só o arquivo de contexto criado, responder em até 8 linhas (objetivo, onde estamos, próximo passo, o que depende do usuário) e aguardar. Depois:
- `detach_session` na sessão criada, para ela não ficar aninhada no chat que a criou;
- `move_sessions` para o grupo do projeto na barra lateral (descubra o id com `list_groups`; se o grupo não existir, crie com o nome definido no `CLAUDE.md`).

**B. Chat aberto manualmente, começando com /novo-chat:** a sessão atual já está na pasta certa (confira o diretório de trabalho; se não estiver na pasta do projeto, avise o usuário e pare). Crie contexto e índice como acima, renomeie a sessão atual com `set_session_title` ("self") e mova-a ("self") para o grupo do projeto. Em seguida responda como no item A.

## 5. Conferir e relatar

Confirme: arquivo de contexto gravado, linha no índice, sessão com o título certo, no grupo certo e com diretório de trabalho na pasta do projeto. Relate ao usuário em poucas linhas, com o link da sessão.

## Regras

- Não altere cards, banco, planilhas nem automações durante a criação.
- Não crie worktree nem branch.
- Se o projeto tiver regras próprias de criação de chat no `CLAUDE.md`, elas prevalecem sobre este roteiro.
