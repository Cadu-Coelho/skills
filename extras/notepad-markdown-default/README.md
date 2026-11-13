# Markdown como padrão nas abas novas do Notepad++

Plugin pequeno (C++, uma DLL de 77 KB) que faz cada nova aba do Notepad++ abrir com a linguagem `Markdown (Default)`, em vez de texto puro. O Notepad++ não oferece isso nas Preferências: ele só deixa escolher a categoria genérica "linguagem definida pelo usuário", sem dizer qual. O plugin completa o caminho.

Resultado esperado numa aba nova, na barra de status:

`User Defined language file - Markdown (Default)`

## Como funciona

- O Notepad++ é configurado para abrir abas novas como `User Defined language file` (`lang="15"` em `NewDocDefaultSettings` do `config.xml`).
- Ao receber `NPPN_READY` e `NPPN_BUFFERACTIVATED`, o plugin confere se a aba está nessa categoria genérica e, se estiver, aciona a primeira UDL do usuário.
- Por isso `Markdown (Default)` precisa ser a primeira UDL em `%APPDATA%\Notepad++\userDefineLang.xml`. A UDL está em `config/userDefineLang.xml`.
- Nada no executável do Notepad++ é alterado. Uma versão anterior desta solução fazia patch binário do `notepad++.exe`; o plugin substituiu isso.

## Conteúdo

| Arquivo | Para quê |
| --- | --- |
| `CaduMarkdownDefault.cpp` | Fonte do plugin |
| `CaduMarkdownDefault.dll` | DLL compilada (x64), pronta para instalar |
| `config/userDefineLang.xml` | A linguagem `Markdown (Default)` |
| `REINSTALAR.ps1` | Instala a DLL (pede elevação); com `-ComConfiguracao`, instala também a UDL e ajusta a aba nova; com `-Rebuild`, recompila |
| `VERIFICAR.ps1` | Diagnóstico somente leitura: hashes, UDL e configuração da aba nova |
| `skill/SKILL.md` | Skill para o Claude Code manter o plugin por você |

SHA-256 da DLL publicada: `79F7ECC5B38D4F5200FBC8FC4F107FC2EE43715947EFED0FD16A857CAE15B6E8`. Testado no Notepad++ 8.9.8.1, 64 bits.

## Instalar

1. Instale o Notepad++ (instalador oficial, em `C:\Program Files\Notepad++`), abra uma vez e feche completamente.
2. No PowerShell, nesta pasta:

```powershell
.\REINSTALAR.ps1 -ComConfiguracao
```

O script instala a UDL como primeira linguagem e configura a aba nova, guardando cópia `.bak-<data>` do que existia, e então copia a DLL com elevação. Ele para se o Notepad++ estiver aberto.

3. Abra o Notepad++, crie uma aba e confira a barra de status. Rode `.\VERIFICAR.ps1`: todos os itens devem dar `True`.

Opcional: para preview do Markdown, use o plugin separado `NppMarkdownPanel` (Admin de Plugins do Notepad++).

## Depois de atualizar o Notepad++

Atualizações podem apagar a pasta de plugins. Feche o Notepad++ e rode `.\REINSTALAR.ps1` (sem parâmetros).

## Recompilar

Só se o fonte mudar ou se uma versão futura do Notepad++ rejeitar a DLL. Instale o MSYS2 (`winget install MSYS2.MSYS2`), no terminal MINGW64 rode `pacman -S mingw-w64-x86_64-gcc` e, com o Notepad++ fechado:

```powershell
.\REINSTALAR.ps1 -Rebuild
```

Se o MSYS2 não estiver em `C:\msys64`, defina a variável `NPP_MSYS2_SHELL` com o caminho do `msys2_shell.cmd`.

## Regras técnicas que não devem ser alteradas por engano

- `NewDocDefaultSettings` só aceita a categoria genérica `L_USER` (15).
- `Markdown (Default)` precisa ser a primeira UDL.
- `NPPM_GETNBUSERLANG` devolve o comando genérico "Definida pelo usuário"; a primeira UDL usa esse identificador mais um.
- `getFuncsArray` precisa retornar ao menos um item. Retornar zero faz o Notepad++ rejeitar o plugin (por isso existe o item de menu informativo).

## Falhas que não são deste plugin

O erro `CoreWebView2 is uninitialized` vem do `NppMarkdownPanel`, no preview. Não altere esta DLL para tentar corrigi-lo.

## Aviso

Plugin não oficial e sem assinatura digital. Se preferir não usar a DLL pronta, compile a partir do fonte com `-Rebuild`.
