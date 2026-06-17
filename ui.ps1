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
    $url = "http://127.0.0.1:$port"
    Start-Process $url
    Write-Host "编剧团队 UI 已在运行：$url"
    exit 0
}

& $python -m scriptroom.server --host 127.0.0.1 --port $port --open

exit $LASTEXITCODE
