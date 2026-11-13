---
name: trava-banco-por-hook
description: Instala no projeto uma trava de governança para bancos de dados acessados por conector MCP (Supabase, Postgres e similares), usando um hook PreToolUse do Claude Code. Leitura passa livre, qualquer escrita pede confirmação e operações destrutivas (DROP, TRUNCATE, desligar RLS, DELETE sem WHERE) são bloqueadas. Use quando o usuário pedir "trava no banco", "proteger a produção", "não deixar o Claude apagar dados", "hook para o Supabase" ou quiser que o Claude só leia o banco sem pedir.
---

# Trava de banco por hook

Regras escritas no `CLAUDE.md` orientam o modelo, mas não impedem nada. Um hook `PreToolUse` roda **antes** de cada chamada de ferramenta, fora do modelo, e decide: `allow` (segue sem perguntar), `ask` (o usuário confirma na tela) ou `deny` (bloqueia). É a camada que segura um erro mesmo quando o modelo se engana.

O script `trava-banco.py` desta pasta faz três coisas:

| Situação | Decisão |
| --- | --- |
| `SELECT`, `WITH` sem escrita, `EXPLAIN`, `SHOW` | passa |
| `INSERT`, `UPDATE`, `DELETE` com `WHERE`, DDL por migration, deploy, branches | pede confirmação |
| `DROP TABLE/SCHEMA/DATABASE/COLUMN/POLICY`, `TRUNCATE`, desligar RLS, `DELETE` sem `WHERE` | bloqueia |
| Projeto diferente do protegido no mesmo conector | pede confirmação |

Comentários e o conteúdo de strings são removidos antes da análise, então `select 'drop table x'` é leitura, e um `DELETE` escondido dentro de uma CTE conta como escrita.

## Instalação no projeto

1. Pergunte ao usuário, se não estiver claro: qual conector MCP fala com o banco (veja o nome das ferramentas, ex.: `mcp__supabase__execute_sql`), qual o id do projeto de produção (se houver) e como ele quer chamar o ambiente nas mensagens.
2. Copie `trava-banco.py` para `.claude/hooks/trava-banco.py` do projeto.
3. Confira `FERRAMENTAS_SQL` no topo do script: cada ação do conector que recebe SQL e o nome do campo onde o SQL vem. Para descobrir o campo, olhe o esquema da ferramenta no conector. Acrescente as ações que faltarem.
4. Mescle o conteúdo de `exemplo-settings.json` no `.claude/settings.json` do projeto (não sobrescreva o que já existe). Ajuste o `matcher` para as ações reais do conector e preencha `TRAVA_BANCO_PROJETO` e `TRAVA_BANCO_NOME`. Se o hook não achar o script pelo caminho relativo, use o caminho absoluto.
5. Use `"onFailure": "block"`: se o script falhar, a chamada é bloqueada em vez de passar sem checagem.
6. Documente a regra em `.claude/rules/` (o que é proibido e por quê), para o modelo já saber antes de tentar.

## Teste antes de confiar

Rode o script com entradas simuladas, sem tocar no banco:

```bash
echo '{"tool_name":"mcp__supabase__execute_sql","tool_input":{"query":"select 1"}}' | python .claude/hooks/trava-banco.py
echo '{"tool_name":"mcp__supabase__execute_sql","tool_input":{"query":"drop table clientes"}}' | python .claude/hooks/trava-banco.py
```

O primeiro deve dar `allow` e o segundo `deny`. Teste também uma escrita (`ask`) e uma leitura com CTE de escrita (`ask`). Depois, numa sessão nova do Claude Code, peça uma consulta simples e confira que ela passa sem pergunta.

## Limites

- A análise é por padrões de texto, não um parser SQL completo. Ela erra para o lado seguro (na dúvida, pergunta), mas não é auditoria: mantenha backups e permissões mínimas no próprio banco.
- O hook só vê chamadas feitas pelo Claude Code. Não protege acessos por outros clientes.
- Nunca afrouxe a trava para "destravar" uma tarefa sem o usuário pedir. Se algo legítimo for bloqueado, explique e deixe ele decidir.
