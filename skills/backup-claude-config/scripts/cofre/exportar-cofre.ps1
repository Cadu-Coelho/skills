# Gera o cofre cifrado com as credenciais dos conectores locais (arquivos da pasta configurada e
# variáveis de usuário com os prefixos configurados em cofre-comum.ps1).
# Rode você mesmo; nenhuma senha aparece na tela.
# Uso: .\exportar-cofre.ps1            (pede a frase-senha duas vezes)

param([string]$Destino, [Security.SecureString]$Frase)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'cofre-comum.ps1')
if (-not $Destino) { $Destino = $script:CofrePadrao }

$banco = [ordered]@{}
$conexoes = Join-Path $script:PastaBanco 'connections.json'
if (Test-Path $conexoes) { $banco['connections.json'] = Get-Content -Raw $conexoes }
Get-ChildItem $script:PastaBanco -Filter '*.dpapi' -Force | ForEach-Object {
    $seguro = (Get-Content -Raw $_.FullName).Trim() | ConvertTo-SecureString
    $banco[$_.Name] = [Net.NetworkCredential]::new('', $seguro).Password
}

$vars = [ordered]@{}
$usuario = [Environment]::GetEnvironmentVariables('User')
$usuario.Keys | Where-Object { $_ -match $script:PadraoVars } | Sort-Object | ForEach-Object { $vars[$_] = $usuario[$_] }

$conteudo = [ordered]@{ versao = 1; gerado = (Get-Date).ToString('s'); computador = $env:COMPUTERNAME; banco = $banco; variaveis = $vars }
$dados = [Text.Encoding]::UTF8.GetBytes(($conteudo | ConvertTo-Json -Depth 5 -Compress))
$banco = $null; $vars = $null; $conteudo = $null

if (-not $Frase) { $Frase = Read-FraseSenha -Confirmar }
$cofre = Protect-Cofre $dados $Frase
[Array]::Clear($dados, 0, $dados.Length)

New-Item -ItemType Directory -Force (Split-Path $Destino) | Out-Null
if (Test-Path $Destino) { Copy-Item $Destino "$Destino.anterior" -Force }
[IO.File]::WriteAllBytes($Destino, $cofre)
Write-Host "Cofre gravado em $Destino"
Write-Host "Itens: $((Get-ChildItem $script:PastaBanco -Filter '*.dpapi' -Force).Count) senhas do banco, connections.json e $(($usuario.Keys | Where-Object { $_ -match $script:PadraoVars }).Count) variáveis."
Write-Host 'Guarde a frase-senha fora do Drive e do GitHub (gerenciador de senhas ou papel).'
