# Copia a configuração viva do Claude para este repositório, conforme mapa.psd1.
# Rode antes de cada commit. Não apaga nada fora desta pasta.
# Termina com uma barreira: recusa se encontrar algo parecido com segredo.

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$cfg = Import-PowerShellDataFile (Join-Path $repo 'mapa.psd1')
function Expandir([string]$p) { if ($p.StartsWith('~')) { $env:USERPROFILE + $p.Substring(1) } else { $p } }

$itens = @($cfg.Itens)
if ($cfg.IncluirMemoria) {
    Get-ChildItem (Join-Path $env:USERPROFILE '.claude\projects') -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notmatch 'scratch|Temp' -and (Test-Path (Join-Path $_.FullName 'memory')) } |
        ForEach-Object { $itens += @{ origem = (Join-Path $_.FullName 'memory'); destino = "global\memory\$($_.Name)" } }
}

$terceiros = @()
$listaTerceiros = Join-Path $repo $cfg.ArquivoSkillsTerceiros
if ($cfg.ArquivoSkillsTerceiros -and (Test-Path $listaTerceiros)) {
    $terceiros = Get-Content $listaTerceiros | Where-Object { $_.Trim() -and -not $_.StartsWith('#') }
}

foreach ($item in $itens) {
    $de = Expandir $item.origem
    $para = Join-Path $repo $item.destino
    if (-not (Test-Path $de)) {
        if (-not $item.opcional) { Write-Warning "Não encontrado: $de" }
        continue
    }
    if ((Get-Item $de).PSIsContainer) {
        if (Test-Path $para) { Remove-Item $para -Recurse -Force }
        New-Item -ItemType Directory -Force $para | Out-Null
        $xd = @($cfg.ExcluirPastas)
        if ($item.destino -eq 'global\skills') { $xd += $terceiros }
        robocopy $de $para /E /NFL /NDL /NJH /NJS /NP /XF $cfg.ExcluirArquivos /XD $xd | Out-Null
        if ($LASTEXITCODE -ge 8) { throw "robocopy falhou em $de (código $LASTEXITCODE)" }
    } else {
        New-Item -ItemType Directory -Force (Split-Path $para) | Out-Null
        Copy-Item $de $para -Force
    }
    Write-Host "ok  $($item.destino)"
}

# Barreira final: recusa se algum padrão conhecido de segredo aparecer
$padroes = @(
    'BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY', 'ghp_[A-Za-z0-9]{20,}', 'gho_[A-Za-z0-9]{20,}', 'github_pat_',
    'glpat-[A-Za-z0-9_-]{15,}', 'xox[bp]-', 'AKIA[0-9A-Z]{16}', 'sk-[A-Za-z0-9_-]{20,}', 'sk-ant-[A-Za-z0-9_-]{20,}',
    'eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.'
)
$suspeitos = Get-ChildItem $repo -Recurse -File -Force |
    Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.FullName -ne $PSCommandPath -and $_.Extension -in '.md','.json','.js','.ts','.py','.ps1','.psd1','.toml','.txt','.yaml','.yml' } |
    Select-String -Pattern $padroes -List
if ($suspeitos) {
    $suspeitos | ForEach-Object { Write-Warning "Possível segredo: $($_.Path):$($_.LineNumber)" }
    throw 'Sincronização concluída com alertas de segredo. Não faça commit antes de revisar.'
}
Write-Host 'Sincronizado sem alertas de segredo.'
