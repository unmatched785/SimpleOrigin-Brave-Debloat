[CmdletBinding()]
param(
    [string]$SourceDir = (Join-Path $PSScriptRoot 'src'),
    [string]$OutputPath = (Join-Path $PSScriptRoot 'SimpleOrigin.ps1')
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SourceDir)) {
    throw "Source directory not found: $SourceDir"
}

$buildOrderPath = Join-Path $SourceDir 'build-order.txt'

if (Test-Path -LiteralPath $buildOrderPath) {
    $orderedNames = Get-Content -LiteralPath $buildOrderPath |
        ForEach-Object { $_.Trim() } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    if (-not $orderedNames) {
        throw "Build order file is empty: $buildOrderPath"
    }

    $sourceFiles = foreach ($name in $orderedNames) {
        $path = Join-Path $SourceDir $name
        if (-not (Test-Path -LiteralPath $path)) {
            throw "Missing source file listed in build-order.txt: $name"
        }
        Get-Item -LiteralPath $path
    }
}
else {
    $sourceFiles = Get-ChildItem -LiteralPath $SourceDir -Filter '*.ps1' -File |
        Sort-Object Name
}

if (-not $sourceFiles) {
    throw "No source files were found in: $SourceDir"
}

$parts = foreach ($file in $sourceFiles) {
    [System.IO.File]::ReadAllText($file.FullName)
}

$compiled = [string]::Concat($parts)
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($OutputPath, $compiled, $utf8Bom)

Write-Host "Built $OutputPath from $($sourceFiles.Count) source files."
