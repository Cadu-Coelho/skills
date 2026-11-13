---
name: backup-claude-config
description: Monta e opera um backup versionado da configuração do Claude Code (CLAUDE.md, settings, skills próprias, regras, hooks, memória, tarefas agendadas e .mcp.json dos projetos) num repositório Git privado, com barreira contra segredos, restauração em máquina nova e um cofre cifrado (AES-256-GCM) para as credenciais dos conectores locais. Use quando o usuário pedir "backup da minha configuração do Claude", "versionar minhas skills", "preparar para trocar de computador", "recuperação de desastre", ou perguntar se há algo para atualizar no backup.
---

# Backup da configuração do Claude

Três camadas, cada uma no lugar certo:

| Camada | Onde fica | O que guarda |
| --- | --- | --- |
| Configuração | Repositório Git **privado** | `CLAUDE.md`, `settings.json`, skills próprias, `.claude/rules/`, hooks, memória, tarefas agendadas, `.mcp.json` dos projetos |
| Credenciais | Arquivo cifrado numa pasta sincronizada na nuvem (Google Drive, OneDrive), **nunca no Git** | Senhas e tokens dos conectores locais |
| Dados de trabalho | Backup de arquivos comum | Documentos, planilhas, código dos projetos |

Os scripts estão em `scripts/` desta skill. Requerem Windows e PowerShell 7.

## Montar (uma vez)

1. Crie uma pasta para o repositório (ex.: `~/claude-config`) e copie para ela o conteúdo de `scripts/` (inclusive `.gitignore`).
2. Edite `mapa.psd1` com o usuário: o que é global, quais projetos entram e quais arquivos de cada um. Liste em `skills-terceiros.txt` as skills instaladas de terceiros (elas são reinstaladas pela origem, não copiadas).
3. Rode `.\sincronizar.ps1` e revise o que entrou. A barreira final recusa se achar padrões de segredo (chaves privadas, tokens do GitHub, GitLab, Slack, AWS, OpenAI, Anthropic, JWT). Com alerta, não faça commit: mostre ao usuário.
4. Crie o repositório **privado** e faça o primeiro commit e push só com aprovação do usuário. Antes, confira se `git status` não mostra nada de credencial ou dado de trabalho.
5. Escreva o `README.md` do repositório a partir de `modelo-README.md`, com a ordem de recuperação de desastre preenchida.

## Cofre de credenciais

- Ajuste no topo de `cofre/cofre-comum.ps1`: a pasta dos arquivos de credencial, os prefixos das variáveis de usuário com tokens e o caminho do cofre na nuvem.
- **Gerar ou atualizar:** o usuário roda `.\cofre\exportar-cofre.ps1` (pede a frase-senha duas vezes, mínimo 14 caracteres). Refaça sempre que trocar uma senha ou um token. A versão anterior fica como `.anterior`.
- **Conferir:** `.\cofre\importar-cofre.ps1 -Verificar` compara o cofre com o computador atual e mostra só "igual" ou "DIFERENTE", nunca valores.
- **Restaurar:** `.\cofre\importar-cofre.ps1 -Confirmar` recria os arquivos e as variáveis, guardando cópia do que existir.
- Formato: AES-256-GCM, chave derivada da frase-senha por PBKDF2-SHA256 com 600.000 iterações. Sem a frase o arquivo não serve para nada. A frase fica com o usuário, fora da nuvem e do Git.
- Você nunca pede nem digita a frase-senha: quem roda os comandos do cofre é o usuário.

## Rotina

Combine com o usuário o gatilho. O modelo que funciona bem: sem envio automático; quando ele perguntar "tem algo para atualizar no backup?", rode `sincronizar.ps1`, confira `git status` e, se houver mudança, mostre o resumo e faça commit e push conforme a regra de aprovação que ele definiu.

## Máquina nova

1. Instale Git, PowerShell 7 e o Claude Code; clone o repositório.
2. `.\restaurar.ps1` (simulação) e depois `.\restaurar.ps1 -Confirmar`. Tudo que já existir ganha backup antes.
3. Credenciais: `.\cofre\importar-cofre.ps1 -Confirmar`.
4. Conectores da conta claude.ai: reconectar em Configurações > Conectores.
5. Reinstalar as skills de terceiros.
6. Abrir uma sessão e testar os conectores em leitura.

## Nunca versionar

Arquivos de credencial (`.dpapi`, `auth.json`, `.claude.json`, `.credentials.json`, `.env`), tokens, arquivos de conexão com endereços internos, histórico de conversas e dados de trabalho. A memória do Claude pode conter dados pessoais: por isso o repositório é privado.
