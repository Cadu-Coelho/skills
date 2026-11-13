# Funções comuns do cofre de credenciais. Não contém segredos. Requer PowerShell 7.
# Formato do arquivo: "CLCOFRE1" + sal(16) + nonce(12) + tag(16) + texto cifrado (AES-256-GCM),
# chave derivada da frase-senha por PBKDF2-SHA256 com 600.000 iterações.

# Ajuste estes três valores para o seu caso:
# pasta com os arquivos de credencial dos conectores locais (connections.json e senhas .dpapi),
# prefixos das variáveis de usuário com tokens, e onde gravar o cofre (uma pasta sincronizada na nuvem).
$script:PastaBanco   = Join-Path $env:USERPROFILE 'conectores\banco'
$script:PadraoVars   = '^(MEU_SERVICO_|OUTRO_SERVICO_)'
$script:CofrePadrao  = Join-Path $env:USERPROFILE 'Google Drive\Backup Claude\cofre-credenciais.bin'
$script:Magica       = [Text.Encoding]::ASCII.GetBytes('CLCOFRE1')
$script:Iteracoes    = 600000

function Get-ChaveCofre([Security.SecureString]$Frase, [byte[]]$Sal) {
    $texto = [Net.NetworkCredential]::new('', $Frase).Password
    try {
        $kdf = [Security.Cryptography.Rfc2898DeriveBytes]::new($texto, $Sal, $script:Iteracoes, [Security.Cryptography.HashAlgorithmName]::SHA256)
        try { return $kdf.GetBytes(32) } finally { $kdf.Dispose() }
    } finally { $texto = $null }
}

function Protect-Cofre([byte[]]$Dados, [Security.SecureString]$Frase) {
    $sal = [Security.Cryptography.RandomNumberGenerator]::GetBytes(16)
    $nonce = [Security.Cryptography.RandomNumberGenerator]::GetBytes(12)
    $chave = Get-ChaveCofre $Frase $sal
    $cifra = [byte[]]::new($Dados.Length); $tag = [byte[]]::new(16)
    $aes = [Security.Cryptography.AesGcm]::new($chave, 16)
    try { $aes.Encrypt($nonce, $Dados, $cifra, $tag) } finally { $aes.Dispose(); [Array]::Clear($chave, 0, 32) }
    return [byte[]]($script:Magica + $sal + $nonce + $tag + $cifra)
}

function Unprotect-Cofre([byte[]]$Arquivo, [Security.SecureString]$Frase) {
    if ([Text.Encoding]::ASCII.GetString($Arquivo, 0, 8) -ne 'CLCOFRE1') { throw 'Arquivo não é um cofre válido.' }
    $sal = $Arquivo[8..23]; $nonce = $Arquivo[24..35]; $tag = $Arquivo[36..51]
    $cifra = [byte[]]$Arquivo[52..($Arquivo.Length - 1)]
    $chave = Get-ChaveCofre $Frase ([byte[]]$sal)
    $dados = [byte[]]::new($cifra.Length)
    $aes = [Security.Cryptography.AesGcm]::new($chave, 16)
    try { $aes.Decrypt([byte[]]$nonce, $cifra, [byte[]]$tag, $dados) }
    catch { throw 'Frase-senha incorreta ou cofre corrompido.' }
    finally { $aes.Dispose(); [Array]::Clear($chave, 0, 32) }
    return $dados
}

function Read-FraseSenha([switch]$Confirmar) {
    $f1 = Read-Host 'Frase-senha do cofre' -AsSecureString
    if ($Confirmar) {
        $t1 = [Net.NetworkCredential]::new('', $f1).Password
        if ($t1.Length -lt 14) { throw 'Use uma frase-senha com pelo menos 14 caracteres.' }
        $f2 = Read-Host 'Repita a frase-senha' -AsSecureString
        if ($t1 -ne [Net.NetworkCredential]::new('', $f2).Password) { throw 'As frases-senha não conferem.' }
        $t1 = $null
    }
    return $f1
}
