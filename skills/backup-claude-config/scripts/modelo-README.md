# Configuração do Claude

Repositório **privado** com a configuração do Claude Code: preferências, skills próprias, regras, travas, automações e `.mcp.json` dos projetos. Não contém credenciais nem dados de trabalho.

## Estrutura

| Pasta | Conteúdo | Origem no computador |
| --- | --- | --- |
| `global/` | `CLAUDE.md`, `settings.json`, skills, tarefas agendadas, memória | `~/.claude/` |
| `projetos/<nome>/` | `CLAUDE.md`, `.mcp.json`, `.claude/` | pasta do projeto |

O que entra está em `mapa.psd1`.

## Rotina

1. `.\sincronizar.ps1`. Com alerta de segredo, pare e revise.
2. `git status`. Sem mudanças, está em dia.
3. Com mudanças: commit com resumo e push.

## Recuperação de desastre

| Ordem | Camada | O que volta | Como |
| --- | --- | --- | --- |
| 1 | Conta Claude (nuvem) | Conectores da conta, artefatos, chats | Entrar na conta no app novo e conferir os conectores |
| 2 | Este repositório | Preferências, skills, regras, travas, automações | `gh repo clone <usuario>/claude-config`, depois `restaurar.ps1 -Confirmar` |
| 3 | Cofre de credenciais | Senhas e tokens dos conectores locais | `cofre\importar-cofre.ps1 -Confirmar` com a frase-senha |
| 4 | Backup de arquivos | Dados de trabalho | Restaurar do backup de arquivos. Nunca guardar esses dados no Git |
| 5 | Skills de terceiros | Lista em `skills-terceiros.txt` | Reinstalar pela origem, revisando antes |

Depois de restaurar, abrir uma sessão nova e testar os conectores em leitura.

## Cofre de credenciais

O arquivo cifrado fica em `<pasta na nuvem>\cofre-credenciais.bin`, nunca aqui. A frase-senha fica fora da nuvem e do Git.

## Nunca versionar

Arquivos de credencial, tokens, arquivos de conexão, histórico de conversas e dados de trabalho.
