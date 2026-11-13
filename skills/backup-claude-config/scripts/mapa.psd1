# O que entra no backup: cada item liga um caminho do computador a uma pasta do repositório.
# Usado por sincronizar.ps1 (computador -> repositório) e restaurar.ps1 (repositório -> computador).
# ~ vira a pasta do usuário. opcional = $true: sem aviso se o caminho não existir.
@{
    Itens = @(
        # Global
        @{ origem = '~\.claude\CLAUDE.md';        destino = 'global\CLAUDE.md' }
        @{ origem = '~\.claude\settings.json';    destino = 'global\settings.json' }
        @{ origem = '~\.claude\skills';           destino = 'global\skills' }
        @{ origem = '~\.claude\scheduled-tasks';  destino = 'global\scheduled-tasks'; opcional = $true }

        # Um bloco por projeto (exemplo)
        @{ origem = 'C:\Projetos\MeuProjeto\CLAUDE.md'; destino = 'projetos\meu-projeto\CLAUDE.md'; opcional = $true }
        @{ origem = 'C:\Projetos\MeuProjeto\.mcp.json'; destino = 'projetos\meu-projeto\.mcp.json'; opcional = $true }
        @{ origem = 'C:\Projetos\MeuProjeto\.claude';   destino = 'projetos\meu-projeto\.claude';   opcional = $true }
    )

    # Copia também a memória do Claude (~/.claude/projects/<pasta>/memory).
    IncluirMemoria = $true

    # Skills de terceiros não são copiadas: reinstale pela origem. Um nome de pasta por linha.
    ArquivoSkillsTerceiros = 'skills-terceiros.txt'

    # Nunca copiar.
    ExcluirArquivos = @('*.dpapi', 'connections.json', '*.log', '.env*', 'auth.json', '.credentials.json')
    ExcluirPastas   = @('node_modules', '__pycache__', 'vendor', '.git')
}
