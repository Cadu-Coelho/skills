# Envia um prompt (arquivo de texto) ao GPT (Codex CLI) ou ao Gemini (Antigravity CLI, agy) e grava só a resposta.
# Uso: consultar.ps1 -Modelo gpt|gemini -Entrada prompt.txt -Saida resposta.md
# Roda numa pasta vazia e em modo somente leitura: os modelos só respondem, não mexem em arquivos.
param(
    [Parameter(Mandatory)][ValidateSet('gpt', 'gemini')][string]$Modelo,
    [Parameter(Mandatory)][string]$Entrada,
    [Parameter(Mandatory)][string]$Saida
)
$ErrorActionPreference = 'Stop'
$OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false

$prompt = "Responda diretamente com o seu conhecimento, sem usar ferramentas, comandos, buscas ou arquivos.`n`n" + (Get-Content -Raw -Encoding UTF8 $Entrada)
$pasta = Join-Path $env:TEMP 'mesa-redonda-vazia'
New-Item -ItemType Directory -Force $pasta | Out-Null
$erros = Join-Path $env:TEMP "mesa-redonda-$Modelo-erro.log"

Push-Location $pasta
try {
    if ($Modelo -eq 'gpt') {
        $resposta = $prompt | codex exec --skip-git-repo-check --sandbox read-only -C $pasta - 2>$erros
    } else {
        # Gemini pelo Antigravity CLI (agy): o Gemini CLI deixou de aceitar conta pessoal em 18/06/2026.
        $agy = Join-Path $env:LOCALAPPDATA 'agy\bin\agy.exe'
        # Prompt via stdin em stream-json: o argumento -p esbarra no limite de ~32 mil caracteres do Windows.
        $linha = @{ event = 'user'; message = @{ content = $prompt } } | ConvertTo-Json -Compress -Depth 5
        $saidaJson = $linha | & $agy --input-format stream-json --output-format stream-json --model gemini-3.8-flash-high --mode plan 2>$erros
        $resultado = $saidaJson | Where-Object { $_ -match '"event"\s*:\s*"result"' } | Select-Object -Last 1 | ConvertFrom-Json
        if ($resultado.result.status -ne 'SUCCESS') { Add-Content $erros "agy: $($resultado.result.error)"; $resposta = $null }
        else { $resposta = $resultado.result.response }
    }
    $codigo = $LASTEXITCODE
} finally { Pop-Location }

$texto = ($resposta -join "`n").Trim()
if ($codigo -ne 0 -or -not $texto) {
    $detalhe = (Get-Content $erros -Tail 5 -ErrorAction SilentlyContinue) -join ' | '
    throw "Falha ao consultar $Modelo (código $codigo). $detalhe"
}
Set-Content -Path $Saida -Value $texto -Encoding UTF8
Write-Host "ok $Modelo -> $Saida"
