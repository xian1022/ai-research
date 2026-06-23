$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$site = Join-Path $root '_site'
$routes = @('tsmc', 'cpo', 'components', 'server-cpu', 'ai-pcb')

if (Test-Path -LiteralPath $site) {
    Remove-Item -LiteralPath $site -Recurse -Force
}

New-Item -ItemType Directory -Path $site | Out-Null
Copy-Item -LiteralPath (Join-Path $root '.nojekyll') -Destination $site
Copy-Item -LiteralPath (Join-Path $root 'index.html') -Destination $site

foreach ($route in $routes) {
    $source = Join-Path $root "reports\$route\index.html"
    $destination = Join-Path $site "reports\$route"

    if (-not (Test-Path -LiteralPath $source)) {
        throw "Missing public report: reports/$route/index.html"
    }

    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    Copy-Item -LiteralPath $source -Destination (Join-Path $destination 'index.html')
}

Write-Host 'Built restricted GitHub Pages artifact in _site.'
