<div align="center">

<img src="assets/cadu.png" alt="Cadu Coelho" width="140">

# Skills do Cadu para o Claude Code

**Skills em português para trabalhar melhor com o Claude Code:** debate entre IAs, continuidade de projetos longos, migração do Codex, backup da configuração e travas de segurança para bancos de dados.

[![Licença MIT](https://img.shields.io/badge/licen%C3%A7a-MIT-blue.svg)](LICENSE)
![Claude Code](https://img.shields.io/badge/Claude%20Code-skills-d97757)
![Idioma](https://img.shields.io/badge/idioma-pt--BR-green)

[Instalar](#instalar) · [Skills](#skills) · [Extras](#extras) · [English](#english-summary)

</div>

---

## Quem sou

Sou [Cadu Coelho](https://github.com/Cadu-Coelho): 25 anos transformando ideias em realidade, CEO da KYROG e palestrante. Trabalho com requisitos, produto e automação com IA, e uso o Claude Code todos os dias em projetos de trabalho e pessoais. Estas skills nasceram desse uso real: cada uma resolve um problema que eu tive de verdade e foi testada antes de vir para cá.

## Instalar

No Claude Code, adicione este repositório como marketplace de plugins:

```
/plugin marketplace add Cadu-Coelho/skills
```

Depois instale só o que quiser, por exemplo:

```
/plugin install mesa-redonda@cadu-skills
```

Ou copie a pasta da skill para `~/.claude/skills/` (todos os projetos) ou para `.claude/skills/` de um projeto.

## Skills

| Skill | O que faz | Precisa de |
| --- | --- | --- |
| [**mesa-redonda**](skills/mesa-redonda) | Claude, GPT e Gemini assumem especialistas diferentes e debatem em rodadas encadeadas até um consenso. O Claude modera e entrega a resposta consensual, as divergências que sobraram e quem mudou de ideia. | Codex CLI e Antigravity CLI logados, PowerShell |
| [**retomar-projeto**](skills/retomar-projeto) | Retoma um projeto depois de dias ou semanas: lê o guia e o histórico, compara com o estado atual e segue sem refazer o diagnóstico inteiro. | |
| [**novo-chat**](skills/novo-chat) | Cria um chat novo do projeto já padronizado: arquivo de contexto em 10 seções, índice e grupo na barra lateral. | App desktop do Claude |
| [**webaudit360**](skills/webaudit360) | Auditoria de sites em arquitetura, desempenho, UX, acessibilidade, segurança, privacidade, SEO, conversão e autenticidade visual, separando o que foi medido do que foi inferido. | |
| [**migrar-do-codex**](skills/migrar-do-codex) | Roteiro para trazer projetos do OpenAI Codex para o Claude Code: inventário, regras em `.claude/rules/`, cópia 80/20, contextos por frente e validação cruzada feita pelo próprio Codex. | |
| [**backup-claude-config**](skills/backup-claude-config) | Backup da configuração do Claude Code num Git privado, com barreira contra segredos, restauração em máquina nova e cofre AES-256-GCM para as credenciais. | Windows, PowerShell 7 |
| [**trava-banco-por-hook**](skills/trava-banco-por-hook) | Hook `PreToolUse` para conectores de banco (Supabase, Postgres): leitura livre, escrita pede confirmação, `DROP`, `TRUNCATE` e desligar RLS são bloqueados. | Python |

| [**fluxo**](skills/fluxo) | Menu (com submenus, por clique ou número) para escolher como tocar um trabalho de código: direto, ciclo completo (afinar a ideia, spec, tarefas, implementar com teste, revisar), uma etapa só ou apoio para entender. Conduz as skills do Matt Pocock sem você decorar comandos. | Plugin [mattpocock-skills](#skills-de-terceiros-que-uso-e-recomendo) |

### Destaque: mesa redonda

```
Você: /mesa-redonda vale a pena reescrever o sistema legado ou evoluir aos poucos?

Mesa: arquiteto de software (GPT) · gerente de produto (Gemini) · especialista em risco operacional (Claude)
Rodada 1 às cegas → rodadas 2 e 3 encadeadas, cada um rebatendo os outros
Consenso: ...    Em aberto: ...    Quem mudou de ideia: ...    Ata completa em ~/mesa-redonda/atas/
```

Cada modelo responde sem ferramentas e sem acesso a arquivos. Antes de enviar qualquer coisa para a OpenAI ou o Google, a skill avisa se o tema envolve dados de trabalho ou de terceiros.

## Skills de terceiros que uso e recomendo

**[Skills For Real Engineers](https://github.com/mattpocock/skills), de Matt Pocock** (licença MIT). Uso no dia a dia e recomendo. É um pacote de skills para trabalhar com o agente em ciclo, em vez de pedir "faz aí": entrevista para afinar a ideia (`grill-me`), spec (`to-spec`), tarefas pequenas de ponta a ponta (`to-tickets`), implementação com teste primeiro (`tdd`), revisão contra padrões e spec (`code-review`), diagnóstico de bugs difíceis e outras. As skills são dele, não deste repositório. Minha skill [**fluxo**](skills/fluxo) só oferece um menu em português por cima delas.

```
/plugin marketplace add mattpocock/skills
/plugin install mattpocock-skills@mattpocock
```

## Extras

| Pasta | O que é |
| --- | --- |
| [**notepad-markdown-default**](extras/notepad-markdown-default) | Plugin para o Notepad++ (C++, código-fonte e DLL) que faz toda aba nova abrir em Markdown, com scripts de instalação e verificação e uma skill para o Claude manter o plugin. |

## Princípios

- **Português do Brasil** nas instruções e nas respostas.
- **Nada acontece fora do computador sem confirmação:** commit, push, publicação, envio de mensagem e escrita em banco sempre passam pelo usuário.
- **Credenciais nunca entram em arquivos de texto:** as skills só citam variáveis e cofres pelo nome.
- **Evidência antes de afirmação:** as skills distinguem o que foi testado do que foi apenas preparado.

## Contribuir

Achou um erro ou tem uma ideia? Abra uma issue. Pull requests são bem-vindos, de preferência pequenos e com o caso de uso que motivou a mudança.

## Estrutura do repositório

```
.claude-plugin/marketplace.json   instala tudo com /plugin marketplace add
skills/
├── mesa-redonda/                 SKILL.md + consultar.ps1
├── retomar-projeto/
├── novo-chat/
├── webaudit360/                  SKILL.md + references/
├── migrar-do-codex/              SKILL.md + modelos/
├── backup-claude-config/         SKILL.md + scripts/ (sincronizar, restaurar, cofre)
├── trava-banco-por-hook/         SKILL.md + trava-banco.py + exemplo-settings.json
└── fluxo/                        SKILL.md (menu sobre o pacote do Matt Pocock)
extras/
└── notepad-markdown-default/     plugin C++, DLL, scripts e skill
assets/                           imagens do README
```

## Licença

[MIT](LICENSE). Use, adapte e redistribua à vontade, mantendo o aviso de copyright.

---

## English summary

Claude Code skills written in Brazilian Portuguese, built and tested in daily real-world use.

- **mesa-redonda** (round table): Claude, GPT (Codex CLI) and Gemini (Antigravity CLI) role-play different experts and debate in chained rounds until they reach a consensus, with Claude as moderator.
- **retomar-projeto**: resume a project after a break by diffing the documented state against the current one, without redoing the whole analysis.
- **novo-chat**: create a standardized chat session for a project (10-section context file, index, sidebar group) in the Claude desktop app.
- **webaudit360**: multidisciplinary website audit with evidence levels and a prioritized roadmap.
- **migrar-do-codex**: playbook for migrating from OpenAI Codex to Claude Code, ending with a cross-check performed by Codex itself.
- **backup-claude-config**: versioned backup of your Claude Code setup in a private Git repo, with a secret-scanning gate, restore script and an AES-256-GCM credential vault.
- **trava-banco-por-hook** (database guard): a `PreToolUse` hook that allows reads, asks before writes and blocks destructive SQL on MCP database connectors.
- **fluxo** (workflow menu): a numbered menu with submenus to pick how to run a coding task (direct, full cycle, a single stage, or learning support), driving Matt Pocock's skills so you don't have to memorize commands. Requires his plugin, which I use and recommend: https://github.com/mattpocock/skills.
- **Extras:** a small Notepad++ plugin (C++) that makes every new tab default to Markdown.

Install with `/plugin marketplace add Cadu-Coelho/skills`. Licensed under MIT.
