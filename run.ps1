$ErrorActionPreference = "Stop"

$bundledPython = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (Test-Path $bundledPython) {
    $python = $bundledPython
} else {
    $python = (Get-Command python -ErrorAction Stop).Source
}

if ($args.Count -eq 0) {
    & $python -m scriptroom.cli --brief examples/brief_cn.json --provider offline --output outputs/雾港回声.md
} else {
    & $python -m scriptroom.cli @args
}

exit $LASTEXITCODE

