"""Trava de banco de dados para o Claude Code (hook PreToolUse).

Leitura passa sem perguntar. Qualquer escrita pede confirmação. Operações
destrutivas (DROP, TRUNCATE, desligar RLS...) são bloqueadas.

Funciona com qualquer conector MCP que receba SQL: ajuste FERRAMENTAS_SQL com o
nome da ação e o campo que traz o SQL, e PROJETO_PERMITIDO se o conector
tiver o conceito de projeto (Supabase, Neon, PlanetScale...).
Configuração do hook: veja exemplo-settings.json.
"""
import json
import os
import re
import sys

# Projeto que esta trava protege. Outro projeto no mesmo conector = pedir confirmação.
# Pode vir da variável de ambiente TRAVA_BANCO_PROJETO. Vazio = não confere projeto.
PROJETO_PERMITIDO = os.environ.get("TRAVA_BANCO_PROJETO", "")
NOME_AMBIENTE = os.environ.get("TRAVA_BANCO_NOME", "banco de produção")

# Ação da ferramenta MCP (parte final do nome, depois de "__") -> campo com o SQL.
FERRAMENTAS_SQL = {
    "execute_sql": "query",      # Supabase
    "apply_migration": "query",  # Supabase (DDL)
    "query": "sql",              # servidores MCP de Postgres genéricos
    "run_sql": "sql",
}
# Ações que sempre mudam estrutura (nunca contam como leitura).
FERRAMENTAS_DDL = {"apply_migration"}

PROIBIDO = [
    (r"\bdrop\s+table\b", "DROP TABLE"),
    (r"\bdrop\s+schema\b", "DROP SCHEMA"),
    (r"\bdrop\s+database\b", "DROP DATABASE"),
    (r"\btruncate\b", "TRUNCATE"),
    (r"\bdrop\s+column\b", "remoção de coluna"),
    (r"\bdisable\s+row\s+level\s+security\b", "desativação de RLS"),
    (r"\bno\s+force\s+row\s+level\s+security\b", "enfraquecimento de RLS"),
    (r"\bdrop\s+policy\b", "remoção de política"),
    (r"\bdelete\s+from\s+\w+(\.\w+)?\s*(;|$)", "DELETE sem WHERE"),
]

LEITURA = re.compile(r"^\s*(select|with|explain|show|values|table)\b", re.I)
ESCRITA_EM_CTE = re.compile(r"\b(insert|update|delete|merge|alter|create|drop|grant|revoke|call|do|copy)\b", re.I)


def sem_comentarios(sql: str) -> str:
    """Remove comentários e o conteúdo de strings, para não confundir a análise."""
    sql = re.sub(r"/\*.*?\*/", " ", sql, flags=re.S)
    sql = re.sub(r"--[^\n]*", " ", sql)
    sql = re.sub(r"'(?:[^']|'')*'", "''", sql)
    return sql


def responder(decisao: str, motivo: str) -> None:
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": decisao,
            "permissionDecisionReason": motivo,
        }
    }, ensure_ascii=False))
    sys.exit(0)


def main() -> None:
    sys.stdout.reconfigure(encoding="utf-8")  # acentos corretos também no Windows
    dados = json.load(sys.stdin)
    entrada = dados.get("tool_input", {}) or {}
    acao = dados.get("tool_name", "").rsplit("__", 1)[-1]
    projeto = entrada.get("project_id")

    if PROJETO_PERMITIDO and projeto and projeto != PROJETO_PERMITIDO:
        responder("ask", f"Projeto {projeto} não é o {NOME_AMBIENTE} protegido por esta trava. Confirme antes de agir.")

    if acao in FERRAMENTAS_SQL:
        sql = sem_comentarios(entrada.get(FERRAMENTAS_SQL[acao], "") or "")
        baixo = sql.lower()
        for padrao, nome in PROIBIDO:
            if re.search(padrao, baixo, re.M):
                responder("deny", f"Trava do banco: {nome} é proibido no {NOME_AMBIENTE}. Não contorne; explique ao usuário.")
        comandos = [c for c in sql.split(";") if c.strip()]
        leitura = comandos and all(LEITURA.match(c) and not ESCRITA_EM_CTE.search(c) for c in comandos)
        if acao not in FERRAMENTAS_DDL and leitura:
            responder("allow", f"{NOME_AMBIENTE}: consulta somente leitura.")
        tipo = "Migration (DDL)" if acao in FERRAMENTAS_DDL else "Escrita"
        responder("ask", f"{tipo} no {NOME_AMBIENTE}. Só confirme se o usuário pediu e aprovou esta alteração no chat.")

    # Demais ferramentas que o matcher do hook enviar (deploy, pausa, branches...): sempre perguntar.
    responder("ask", f"'{acao}' altera o {NOME_AMBIENTE}. Confirme antes de seguir.")


if __name__ == "__main__":
    main()
