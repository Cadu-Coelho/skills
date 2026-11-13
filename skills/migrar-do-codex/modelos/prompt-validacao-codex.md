# Prompt para o Codex validar a migração

Preencha as partes entre `< >` e cole num chat novo do Codex. Ele trabalha só em leitura e grava um único relatório, que o Claude lê depois.

---

Estou migrando todo o meu trabalho do Codex para o Claude Code e preciso que você audite, **somente em leitura**, se algo relevante ficou para trás. Você conhece o que existe do seu lado (configuração, AGENTS.md, skills, automações, memórias, conectores e o histórico dos nossos chats); o Claude já montou o lado de lá.

**Regras desta tarefa**

- Não altere, mova, apague nem crie nenhum arquivo, exceto o relatório `<caminho>/validacao-codex.md`.
- Não pause, rode nem altere automações, conectores, bancos ou serviços externos.
- Não copie segredos para o relatório (senhas, tokens, chaves, cookies, `auth.json`, `.env`, arquivos de conexão). Se um segredo for a lacuna, cite só o nome e o lugar.
- Não precisa resolver nada; só apontar.

**O que já foi migrado (onde está agora)**

| Origem no Codex | Destino no Claude |
| --- | --- |
| `<pasta do projeto>/AGENTS.md` | `<pasta nova>/CLAUDE.md` e `.claude/rules/` (`<regras>`) |
| `<conectores>` | `<pasta nova>/.mcp.json` |
| `<automações>` | Tarefas agendadas do Claude |
| `<skills>` | `<onde ficaram>` |
| Preferências pessoais | `~/.claude/CLAUDE.md` |

**Deixado de fora de propósito:** `<lista com o motivo>`.

**O que verificar**

1. Regras e preferências: alguma regra que você segue (no `~/.codex`, nos `AGENTS.md`, em memórias ou aprendida nos chats) que não aparece nos destinos acima? Leia os destinos para comparar.
2. Skills, automações e conectores do Codex sem equivalente no Claude.
3. Decisões ou pendências importantes dos nossos chats que não estão nos `contextos/` nem no backlog.
4. Arquivos ou pastas de trabalho úteis que ficaram só nas pastas do Codex (fora da lista "deixado de fora"), inclusive em pastas internas como `~/.codex/visualizations`.
5. Algo migrado de forma errada ou desatualizada (caminho, versão, conta, regra que mudou depois).

**Formato do relatório**

Em português do Brasil. Para cada achado: o que é, onde está no Codex, onde deveria estar no Claude, e a gravidade (**crítico**: perderia trabalho ou quebraria algo; **importante**: regra ou contexto faltando; **opcional**). Termine com uma linha dizendo o que você conferiu e não encontrou problema. Se não houver lacunas, diga isso claramente.
