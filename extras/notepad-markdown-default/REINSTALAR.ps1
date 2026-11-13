[CmdletBinding()]
param(
    [switch]$Rebuild,
    # Maquina nova ou Notepad++ zerado: tambem instala a UDL "Markdown (Default)"
    # como primeira linguagem e configura a aba nova como "linguagem do usuario".
    [switch]$ComConfiguracao
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSCommandPath
$source = Join-Path $root 'CaduMarkdownDefault.cpp'
$dll = Join-Path $root 'CaduMarkdownDefault.dll'
$destinationDirectory = 'C:\Program Files\Notepad++\plugins\CaduMarkdownDefault'
$destination = Join-Path $destinationDirectory 'CaduMarkdownDefault.dll'
# Compilador: MSYS2 com MinGW64. Defina NPP_MSYS2_SHELL se ele estiver fora de C:\msys64.
$msysShell = if ($env:NPP_MSYS2_SHELL) { $env:NPP_MSYS2_SHELL } else { 'C:\msys64\msys2_shell.cmd' }

if (Get-Process -Name 'notepad++' -ErrorAction SilentlyContinue) {
    throw 'Feche completamente o Notepad++ antes de reinstalar o plugin.'
}

if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "Fonte local ausente: $source"
}

if ($Rebuild) {
    if (-not (Test-Path -LiteralPath $msysShell -PathType Leaf)) {
        throw "Compilador ausente. Instale o MSYS2 (winget install MSYS2.MSYS2) e, no terminal MINGW64, rode: pacman -S mingw-w64-x86_64-gcc"
    }
    $posix = '/' + $root.Substring(0,1).ToLower() + ($root.Substring(2) -replace '\\','/')
    $build = "g++ -std=c++17 -O2 -shared -static-libgcc -static-libstdc++ -o $posix/CaduMarkdownDefault.dll $posix/CaduMarkdownDefault.cpp"
    & $msysShell -defterm -no-start -mingw64 -shell bash -c $build
    if ($LASTEXITCODE -ne 0) {
        throw "Falha na compilacao, codigo $LASTEXITCODE."
    }
}

if (-not (Test-Path -LiteralPath $dll -PathType Leaf)) {
    throw "DLL local ausente: $dll"
}

# Configuracao do usuario: roda antes de pedir administrador, na conta do usuario.
# A relancada elevada nao recebe -ComConfiguracao, entao isto roda uma vez so.
if ($ComConfiguracao) {
    $nppData = Join-Path $env:APPDATA 'Notepad++'
    $udlFile = Join-Path $nppData 'userDefineLang.xml'
    $udlKit = Join-Path $root 'config\userDefineLang.xml'
    $configFile = Join-Path $nppData 'config.xml'
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    New-Item -ItemType Directory -Path $nppData -Force | Out-Null

    $primeira = $null
    if (Test-Path -LiteralPath $udlFile) {
        [xml]$atual = Get-Content -LiteralPath $udlFile -Raw
        $primeira = @($atual.NotepadPlus.UserLang)[0].name
    }
    if ($primeira -ne 'Markdown (Default)') {
        if (Test-Path -LiteralPath $udlFile) { Copy-Item -LiteralPath $udlFile "$udlFile.bak-$stamp" }
        Copy-Item -LiteralPath $udlKit -Destination $udlFile -Force
        Write-Host "UDL 'Markdown (Default)' instalada (copia anterior em .bak-$stamp, se havia)."
    } else {
        Write-Host "UDL 'Markdown (Default)' ja e a primeira; mantida."
    }

    if (Test-Path -LiteralPath $configFile) {
        [xml]$cfg = Get-Content -LiteralPath $configFile -Raw
        $no = $cfg.NotepadPlus.GUIConfigs.GUIConfig | Where-Object { $_.name -eq 'NewDocDefaultSettings' }
        if ($no -and $no.lang -ne '15') {
            Copy-Item -LiteralPath $configFile "$configFile.bak-$stamp"
            $no.SetAttribute('lang', '15')
            $cfg.Save($configFile)
            Write-Host 'Aba nova configurada como "linguagem do usuario" (lang=15).'
        } elseif ($no) {
            Write-Host 'Aba nova ja usa "linguagem do usuario"; mantida.'
        }
    } else {
        Write-Host 'config.xml ainda nao existe: abra e feche o Notepad++ uma vez e rode de novo com -ComConfiguracao.'
    }
}

$isAdministrator = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdministrator) {
    $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $PSCommandPath)
    if ($Rebuild) {
        $arguments += '-Rebuild'
    }
    $process = Start-Process -FilePath 'powershell.exe' -Verb RunAs -Wait -PassThru -ArgumentList $arguments -ErrorAction Stop
    exit $process.ExitCode
}

New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
Copy-Item -LiteralPath $dll -Destination $destination -Force

$localHash = (Get-FileHash -LiteralPath $dll -Algorithm SHA256).Hash
$installedHash = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash
if ($localHash -ne $installedHash) {
    throw 'A copia foi concluida, mas o hash da DLL instalada nao confere.'
}

Write-Host "Plugin instalado com sucesso: $destination"
Write-Host "SHA-256: $installedHash"
