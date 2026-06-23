$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$homepage = Join-Path $root 'index.html'

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw "ASSERTION FAILED: $Message"
    }
}

Assert-True (Test-Path -LiteralPath $homepage) 'Root index.html must exist'

$html = Get-Content -LiteralPath $homepage -Raw -Encoding UTF8

Assert-True ($html -match '<html\s+lang="zh-Hant"') 'Document language must be zh-Hant'
Assert-True ($html -match '<title>[^<]+</title>') 'Document must have a non-empty title'
Assert-True ($html -match 'data-research-count="4"') 'Dashboard must declare four research reports'
Assert-True ($html -match '<time[^>]+datetime="2026-06-23"') 'Dashboard must show latest update date 2026-06-23'
Assert-True ($html -match '<h1>[^<]+</h1>') 'Hero title must be one uninterrupted line of text'
Assert-True ($html -notmatch 'summary-board|LIBRARY SNAPSHOT') 'Library snapshot panel must be removed'
Assert-True ($html -match 'h1\s*\{[^}]*white-space:\s*nowrap') 'Hero title must be prevented from wrapping'

$links = [regex]::Matches(
    $html,
    '<a\b(?=[^>]*\bdata-report-link\b)(?=[^>]*\btarget="_blank")(?=[^>]*\brel="noopener")[^>]*\bhref="([^"]+)"[^>]*>',
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
)

Assert-True ($links.Count -eq 4) 'Four report links must use relative routes and safe new-tab settings'

$actualLinks = @($links | ForEach-Object { $_.Groups[1].Value })
$expectedLinks = @(
    'reports/tsmc/',
    'reports/components/',
    'reports/server-cpu/',
    'reports/ai-pcb/'
)
Assert-True (($actualLinks -join '|') -eq ($expectedLinks -join '|')) 'Links must use published relative routes'
$projectOrder = @('tsmc', 'components', 'server-cpu', 'ai-pcb')
$projectPositions = @($projectOrder | ForEach-Object { $html.IndexOf("data-project=`"$_`"") })
Assert-True (($projectPositions | Where-Object { $_ -lt 0 }).Count -eq 0) 'Every expected project identifier must be present'
Assert-True (($projectPositions[0] -lt $projectPositions[1]) -and ($projectPositions[1] -lt $projectPositions[2]) -and ($projectPositions[2] -lt $projectPositions[3])) 'Reports must be ordered newest first'

foreach ($relativePath in $actualLinks) {
    $windowsPath = $relativePath -replace '/', [System.IO.Path]::DirectorySeparatorChar
    Assert-True (Test-Path -LiteralPath (Join-Path $root $windowsPath)) "Missing report file: $relativePath"
}

Assert-True ($html -notmatch 'data-public-url') 'Homepage must not hardcode deployment URLs'
Assert-True ($html -notmatch 'xian1022\.github\.io') 'Homepage must remain portable across deployment paths'
Assert-True ($html -notmatch 'dataset\.publicUrl|link\.href\s*=') 'Homepage must not override relative links in JavaScript'
Assert-True ($html -match '@media\s*\(max-width:\s*768px\)') 'Tablet responsive styles are required'
Assert-True ($html -match '@media\s*\(max-width:\s*520px\)') 'Mobile responsive styles are required'
Assert-True ($html -match '@media\s*\(prefers-reduced-motion:\s*reduce\)') 'Reduced motion must be supported'
Assert-True ($html -match ':focus-visible') 'Visible keyboard focus styles are required'
Assert-True ($html -notmatch '(?i)(unsplash|picsum|placeholder|placehold|via\.placeholder|lorem\.space|dummyimage)') 'Placeholder media is forbidden'
Assert-True ($html -notmatch '<(?:img|video|source)\b') 'Version one must not include image or video assets'
Assert-True ($html -notmatch '<(?:script|link)\b[^>]+(?:src|href)="https?://') 'External packages and styles are forbidden'

Write-Host 'PASS: homepage structure, links, fallback behavior, and accessibility hooks are valid.'
