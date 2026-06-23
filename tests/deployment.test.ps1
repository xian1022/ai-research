$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$buildScript = Join-Path $root 'scripts\build-site.ps1'
$workflow = Join-Path $root '.github\workflows\pages.yml'
$site = Join-Path $root '_site'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

Assert-True (Test-Path -LiteralPath $buildScript) 'Public site build script must exist'
Assert-True (Test-Path -LiteralPath $workflow) 'GitHub Pages workflow must exist'

& $buildScript

$expectedFiles = @(
    '.nojekyll',
    'index.html',
    'reports\tsmc\index.html',
    'reports\components\index.html',
    'reports\server-cpu\index.html',
    'reports\ai-pcb\index.html'
)

$actualFiles = @(Get-ChildItem -LiteralPath $site -Recurse -File | ForEach-Object {
    $_.FullName.Substring($site.Length + 1)
})

Assert-True ((($actualFiles | Sort-Object) -join '|') -eq (($expectedFiles | Sort-Object) -join '|')) '_site must contain only approved public files'

$workflowText = Get-Content -LiteralPath $workflow -Raw -Encoding UTF8
foreach ($required in @(
    'workflow_dispatch:',
    'pages: write',
    'id-token: write',
    'cancel-in-progress: true',
    'tests/homepage.test.ps1',
    'tests/publish.test.ps1',
    'tests/deployment.test.ps1',
    'actions/upload-pages-artifact@v3',
    'actions/deploy-pages@v4',
    'path: _site'
)) {
    Assert-True ($workflowText.Contains($required)) "Workflow is missing: $required"
}

Write-Host 'PASS: deployment workflow and public artifact are restricted and valid.'
