
function Test-IsAdmin {
    $current = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($current)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$script:currentScriptPath = if ($PSCommandPath) { $PSCommandPath } else { $MyInvocation.MyCommand.Path }

function Request-ElevatedRelaunch {
    param([string]$Reason)

    if ([string]::IsNullOrWhiteSpace($script:currentScriptPath) -or -not (Test-Path -LiteralPath $script:currentScriptPath)) {
        [System.Windows.Forms.MessageBox]::Show(
            "$Reason Relaunch this script as administrator if you want to write or clear Machine (HKLM) policies.",
            $script:appDisplayName,
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return $false
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "$Reason`r`n`r`nRelaunch as administrator now?",
        $script:appDisplayName,
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) {
        return $false
    }

    try {
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$script:currentScriptPath`" -Bootstrap -NoAdminRelaunch" -Verb RunAs
        return $true
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Administrator rights were not granted. The app will continue in the current user context.",
            $script:appDisplayName,
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return $false
    }
}

$machineRegistryPath = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"
$userRegistryPath    = "HKCU:\SOFTWARE\Policies\BraveSoftware\Brave"
$script:registryPath = $userRegistryPath
$script:toolVersion  = '0.5.0'
$script:appWindowTitle = $script:appDisplayName

function Ensure-PolicyPathExists {
    param([string]$Path)
    if (-not (Test-Path -Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
}

function Test-RegistryKeyIsEmpty {
    param([string]$Path)
    if (-not (Test-Path -Path $Path)) { return $true }

    $item = Get-Item -Path $Path -ErrorAction SilentlyContinue
    if (-not $item) { return $true }

    if ($item.GetSubKeyNames().Count -gt 0) { return $false }

    $props = (Get-ItemProperty -Path $Path -ErrorAction SilentlyContinue).PSObject.Properties |
        Where-Object { $_.Name -notlike 'PS*' }

    return ($props.Count -eq 0)
}

function Cleanup-PolicyPathTree {
    param([string]$LeafPath)

    if (Test-RegistryKeyIsEmpty -Path $LeafPath) {
        Remove-Item -Path $LeafPath -Force -ErrorAction SilentlyContinue
    }

    $parent = Split-Path -Path $LeafPath -Parent
    if ($parent -and (Test-Path -Path $parent) -and (Test-RegistryKeyIsEmpty -Path $parent)) {
        Remove-Item -Path $parent -Force -ErrorAction SilentlyContinue
    }
}

