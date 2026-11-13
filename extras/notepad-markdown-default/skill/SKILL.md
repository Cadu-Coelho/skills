---
name: notepad-markdown-default
description: Diagnosticar e manter o plugin CaduMarkdownDefault, que faz cada nova aba do Notepad++ abrir com a linguagem Markdown (Default). Use para instalar o plugin, restaurar o padrão depois de uma atualização do Notepad++ ou recompilar a DLL; não use para problemas genéricos do editor ou do preview Markdown.
---

# Markdown padrão do Notepad++

O kit fica na pasta pai desta skill (`extras/notepad-markdown-default`). Leia o `README.md` do kit e rode `VERIFICAR.ps1` antes de qualquer manutenção. A verificação é somente leitura e não abre o aplicativo.

A configuração nativa do Notepad++ só permite escolher a categoria genérica `User Defined language file` para abas novas. Não tente selecionar a UDL específica pelas Preferências. O plugin `CaduMarkdownDefault.dll` aplica a primeira UDL, que deve ser `Markdown (Default)` em `%APPDATA%\Notepad++\userDefineLang.xml`.

Para instalar ou restaurar, use `REINSTALAR.ps1` somente com o Notepad++ fechado (em computador novo, `-ComConfiguracao`). A DLL vai para `C:\Program Files\Notepad++\plugins\CaduMarkdownDefault\CaduMarkdownDefault.dll`. Se a cópia exigir privilégio de administrador, peça ao usuário a execução elevada; não contorne permissões nem altere ACLs, executáveis ou outros plugins.

Recompile (`-Rebuild`) apenas se o fonte mudar ou houver incompatibilidade demonstrada. O compilador é o MSYS2 com MinGW64 em `C:\msys64` (ou o caminho da variável `NPP_MSYS2_SHELL`).

Depois da instalação, confira os hashes com `VERIFICAR.ps1` e valide uma nova aba com o status `User Defined language file - Markdown (Default)`. Diferencie verificação dos arquivos de validação visual. O erro `CoreWebView2 is uninitialized` pertence ao plugin separado `NppMarkdownPanel` e não deve ser corrigido alterando este plugin.
