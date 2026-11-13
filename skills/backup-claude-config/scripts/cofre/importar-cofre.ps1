# Restaura as credenciais a partir do cofre numa máquina nova (ou confere o cofre).
# Uso:
#   .\importar-cofre.ps1 -Verificar     abre o cofre e compara com este PC, sem gravar nada
#   .\importar-cofre.ps1 -Confirmar     recria connections.json, os .dpapi e as variáveis de usuário
# Antes de sobrescrever, guarda cópia dos arquivos existentes.

param([string]$Origem, [switch]$Verificar, [switch]$Confirmar, [Security.SecureString]$Frase)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'cofre-comum.ps1')
if (-not $Origem) { $Origem = $script:CofrePadrao }
if (-not ($Verificar -or $Confirmar)) { throw 'Use -Verificar (só confere) ou -Confirmar (restaura).' }

if (-not $Frase) { $Frase = Read-FraseSenha }
$dados = Unprotect-Cofre ([IO.File]::ReadAllBytes($Origem)) $Frase
$c = [Text.Encoding]::UTF8.GetString($dados) | ConvertFrom-Json -AsHashtable
[Array]::Clear($dados, 0, $dados.Length)
Write-Host "Cofre aberto: gerado em $($c.gerado) no computador $($c.computador)."

if ($Verificar) {
    foreach ($nome in $c.banco.Keys) {
        $arq = Join-Path $script:PastaBanco $nome
        if (-not (Test-Path $arq)) { Write-Host "  $nome : ausente neste PC"; continue }
        if ($nome -like '*.dpapi') {
            $atual = [Net.NetworkCredential]::new('', ((Get-Content -Raw $arq).Trim() | ConvertTo-SecureString)).Password
        } else { $atual = Get-Content -Raw $arq }
        Write-Host ("  {0} : {1}" -f $nome, $(if ($atual -eq $c.banco[$nome]) { 'igual' } else { 'DIFERENTE' }))
    }
    foreach ($v in $c.variaveis.Keys) {
        $atual = [Environment]::GetEnvironmentVariable($v, 'User')
        Write-Host ("  {0} : {1}" -f $v, $(if ($atual -eq $c.variaveis[$v]) { 'igual' } else { 'DIFERENTE' }))
    }
    $atual = $null; $c = $null
    return
}

$carimbo = Get-Date -Format 'yyyyMMdd-HHmmss'
New-Item -ItemType Directory -Force $script:PastaBanco | Out-Null
foreach ($nome in $c.banco.Keys) {
    $arq = Join-Path $script:PastaBanco $nome
    if (Test-Path $arq) { Copy-Item $arq "$arq.backup-$carimbo" -Force }
    if ($nome -like '*.dpapi') {
        ConvertTo-SecureString $c.banco[$nome] -AsPlainText -Force | ConvertFrom-SecureString | Set-Content -LiteralPath $arq -Encoding utf8
    } else { Set-Content -LiteralPath $arq -Value $c.banco[$nome] -Encoding utf8 -NoNewline }
    Write-Host "ok  $nome"
}
foreach ($v in $c.variaveis.Keys) {
    [Environment]::SetEnvironmentVariable($v, $c.variaveis[$v], 'User')
    Write-Host "ok  variável $v"
}
$c = $null
Write-Host 'Credenciais restauradas. Feche e reabra o Claude para os conectores lerem as variáveis novas.'
