param(
    [switch]$NoAdminRelaunch,
    [switch]$Bootstrap
)

$script:RawSourceUrl = 'https://raw.githubusercontent.com/unmatched785/SimpleOrigin/main/SimpleOrigin.ps1'

function Invoke-SimpleOriginBootstrap {
    param([switch]$NoAdminRelaunch)

    $tempRoot = Join-Path $env:TEMP 'SimpleOrigin'
    $tempPath = Join-Path $tempRoot 'SimpleOrigin.ps1'

    try {
        New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
        $content = Invoke-RestMethod -Uri $script:RawSourceUrl -Headers @{ 'Cache-Control' = 'no-cache' }
        [System.IO.File]::WriteAllText($tempPath, [string]$content, [System.Text.UTF8Encoding]::new($false))
        Unblock-File -Path $tempPath -ErrorAction SilentlyContinue

        $arguments = @(
            '-ExecutionPolicy', 'Bypass',
            '-File', $tempPath,
            '-Bootstrap'
        )

        if ($NoAdminRelaunch) {
            $arguments += '-NoAdminRelaunch'
        }

        Start-Process -FilePath 'powershell' -ArgumentList $arguments | Out-Null
        return $true
    }
    catch {
        Write-Error "SimpleOrigin bootstrap failed: $($_.Exception.Message)"
        return $false
    }
}

if (-not $Bootstrap -and [string]::IsNullOrWhiteSpace($MyInvocation.MyCommand.Path)) {
    if (Invoke-SimpleOriginBootstrap -NoAdminRelaunch:$NoAdminRelaunch) {
        return
    }
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

