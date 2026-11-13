# Restaura a configuração do Claude a partir deste repositório numa máquina nova, conforme mapa.psd1.
# Sem -Confirmar, só simula. Faz backup de tudo que já existir antes de sobrescrever.
# Depois: restaurar as credenciais (cofre\importar-cofre.ps1), conectar os conectores da conta
# claude.ai e reinstalar as skills de terceiros.

param([switch]$Confirmar)
$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$cfg = Import-PowerShellDataFile (Join-Path $repo 'mapa.psd1')
$carimbo = Get-Date -Format 'yyyyMMdd-HHmmss'
function Expandir([string]$p) { if ($p.StartsWith('~')) { $env:USERPROFILE + $p.Substring(1) } else { $p } }

$itens = @($cfg.Itens | ForEach-Object { @{ de = $_.destino; para = (Expandir $_.origem) } })
Get-ChildItem (Join-Path $repo 'global\memory') -Directory -ErrorAction SilentlyContinue |
    ForEach-Object { $itens += @{ de = "global\memory\$($_.Name)"; para = (Join-Path $env:USERPROFILE ".claude\projects\$($_.Name)\memory") } }

# Itens ausentes no repositório são ignorados.
$itens = @($itens | Where-Object { Test-Path (Join-Path $repo $_.de) })

if (-not $Confirmar) {
    Write-Host 'Simulação. Nada foi alterado. Rode com -Confirmar para aplicar:'
    $itens | ForEach-Object { Write-Host "  $($_.de)  ->  $($_.para)" }
    return
}

foreach ($item in $itens) {
    $origem = Join-Path $repo $item.de
    if (Test-Path $item.para) {
        $bk = "$($item.para).backup-$carimbo"
        Copy-Item $item.para $bk -Recurse -Force
        Write-Host "backup  $bk"
    }
    if ((Get-Item $origem).PSIsContainer) {
        New-Item -ItemType Directory -Force $item.para | Out-Null
        robocopy $origem $item.para /E /NFL /NDL /NJH /NJS /NP | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "robocopy falhou em $origem (código $LASTEXITCODE)" }
    } else {
        New-Item -ItemType Directory -Force (Split-Path $item.para) | Out-Null
        Copy-Item $origem $item.para -Force
    }
    Write-Host "ok      $($item.para)"
}
Write-Host 'Restaurado. Siga o README para credenciais e conectores.'
