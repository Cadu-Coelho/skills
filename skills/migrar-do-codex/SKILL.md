---
name: migrar-do-codex
description: Migra o trabalho de quem usa o OpenAI Codex (CLI ou app) para o Claude Code, projeto por projeto, sem perder regras, skills, automações, conectores nem o contexto dos chats. Faz inventário, converte AGENTS.md em CLAUDE.md e .claude/rules/, copia só o essencial (80/20), cria um contexto e um chat por frente de trabalho e termina com uma validação cruzada feita pelo próprio Codex. Use quando o usuário disser "migrar do Codex", "sair do Codex", "trazer meus projetos do Codex para o Claude" ou parecido.
---

# Migrar do Codex para o Claude Code

Roteiro testado numa migração real de três projetos (trabalho, empresa própria e pessoal) em três dias. A ideia central: o Codex vira **arquivo** intacto, o Claude ganha uma cópia enxuta e organizada, e no fim o Codex audita se algo ficou para trás.

## Princípios

- **Não mover, copiar.** As pastas do Codex ficam intactas até o fim (e depois). Nada é apagado durante a migração.
- **80/20.** Traga o que é usado: regras, skills, código ativo, documentos de referência. Deixe de fora caches, builds, `node_modules`, experimentos, rollbacks temporários e downloads. Registre o que ficou de fora e por quê.
- **Uma fonte por regra.** Depois da migração, a regra vive em `.claude/rules/` (ou no `CLAUDE.md`). Se o Codex continuar em uso por um tempo, decida com o usuário se o `AGENTS.md` vira cópia ou fica congelado; não mantenha duas fontes editáveis.
- **Credenciais nunca são copiadas para arquivos de texto.** Ficam onde estão (cofre do sistema, variáveis de usuário) e são só referenciadas pelo nome.
- **Um projeto por vez**, com teste antes de passar ao próximo.

## 1. Inventário (somente leitura)

Para cada projeto, levante e mostre ao usuário numa tabela curta:

| Item no Codex | Onde costuma estar |
| --- | --- |
| Regras do projeto | `AGENTS.md` na raiz e em subpastas |
| Preferências globais | `~/.codex/AGENTS.md`, memórias |
| Configuração e conectores MCP | `~/.codex/config.toml` |
| Skills | `~/.codex/skills/`, `.codex/skills/` do projeto, plugins |
| Automações | `~/.codex/automations/` (e o banco local do app) |
| Artefatos gerados (protótipos, visualizações) | `~/.codex/visualizations/` e similares |
| Histórico de chats | `~/.codex/sessions/` |

Pergunte quais pastas são projetos e quais são só arquivo. Some o tamanho das pastas para planejar o 80/20.

## 2. Mapear para o Claude

| Codex | Claude Code |
| --- | --- |
| `AGENTS.md` do projeto | `CLAUDE.md` curto (identidade do projeto, mapa) + `.claude/rules/<tema>.md` (uma regra por assunto) |
| `~/.codex/AGENTS.md` | `~/.claude/CLAUDE.md` |
| Skills | `.claude/skills/` do projeto ou `~/.claude/skills/` (globais); revise o texto, não copie cego |
| Conectores em `config.toml` | `.mcp.json` do projeto (servidores locais) ou conectores da conta claude.ai |
| Automações | Tarefas agendadas do Claude (pause as do Codex, só apague depois que as novas rodarem bem) |
| Regras de governança "só no texto" | Hook `PreToolUse` que bloqueia de verdade (veja a skill `trava-banco-por-hook`) |
| Artefatos em pastas internas do Codex | Pasta persistente do projeto (ex.: `prototipos/`), com os contextos apontando para lá |

## 3. Montar o projeto novo

1. Crie a pasta do projeto no Claude e copie o essencial. Use cópia com exclusões (`robocopy /XD node_modules .git ...` ou `rsync --exclude`), nunca mova.
2. Escreva `CLAUDE.md` e `.claude/rules/`. Leia o `AGENTS.md` inteiro e também o histórico recente dos chats principais: muitas regras foram combinadas no chat e nunca chegaram ao `AGENTS.md`.
3. Reaponte caminhos em regras, skills, scripts, `.mcp.json` e tarefas agendadas. Procure o caminho antigo em todo o projeto novo (`grep -r`) até não sobrar ocorrência indevida.
4. Teste cada conector e cada trava a partir da pasta nova, em leitura.

## 4. Contextos e chats por frente

Um chat do Codex com 200 mensagens não deve virar um chat do Claude com 200 mensagens. Divida o projeto em **frentes** (módulos, temas, clientes) e, para cada uma:

- Crie `contextos/NN-slug.md` com as 10 seções de `modelos/contexto.md`. O contexto concentra o que importa (decisões vigentes, onde estamos, armadilhas) e cita o histórico do Codex como fonte de detalhe.
- Mantenha um índice `contextos/00-indice.md`.
- Abra um chat do Claude por frente, que lê só o próprio contexto ao começar (a skill `novo-chat` automatiza isso no app desktop).

## 5. Validação cruzada pelo Codex

Quem melhor sabe o que ficou para trás é o próprio Codex, que conhece a configuração e os chats dele. Preencha `modelos/prompt-validacao-codex.md` com a tabela do que foi migrado e o que ficou de fora de propósito, e peça ao usuário para colar num chat novo do Codex. Ele trabalha só em leitura e grava um relatório; o Claude lê o relatório e trata cada achado (corrigir, registrar ou descartar com motivo).

## 6. Encerrar

- Registre o estado num arquivo de status da migração (concluído, pendências, decisões adiadas), para retomar sem reler tudo.
- Faça backup da configuração nova (veja a skill `backup-claude-config`).
- **Antes de desinstalar o Codex ou apagar `~/.codex`:** guarde `~/.codex/sessions`. Os contextos citam esses históricos como fonte, e eles não voltam.
- Apague as automações antigas do Codex só depois de conferir que as tarefas novas rodaram com sucesso.

## Armadilhas vistas na prática

- Artefatos que só existiam em pasta interna do Codex (visualizações, protótipos) e seriam perdidos ao limpar `~/.codex`.
- Contextos apontando para a estrutura antiga depois de uma reorganização de pastas.
- Instruções antigas convivendo com a regra nova que as revogou, sem marcar a substituição.
- Variantes de código de deploy diferentes da fonte local, sem saber qual está em produção.
