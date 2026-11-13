---
name: mesa-redonda
description: Mesa redonda entre Claude, GPT (Codex CLI) e Gemini (Antigravity CLI, agy) sobre um tema do usuário. Cada modelo assume um especialista diferente, eles debatem em rodadas encadeadas (a saída de um é a entrada do próximo) até um consenso, e Claude modera e devolve a resposta consensual com as divergências que sobraram. Use quando o usuário pedir "mesa redonda", "debate entre as IAs", "coloca o GPT e o Gemini para discutir", "quero o consenso dos modelos sobre X" ou digitar /mesa-redonda.
---

# Mesa redonda

Você é o moderador. Não é participante: não defenda posição nem puxe o consenso para o seu lado. O participante "Claude" é um subagente separado, para que a sua moderação não contamine o debate.

## Antes de começar

1. **Privacidade.** O tema e qualquer documento vão para a OpenAI e o Google. Se envolver o trabalho do usuário (empresa, clientes, documentos recebidos de outra organização), dados pessoais de terceiros ou segredos, avise e só siga com confirmação explícita do usuário nesta conversa. Registre na ata que ele confirmou.
2. **Disponibilidade.** Os participantes externos rodam por `consultar.ps1` (nesta pasta da skill), que usa o login do próprio usuário em cada CLI. O Gemini roda pelo Antigravity CLI (`%LOCALAPPDATA%\agy\bin\agy.exe`, modelo `gemini-3.8-flash-high`, modo `plan`), porque o Gemini CLI deixou de aceitar conta pessoal em 18/06/2026. Se um falhar por login, diga em uma linha, siga com quem estiver disponível e registre isso no resultado. Login é sempre do usuário (`agy` ou `codex login` num terminal); nunca peça senha, código ou chave. Nunca rode os participantes com permissões liberadas (`--dangerously-skip-permissions` ou equivalentes): o script já pede resposta sem ferramentas.
3. **Pasta de trabalho.** Sempre no mesmo diretório central, valendo para qualquer projeto: `~/mesa-redonda/atas/AAAA-MM-DD-<projeto>-<slug-do-tema>/` (ou outro que o usuário tenha definido no `CLAUDE.md`). Prompts, respostas e a ata ficam ali. Não crie pasta de atas dentro do projeto.

## Debate de documento

Quando o assunto for um documento (arquivo, link, página), em vez de um tema aberto:

1. Leia o documento inteiro e salve o texto limpo como `documento.md` na pasta da mesa. Até ~60 mil caracteres vai inteiro no prompt de cada participante (o script aguenta). Acima disso, divida por seções e debata em blocos, ou combine o recorte com o usuário.
2. Pergunte ao usuário, se ele não disse, o que a mesa deve produzir: avaliação geral, riscos, decisões a tomar, sugestões de comentário ao autor. Isso vira a pergunta da mesa.
3. Escolha especialistas que olhem o documento de lados diferentes (ex.: num documento técnico de produto: arquiteto de software, especialista de negócio ou do domínio, especialista em segurança ou qualidade).
4. Na rodada 1, cada participante recebe o documento completo, o papel e a pergunta, e cita as seções em que se apoia. Nas encadeadas, mande o documento de novo junto com as falas, porque cada chamada externa começa do zero.
5. Na ata, ligue cada ponto de consenso e de divergência às seções do documento. Não publique nada no documento original (comentário, edição) sem o usuário aprovar o texto exato.

## Montagem

Defina **três especialistas** com perspectivas que realmente se oponham ou se complementem no tema (ex.: em "biscoito ou bolacha": linguista, historiador da alimentação, regionalista/sociolinguista). Atribua um a cada modelo, variando a atribuição entre mesas. Mostre a composição ao usuário em uma linha e siga sem esperar, salvo se ele pediu para aprovar antes.

## Rodadas

Limite de **3 rodadas**. Cada resposta de participante tem no máximo ~250 palavras, no idioma do usuário.

**Rodada 1, às cegas.** Cada participante recebe só o tema e o próprio papel, e responde com: posição, três argumentos mais fortes e grau de confiança (0 a 100).

**Rodadas 2 e 3, encadeadas.** A ordem gira a cada rodada. Cada participante recebe as falas mais recentes dos outros (inclusive as já produzidas nesta rodada, por isso a saída de um alimenta o próximo) e deve, nesta ordem:
1. Apontar onde discorda dos outros e por quê. Concordar sem apontar ao menos um ponto de atrito, nem que seja de ênfase, não vale.
2. Dizer o que o convenceu, se algo convenceu.
3. Dar a posição atualizada e a confiança.
4. Terminar com `CONSENSO: sim` ou `CONSENSO: não`, seguido de uma frase com a resposta que aceitaria assinar.

Pare antes da rodada 3 se todos disserem `CONSENSO: sim` com frases compatíveis.

### Prompt de cada participante

Monte em arquivo `rN-<modelo>-prompt.txt`:

```
Você participa de uma mesa redonda com outros dois especialistas.
Tema: <tema>
Seu papel: <especialista>, <o que essa perspectiva valoriza>.
Fale só a partir desse papel. Não diga que é uma IA nem mencione o modelo que você é.
<Rodada 1: instruções da rodada 1>
<Rodadas 2+: "Falas mais recentes dos outros:" + falas com o nome do papel, depois as instruções das rodadas encadeadas>
Responda em português do Brasil, em até 250 palavras.
```

### Como chamar cada um

- GPT: `powershell -File "<pasta da skill>\consultar.ps1" -Modelo gpt -Entrada <prompt> -Saida <rN-gpt.md>`
- Gemini: o mesmo com `-Modelo gemini`.
- Claude: subagente (Agent, tipo general-purpose) com o mesmo prompt, pedindo só a fala como resposta. Grave em `rN-claude.md`.

Na rodada 1 rode os três em paralelo. Nas encadeadas, em sequência. Cada chamada externa leva de 10 a 60 s; rode em segundo plano se passar disso.

## Ata e resposta ao usuário

Grave `ata.md` na pasta da mesa: tema, composição, falas por rodada e síntese. Para o usuário, devolva no chat, curto:

- **Consenso:** a resposta que a mesa assina, em um parágrafo.
- **O que ficou em aberto:** divergências que sobraram, com quem defende o quê.
- **Quem mudou de ideia e por quê**, se alguém mudou.
- Se não houve consenso em 3 rodadas, diga isso claramente e apresente as posições finais; não invente um consenso.
- Link para a ata e, se algum modelo ficou de fora, qual e por quê.
