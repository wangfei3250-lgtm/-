$ErrorActionPreference = "Stop"

$bundledPython = Join-Path $env:USERPROFILE ".cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if (Test-Path $bundledPython) {
    $python = $bundledPython
} else {
    $python = (Get-Command python -ErrorAction Stop).Source
}

& $python -m unittest discover -s tests
exit $LASTEXITCODE

