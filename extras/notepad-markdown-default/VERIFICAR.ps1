[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSCommandPath
$localDll = Join-Path $root 'CaduMarkdownDefault.dll'
$installedDll = 'C:\Program Files\Notepad++\plugins\CaduMarkdownDefault\CaduMarkdownDefault.dll'
$udlFile = Join-Path $env:APPDATA 'Notepad++\userDefineLang.xml'

function Get-Sha256OrMissing([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return 'AUSENTE'
    }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

$markdownIsFirst = $false
if (Test-Path -LiteralPath $udlFile -PathType Leaf) {
    [xml]$udl = Get-Content -LiteralPath $udlFile -Raw
    $firstLanguage = @($udl.NotepadPlus.UserLang)[0]
    $markdownIsFirst = $firstLanguage.name -eq 'Markdown (Default)'
}

$abaNovaLang = 'AUSENTE'
$configFile = Join-Path $env:APPDATA 'Notepad++\config.xml'
if (Test-Path -LiteralPath $configFile -PathType Leaf) {
    [xml]$cfg = Get-Content -LiteralPath $configFile -Raw
    $abaNovaLang = ($cfg.NotepadPlus.GUIConfigs.GUIConfig | Where-Object { $_.name -eq 'NewDocDefaultSettings' }).lang
}

[pscustomobject]@{
    NotepadAberto = [bool](Get-Process -Name 'notepad++' -ErrorAction SilentlyContinue)
    DllLocal = $localDll
    HashDllLocal = Get-Sha256OrMissing $localDll
    DllInstalada = $installedDll
    HashDllInstalada = Get-Sha256OrMissing $installedDll
    UdlExiste = Test-Path -LiteralPath $udlFile -PathType Leaf
    MarkdownDefaultEhPrimeiraUdl = $markdownIsFirst
    AbaNovaUsaLinguagemUsuario = ($abaNovaLang -eq '15')
} | Format-List
