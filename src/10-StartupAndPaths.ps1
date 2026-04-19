
function Test-IsAdmin {
    $current = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($current)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not $NoAdminRelaunch -and -not (Test-IsAdmin)) {
    try {
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`" -NoAdminRelaunch" -Verb RunAs
        exit
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Administrator rights were not granted. The app will continue, but machine-level Apply/Reset may fail.",
            "Simple Origin",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
    }
}

$machineRegistryPath = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"
$userRegistryPath    = "HKCU:\SOFTWARE\Policies\BraveSoftware\Brave"
$script:registryPath = $machineRegistryPath
$script:toolVersion  = '0.3.2'

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

