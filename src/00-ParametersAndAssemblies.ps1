param(
    [switch]$NoAdminRelaunch,
    [switch]$Bootstrap
)

$script:repoOwner = 'unmatched785'
$script:repoName = 'SimpleOrigin-Brave-Debloat'
$script:scriptFileName = 'SimpleOrigin.ps1'
$script:tempFolderName = 'SimpleOrigin-Brave-Debloat'
$script:settingsFileName = 'SimpleOriginBraveDebloatSettings.json'
$script:appDisplayName = 'Simple Origin - Brave Debloat'
$script:RawSourceUrl = "https://raw.githubusercontent.com/$($script:repoOwner)/$($script:repoName)/main/$($script:scriptFileName)"

function Invoke-SimpleOriginBootstrap {
    param([switch]$NoAdminRelaunch)

    $tempRoot = Join-Path $env:TEMP $script:tempFolderName
    $tempPath = Join-Path $tempRoot $script:scriptFileName

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
        Write-Error "$($script:appDisplayName) bootstrap failed: $($_.Exception.Message)"
        return $false
    }
}

if (-not $Bootstrap -and [string]::IsNullOrWhiteSpace($MyInvocation.MyCommand.Path)) {
    if (Invoke-SimpleOriginBootstrap -NoAdminRelaunch:$NoAdminRelaunch) {
        return
    }
    return
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::SetUnhandledExceptionMode([System.Windows.Forms.UnhandledExceptionMode]::CatchException)
[System.Windows.Forms.Application]::add_ThreadException({
    param($sender, $eventArgs)
    [System.Windows.Forms.MessageBox]::Show(
        "Unexpected error: $($eventArgs.Exception.Message)",
        $script:appDisplayName,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
})

