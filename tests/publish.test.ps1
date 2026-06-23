$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$homepage = Join-Path $root 'index.html'
$html = Get-Content -LiteralPath $homepage -Raw -Encoding UTF8
$baseUrl = 'https://xian1022.github.io/ai-research'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

$routes = @('tsmc', 'components', 'server-cpu', 'ai-pcb')
foreach ($route in $routes) {
    $report = Join-Path $root "reports\$route\index.html"
    Assert-True (Test-Path -LiteralPath $report) "Missing public report: reports/$route/index.html"
    $reportHtml = Get-Content -LiteralPath $report -Raw -Encoding UTF8
    Assert-True ($reportHtml.Length -gt 1000) "Public report is unexpectedly small: $route"
    Assert-True ($reportHtml -match '<!DOCTYPE html>|<!doctype html>') "Public report is not HTML: $route"
    Assert-True ($html -match [regex]::Escape("data-public-url=`"$baseUrl/reports/$route/`"")) "Homepage is missing production URL for $route"
}

Assert-True (Test-Path -LiteralPath (Join-Path $root '.nojekyll')) '.nojekyll must exist'
Assert-True (Test-Path -LiteralPath (Join-Path $root '.gitignore')) '.gitignore must exist'
Assert-True ($html -notmatch 'data-public-url=""') 'Every report must have a production URL'

$ignored = Get-Content -LiteralPath (Join-Path $root '.gitignore') -Raw -Encoding UTF8
foreach ($entry in @('projects/', 'work/', '.agents/')) {
    Assert-True ($ignored.Contains($entry)) ".gitignore must exclude $entry"
}

Write-Host 'PASS: GitHub Pages package and production URLs are valid.'
