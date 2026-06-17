$ErrorActionPreference = "Stop"

$bundledPython = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (Test-Path $bundledPython) {
    $python = $bundledPython
} else {
    $python = (Get-Command python -ErrorAction Stop).Source
}

$port = if ($env:SCRIPTROOM_PORT) { [int]$env:SCRIPTROOM_PORT } else { 8765 }
$existing = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
if ($existing) {
    Write-Host "端口 $port 已有服务在运行。"
    Write-Host "如果之前用 .\ui.ps1 启动，请先关闭旧服务后再运行 .\ui-lan.ps1。"
    exit 0
}

$ips = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object {
        $_.IPAddress -notlike "127.*" -and
        $_.IPAddress -notlike "169.254.*" -and
        $_.PrefixOrigin -ne "WellKnown"
    } |
    Select-Object -ExpandProperty IPAddress -Unique

Write-Host "编剧团队将开放给同一局域网内的电脑。"
foreach ($ip in $ips) {
    Write-Host "别人电脑打开：http://$ip`:$port"
}

& $python -m scriptroom.server --host 0.0.0.0 --port $port --open

exit $LASTEXITCODE

