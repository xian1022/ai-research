$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$homepage = Join-Path $root 'index.html'
$html = Get-Content -LiteralPath $homepage -Raw -Encoding UTF8

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

$routes = @('tsmc', 'cpo', 'components', 'server-cpu', 'ai-pcb')
foreach ($route in $routes) {
    $report = Join-Path $root "reports\$route\index.html"
    Assert-True (Test-Path -LiteralPath $report) "Missing public report: reports/$route/index.html"
    $reportHtml = Get-Content -LiteralPath $report -Raw -Encoding UTF8
    Assert-True ($reportHtml.Length -gt 1000) "Public report is unexpectedly small: $route"
    Assert-True ($reportHtml -match '<!DOCTYPE html>|<!doctype html>') "Public report is not HTML: $route"
    Assert-True ($html -match [regex]::Escape("href=`"reports/$route/`"")) "Homepage is missing relative URL for $route"
}

Assert-True (Test-Path -LiteralPath (Join-Path $root '.nojekyll')) '.nojekyll must exist'
Assert-True (Test-Path -LiteralPath (Join-Path $root '.gitignore')) '.gitignore must exist'
Assert-True ($html -notmatch 'data-public-url|xian1022\.github\.io') 'Published homepage must not contain hardcoded deployment URLs'

$ignored = Get-Content -LiteralPath (Join-Path $root '.gitignore') -Raw -Encoding UTF8
foreach ($entry in @('projects/', 'work/', '.agents/', '_site/')) {
    Assert-True ($ignored.Contains($entry)) ".gitignore must exclude $entry"
}

Write-Host 'PASS: GitHub Pages package and portable relative URLs are valid.'
