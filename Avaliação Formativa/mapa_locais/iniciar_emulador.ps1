# Inicia o emulador Android usando servidores DNS que realmente respondem nesta rede.
# Em algumas redes (escola/empresa) o emulador fica sem internet porque usa um DNS
# que não responde; este script testa os DNS do computador e passa os que funcionam.
param([string]$Avd = 'Pixel_8')

$emulador = Join-Path $env:LOCALAPPDATA 'Android\Sdk\emulator\emulator.exe'
$candidatos = Get-DnsClientServerAddress -AddressFamily IPv4 |
    Where-Object { $_.ServerAddresses } |
    ForEach-Object { $_.ServerAddresses } |
    Select-Object -Unique

$validos = @()
foreach ($dns in $candidatos) {
    try {
        Resolve-DnsName 'firestore.googleapis.com' -Server $dns -Type A -DnsOnly -QuickTimeout -ErrorAction Stop | Out-Null
        $validos += $dns
    } catch { }
    if ($validos.Count -ge 2) { break }
}

$argumentos = @('-avd', $Avd)
if ($validos.Count -gt 0) {
    Write-Host "DNS usados no emulador: $($validos -join ', ')"
    $argumentos += @('-dns-server', ($validos -join ','))
} else {
    Write-Host 'Nenhum DNS testado respondeu; iniciando com a configuração padrão.'
}
Start-Process -FilePath $emulador -ArgumentList $argumentos
