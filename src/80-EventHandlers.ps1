function Get-SelectedFeatureObjects {
    $selected = @()
    foreach ($cb in $script:allCheckboxes) {
        if ($cb.Checked) {
            $selected += $cb.Tag
        }
    }
    return $selected
}

$applyButton.Add_Click({
    $scopeInfo = Get-WriteScopeInfo -ScopeSelection ([string]$scopeDropdown.SelectedItem)
    $script:registryPath = [string]$scopeInfo.TargetPath

    if ($scopeInfo.ScopeName -eq 'Machine' -and -not (Test-IsAdmin)) {
        [System.Windows.Forms.MessageBox]::Show(
            'Machine scope requires administrator rights. Switch Write scope to User (HKCU) or relaunch as admin.',
            'Simple Origin',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    if (([string]$dnsDropdown.SelectedItem) -eq 'custom' -and [string]::IsNullOrWhiteSpace($dnsTemplateBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show(
            'Custom DoH requires a template URL, e.g. https://cloudflare-dns.com/dns-query',
            'Simple Origin',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    $selectedFeatures = @{}
    foreach ($feature in (Get-SelectedFeatureObjects)) {
        $selectedFeatures[$feature.Key] = $feature
    }

    $otherScopeWarnings = New-Object System.Collections.ArrayList
    $otherScopeName = if ($scopeInfo.ScopeName -eq 'User') { 'Machine' } else { 'User' }

    $uniqueKeys = $featureCatalog | ForEach-Object { $_.Key } | Select-Object -Unique
    foreach ($key in $uniqueKeys) {
        if ($selectedFeatures.ContainsKey($key)) {
            $feature = $selectedFeatures[$key]
            Set-ManagedPropertyAtPath -Path $scopeInfo.TargetPath -Key $feature.Key -Value $feature.Value -Type $feature.Type
        }
        else {
            [void](Remove-ManagedPropertyFromPath -Key $key -Path $scopeInfo.TargetPath)
        }

        Clear-OtherScopeManagedProperty -Key $key -OtherPath $scopeInfo.OtherPath -OtherScopeName $otherScopeName -OtherScopeWarnings $otherScopeWarnings
    }

    if (-not (Set-DnsSettings -DnsMode ([string]$dnsDropdown.SelectedItem) -DnsTemplates $dnsTemplateBox.Text -TargetPath $scopeInfo.TargetPath -OtherPath $scopeInfo.OtherPath -TargetScopeName $scopeInfo.ScopeName -OtherScopeWarnings $otherScopeWarnings)) {
        Initialize-CurrentSettings
        return
    }

    Cleanup-PolicyPathTree -LeafPath $machineRegistryPath
    Cleanup-PolicyPathTree -LeafPath $userRegistryPath

    Initialize-CurrentSettings

    if ($otherScopeWarnings.Count -gt 0) {
        $statusLabel.Text = "Applied to $($scopeInfo.ScopeName) scope. Some $otherScopeName-scope keys could not be cleared."
        [System.Windows.Forms.MessageBox]::Show(
            "Settings were written to $($scopeInfo.ScopeName) scope. However, some $otherScopeName-scope keys could not be cleared, so Brave may still prefer those values. Use Reset Managed Policies or relaunch as admin if you want a clean single-scope state.",
            'Simple Origin',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
    }
    else {
        $statusLabel.Text = "Applied to $($scopeInfo.ScopeName) scope. Restart Brave."
        [System.Windows.Forms.MessageBox]::Show(
            "Settings applied. For the keys managed by Simple Origin, $($scopeInfo.ScopeName) scope is now authoritative. Restart Brave and check brave://policy if you want to verify the result.",
            'Simple Origin',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null
    }
})

$resetButton.Add_Click({
    $scopeSummary = Get-ManagedScopeSummary
    if ($scopeSummary.HasMachine -and -not (Test-IsAdmin)) {
        [System.Windows.Forms.MessageBox]::Show(
            'Reset Managed Policies needs administrator rights when Machine (HKLM) keys are present.',
            'Simple Origin',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        'This removes the managed Brave policies touched by this tool from both HKLM and HKCU. Continue?',
        'Simple Origin',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) {
        return
    }

    foreach ($key in (Get-ManagedPolicyKeys)) {
        Remove-ManagedPropertyEverywhere -Key $key
    }

    Cleanup-PolicyPathTree -LeafPath $machineRegistryPath
    Cleanup-PolicyPathTree -LeafPath $userRegistryPath
    Initialize-CurrentSettings
    $statusLabel.Text = 'Managed policies reset from HKLM and HKCU.'
})

$exportButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.SaveFileDialog
    $dialog.Filter = 'JSON files (*.json)|*.json|All files (*.*)|*.*'
    $dialog.Title = 'Export Simple Origin Settings'
    $dialog.InitialDirectory = [Environment]::GetFolderPath('MyDocuments')
    $dialog.FileName = 'SimpleOriginSettings.json'

    if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        return
    }

    $payload = [ordered]@{
        AppVersion   = $script:toolVersion
        Preset       = [string]$presetDropdown.SelectedItem
        FeatureIds   = @((Get-SelectedFeatureObjects) | ForEach-Object { $_.Id })
        FeatureKeys  = @((Get-SelectedFeatureObjects) | ForEach-Object { $_.Key })
        DnsMode      = [string]$dnsDropdown.SelectedItem
        DnsPreset    = [string]$dnsPresetDropdown.SelectedItem
        DnsTemplates = [string]$dnsTemplateBox.Text
        Theme        = if ($script:isDarkTheme) { 'dark' } else { 'light' }
        Scope        = if ([string]$scopeDropdown.SelectedItem -like 'User (HKCU)*') { 'User' } else { 'Machine' }
    }

    $payload | ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 -Path $dialog.FileName
    $statusLabel.Text = "Exported: $($dialog.FileName)"
})

$importButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = 'JSON files (*.json)|*.json|All files (*.*)|*.*'
    $dialog.Title = 'Import Simple Origin Settings'
    $dialog.InitialDirectory = [Environment]::GetFolderPath('MyDocuments')

    if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        return
    }

    try {
        $payload = Get-Content -Raw -Path $dialog.FileName | ConvertFrom-Json
        Clear-FeatureSelection

        if ($payload.PSObject.Properties.Name -contains 'FeatureIds' -and $payload.FeatureIds) {
            Set-FeatureSelection -FeatureIds @($payload.FeatureIds)
        }
        elseif ($payload.PSObject.Properties.Name -contains 'Features' -and $payload.Features) {
            foreach ($key in $payload.Features) {
                foreach ($feature in $featureCatalog) {
                    if ($feature.Key -eq $key -and $script:checkboxById.ContainsKey($feature.Id)) {
                        $script:checkboxById[$feature.Id].Checked = $true
                        break
                    }
                }
            }
        }
        elseif ($payload.PSObject.Properties.Name -contains 'FeatureKeys' -and $payload.FeatureKeys) {
            foreach ($key in $payload.FeatureKeys) {
                foreach ($feature in $featureCatalog) {
                    if ($feature.Key -eq $key -and $script:checkboxById.ContainsKey($feature.Id)) {
                        $script:checkboxById[$feature.Id].Checked = $true
                        break
                    }
                }
            }
        }

        if ($payload.PSObject.Properties.Name -contains 'DnsMode' -and $payload.DnsMode) {
            if (@('off','automatic','secure','custom') -contains ([string]$payload.DnsMode)) {
                $dnsDropdown.SelectedItem = [string]$payload.DnsMode
            }
        }
        if ($payload.PSObject.Properties.Name -contains 'DnsTemplates' -and $payload.DnsTemplates) {
            $dnsTemplateBox.Text = [string]$payload.DnsTemplates
            if (-not $payload.DnsMode) {
                $dnsDropdown.SelectedItem = 'custom'
            }
        }
        if ($payload.PSObject.Properties.Name -contains 'DnsPreset' -and $payload.DnsPreset -and $dnsPresetDropdown.Items.Contains([string]$payload.DnsPreset)) {
            $dnsPresetDropdown.SelectedItem = [string]$payload.DnsPreset
        }
        else {
            $dnsPresetDropdown.SelectedItem = Detect-DnsPresetName -Template $dnsTemplateBox.Text
        }

        if ($payload.PSObject.Properties.Name -contains 'Preset' -and $payload.Preset -and $presetDropdown.Items.Contains([string]$payload.Preset)) {
            $presetDropdown.SelectedItem = [string]$payload.Preset
        }
        else {
            $presetDropdown.SelectedItem = Get-MatchingPresetName
        }

        if ($payload.PSObject.Properties.Name -contains 'Scope' -and $payload.Scope) {
            if (([string]$payload.Scope) -eq 'Machine') {
                $scopeDropdown.SelectedIndex = 1
            }
            else {
                $scopeDropdown.SelectedIndex = 0
            }
        }

        Update-PresetDescription

        if ($payload.PSObject.Properties.Name -contains 'Theme' -and $payload.Theme) {
            Apply-Theme -DarkMode (([string]$payload.Theme).ToLowerInvariant() -ne 'light')
        }

        $statusLabel.Text = "Imported: $($dialog.FileName)"
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Import failed: $_",
            'Simple Origin',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
})

