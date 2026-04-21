function Get-ManagedPolicyKeys {
    $keys = @(
        ($featureCatalog | ForEach-Object { $_.Key } | Select-Object -Unique)
        $legacyManagedPolicyKeys
        'DnsOverHttpsMode'
        'DnsOverHttpsTemplates'
    ) | Select-Object -Unique

    return @($keys)
}

function Get-PolicySetting {
    param([string]$Key)
    $machineSettings = Get-ItemProperty -Path $machineRegistryPath -ErrorAction SilentlyContinue
    $userSettings    = Get-ItemProperty -Path $userRegistryPath -ErrorAction SilentlyContinue

    if ($machineSettings -and ($machineSettings.PSObject.Properties.Name -contains $Key)) {
        return @{ Scope = 'Machine'; Value = $machineSettings.$Key }
    }
    if ($userSettings -and ($userSettings.PSObject.Properties.Name -contains $Key)) {
        return @{ Scope = 'User'; Value = $userSettings.$Key }
    }
    return $null
}

function Get-ManagedScopeSummary {
    $keys = @(Get-ManagedPolicyKeys)
    $machineSettings = Get-ItemProperty -Path $machineRegistryPath -ErrorAction SilentlyContinue
    $userSettings    = Get-ItemProperty -Path $userRegistryPath -ErrorAction SilentlyContinue

    $machineCount = 0
    $userCount = 0

    foreach ($key in $keys) {
        if ($machineSettings -and ($machineSettings.PSObject.Properties.Name -contains $key)) {
            $machineCount++
        }
        if ($userSettings -and ($userSettings.PSObject.Properties.Name -contains $key)) {
            $userCount++
        }
    }

    $preferredScope = if ($machineCount -gt 0) { 'Machine' } elseif ($userCount -gt 0) { 'User' } else { 'User' }

    return [pscustomobject]@{
        HasMachine     = ($machineCount -gt 0)
        HasUser        = ($userCount -gt 0)
        MachineCount   = $machineCount
        UserCount      = $userCount
        IsMixed        = ($machineCount -gt 0 -and $userCount -gt 0)
        PreferredScope = $preferredScope
    }
}

function Get-WriteScopeInfo {
    param([string]$ScopeSelection)

    $targetPath = if ([string]$ScopeSelection -like 'User (HKCU)*') { $userRegistryPath } else { $machineRegistryPath }
    $otherPath  = if ($targetPath -eq $userRegistryPath) { $machineRegistryPath } else { $userRegistryPath }
    $scopeName  = if ($targetPath -eq $userRegistryPath) { 'User' } else { 'Machine' }

    return [pscustomobject]@{
        TargetPath = $targetPath
        OtherPath  = $otherPath
        ScopeName  = $scopeName
    }
}

function Set-ManagedPropertyAtPath {
    param(
        [string]$Path,
        [string]$Key,
        [object]$Value,
        [string]$Type
    )

    Ensure-PolicyPathExists -Path $Path
    Set-ItemProperty -Path $Path -Name $Key -Value $Value -Type $Type -Force
}

function Remove-ManagedPropertyFromPath {
    param(
        [string]$Key,
        [string]$Path
    )

    try {
        if (-not (Test-Path -Path $Path)) {
            return $true
        }

        $item = Get-ItemProperty -Path $Path -ErrorAction SilentlyContinue
        if ($item -and ($item.PSObject.Properties.Name -contains $Key)) {
            Remove-ItemProperty -Path $Path -Name $Key -ErrorAction Stop
        }

        Cleanup-PolicyPathTree -LeafPath $Path
        return $true
    }
    catch {
        return $false
    }
}

function Remove-ManagedPropertyEverywhere {
    param([string]$Key)

    [void](Remove-ManagedPropertyFromPath -Key $Key -Path $machineRegistryPath)
    [void](Remove-ManagedPropertyFromPath -Key $Key -Path $userRegistryPath)
}

function Add-OtherScopeWarning {
    param(
        [System.Collections.ArrayList]$Warnings,
        [string]$ScopeName,
        [string]$Key
    )

    $label = "${ScopeName}:$Key"
    if (-not $Warnings.Contains($label)) {
        [void]$Warnings.Add($label)
    }
}

function Clear-OtherScopeManagedProperty {
    param(
        [string]$Key,
        [string]$OtherPath,
        [string]$OtherScopeName,
        [System.Collections.ArrayList]$OtherScopeWarnings
    )

    if (-not (Remove-ManagedPropertyFromPath -Key $Key -Path $OtherPath)) {
        Add-OtherScopeWarning -Warnings $OtherScopeWarnings -ScopeName $OtherScopeName -Key $Key
    }
}

function Set-DnsSettings {
    param(
        [string]$DnsMode,
        [string]$DnsTemplates,
        [string]$TargetPath,
        [string]$OtherPath,
        [string]$TargetScopeName,
        [System.Collections.ArrayList]$OtherScopeWarnings
    )

    $resolvedMode = $DnsMode
    $otherScopeName = if ($TargetScopeName -eq 'User') { 'Machine' } else { 'User' }

    if ([string]::IsNullOrWhiteSpace($DnsMode) -or $DnsMode -eq 'browser default (unset)') {
        [void](Remove-ManagedPropertyFromPath -Key 'DnsOverHttpsMode' -Path $TargetPath)
        [void](Remove-ManagedPropertyFromPath -Key 'DnsOverHttpsTemplates' -Path $TargetPath)
        Clear-OtherScopeManagedProperty -Key 'DnsOverHttpsMode' -OtherPath $OtherPath -OtherScopeName $otherScopeName -OtherScopeWarnings $OtherScopeWarnings
        Clear-OtherScopeManagedProperty -Key 'DnsOverHttpsTemplates' -OtherPath $OtherPath -OtherScopeName $otherScopeName -OtherScopeWarnings $OtherScopeWarnings
        return $true
    }

    if ($DnsMode -eq 'custom') {
        if ([string]::IsNullOrWhiteSpace($DnsTemplates)) {
            [System.Windows.Forms.MessageBox]::Show(
                'Custom DoH requires a template URL, e.g. https://cloudflare-dns.com/dns-query',
                $script:appDisplayName,
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            ) | Out-Null
            return $false
        }

        $resolvedMode = 'secure'
        Set-ManagedPropertyAtPath -Path $TargetPath -Key 'DnsOverHttpsTemplates' -Value $DnsTemplates -Type String
    }
    else {
        [void](Remove-ManagedPropertyFromPath -Key 'DnsOverHttpsTemplates' -Path $TargetPath)
    }

    Set-ManagedPropertyAtPath -Path $TargetPath -Key 'DnsOverHttpsMode' -Value $resolvedMode -Type String
    Clear-OtherScopeManagedProperty -Key 'DnsOverHttpsMode' -OtherPath $OtherPath -OtherScopeName $otherScopeName -OtherScopeWarnings $OtherScopeWarnings
    Clear-OtherScopeManagedProperty -Key 'DnsOverHttpsTemplates' -OtherPath $OtherPath -OtherScopeName $otherScopeName -OtherScopeWarnings $OtherScopeWarnings
    return $true
}

function Detect-DnsPresetName {
    param([string]$Template)

    if ([string]::IsNullOrWhiteSpace($Template)) {
        return 'Manual'
    }

    if ($Template -eq $dohPresets['NextDNS Public']) {
        return 'NextDNS Public'
    }
    if ($Template -match '^https://dns\.nextdns\.io/[^/]+$') {
        return 'NextDNS Custom Profile'
    }

    foreach ($presetName in $dohPresets.Keys) {
        if ($presetName -eq 'Manual' -or $presetName -eq 'NextDNS Custom Profile') { continue }
        if ($Template -eq [string]$dohPresets[$presetName]) {
            return $presetName
        }
    }

    return 'Manual'
}

