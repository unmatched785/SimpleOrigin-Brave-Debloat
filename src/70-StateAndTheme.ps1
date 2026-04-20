function Apply-Theme {
    param([bool]$DarkMode)

    $script:isDarkTheme = $DarkMode

    if ($DarkMode) {
        $colors = @{
            FormBack       = [System.Drawing.Color]::FromArgb(255, 24, 24, 24)
            PanelBack      = [System.Drawing.Color]::FromArgb(255, 36, 36, 36)
            ControlBack    = [System.Drawing.Color]::FromArgb(255, 32, 32, 32)
            Text           = [System.Drawing.Color]::White
            Muted          = [System.Drawing.Color]::Silver
            BorderAccent   = [System.Drawing.Color]::FromArgb(255, 95, 95, 95)
            SectionAccent  = [System.Drawing.Color]::FromArgb(255, 255, 189, 146)
            Subheader      = [System.Drawing.Color]::Gainsboro
            ButtonAccent   = [System.Drawing.Color]::FromArgb(255, 52, 52, 52)
        }
        $themeButton.Text = '☀'
    }
    else {
        $colors = @{
            FormBack       = [System.Drawing.Color]::FromArgb(255, 248, 249, 251)
            PanelBack      = [System.Drawing.Color]::White
            ControlBack    = [System.Drawing.Color]::White
            Text           = [System.Drawing.Color]::FromArgb(255, 28, 28, 28)
            Muted          = [System.Drawing.Color]::FromArgb(255, 95, 95, 95)
            BorderAccent   = [System.Drawing.Color]::FromArgb(255, 200, 205, 214)
            SectionAccent  = [System.Drawing.Color]::FromArgb(255, 53, 107, 187)
            Subheader      = [System.Drawing.Color]::FromArgb(255, 75, 75, 75)
            ButtonAccent   = [System.Drawing.Color]::FromArgb(255, 248, 249, 251)
        }
        $themeButton.Text = '☾'
    }

    $form.BackColor = $colors.FormBack

    foreach ($panel in $script:themePanels) {
        $panel.BackColor = $colors.PanelBack
    }

    foreach ($label in $script:sectionLabels) {
        $label.ForeColor = $colors.SectionAccent
        $label.BackColor = [System.Drawing.Color]::Transparent
    }

    foreach ($label in $script:subheaderLabels) {
        $label.ForeColor = $colors.Subheader
        $label.BackColor = [System.Drawing.Color]::Transparent
    }

    foreach ($label in $script:mutedLabels) {
        $label.ForeColor = $colors.Muted
        $label.BackColor = [System.Drawing.Color]::Transparent
    }

    foreach ($control in $script:themeControls) {
        if ($control -is [System.Windows.Forms.TextBox] -or $control -is [System.Windows.Forms.ComboBox]) {
            $control.BackColor = $colors.ControlBack
            $control.ForeColor = $colors.Text
        }
        elseif ($control -is [SimpleOriginCheckBox]) {
            $control.ForeColor = $colors.Text
            $control.BackColor = $colors.PanelBack
            $control.BoxBackColor = if ($DarkMode) { [System.Drawing.Color]::FromArgb(255, 28, 28, 28) } else { [System.Drawing.Color]::White }
            $control.BoxBorderColor = if ($DarkMode) { [System.Drawing.Color]::FromArgb(255, 124, 124, 124) } else { $colors.BorderAccent }
            $control.HoverBorderColor = if ($DarkMode) { [System.Drawing.Color]::FromArgb(255, 185, 185, 185) } else { [System.Drawing.Color]::FromArgb(255, 90, 120, 170) }
            $control.CheckMarkColor = if ($DarkMode) { [System.Drawing.Color]::FromArgb(255, 255, 222, 189) } else { [System.Drawing.Color]::FromArgb(255, 53, 107, 187) }
            $control.DisabledBorderColor = if ($DarkMode) { [System.Drawing.Color]::FromArgb(255, 88, 88, 88) } else { [System.Drawing.Color]::FromArgb(255, 180, 180, 180) }
            $control.DisabledCheckMarkColor = if ($DarkMode) { [System.Drawing.Color]::FromArgb(255, 150, 150, 150) } else { [System.Drawing.Color]::FromArgb(255, 150, 150, 150) }
            $control.Invalidate()
        }
        elseif ($control -is [System.Windows.Forms.CheckBox]) {
            $control.ForeColor = $colors.Text
            $control.BackColor = $colors.PanelBack
        }
        elseif ($control -is [System.Windows.Forms.Button]) {
            $control.BackColor = $colors.ButtonAccent
            $control.ForeColor = $colors.Text
            $control.FlatAppearance.BorderColor = $colors.BorderAccent
            $control.FlatAppearance.MouseOverBackColor = if ($DarkMode) { [System.Drawing.Color]::FromArgb(255, 62, 62, 62) } else { [System.Drawing.Color]::FromArgb(255, 235, 240, 248) }
            $control.FlatAppearance.MouseDownBackColor = if ($DarkMode) { [System.Drawing.Color]::FromArgb(255, 70, 70, 70) } else { [System.Drawing.Color]::FromArgb(255, 225, 232, 243) }
        }
        else {
            $control.ForeColor = $colors.Text
            $control.BackColor = [System.Drawing.Color]::Transparent
        }
    }

    if ($script:actionButtons.ContainsKey('apply')) { $script:actionButtons['apply'].ForeColor = if ($DarkMode) { [System.Drawing.Color]::LightGreen } else { [System.Drawing.Color]::FromArgb(255, 0, 122, 61) } }
    if ($script:actionButtons.ContainsKey('reset')) { $script:actionButtons['reset'].ForeColor = if ($DarkMode) { [System.Drawing.Color]::LightCoral } else { [System.Drawing.Color]::FromArgb(255, 180, 50, 50) } }
    if ($script:actionButtons.ContainsKey('loadPreset')) { $script:actionButtons['loadPreset'].ForeColor = if ($DarkMode) { [System.Drawing.Color]::LightSkyBlue } else { [System.Drawing.Color]::FromArgb(255, 0, 96, 176) } }
    if ($script:actionButtons.ContainsKey('clearSelection')) { $script:actionButtons['clearSelection'].ForeColor = if ($DarkMode) { [System.Drawing.Color]::Khaki } else { [System.Drawing.Color]::FromArgb(255, 146, 98, 0) } }
    if ($script:actionButtons.ContainsKey('export')) { $script:actionButtons['export'].ForeColor = if ($DarkMode) { [System.Drawing.Color]::LightSalmon } else { [System.Drawing.Color]::FromArgb(255, 176, 84, 40) } }
    if ($script:actionButtons.ContainsKey('import')) { $script:actionButtons['import'].ForeColor = if ($DarkMode) { [System.Drawing.Color]::LightSkyBlue } else { [System.Drawing.Color]::FromArgb(255, 0, 96, 176) } }
}

$themeButton.Add_Click({
    Apply-Theme -DarkMode (-not $script:isDarkTheme)
})

$dnsDropdown.Add_SelectedIndexChanged({
    $dnsTemplateBox.Enabled = ($dnsDropdown.SelectedItem -eq 'custom')
    if ($dnsDropdown.SelectedItem -ne 'custom') {
        $dnsPresetDropdown.SelectedItem = 'Manual'
    }
})

$dnsPresetDropdown.Add_SelectedIndexChanged({
    $selectedPreset = [string]$dnsPresetDropdown.SelectedItem
    if ([string]::IsNullOrWhiteSpace($selectedPreset) -or $selectedPreset -eq 'Manual') {
        return
    }

    $dnsDropdown.SelectedItem = 'custom'

    if ($selectedPreset -eq 'NextDNS Custom Profile') {
        if ([string]::IsNullOrWhiteSpace($dnsTemplateBox.Text) -or $dnsTemplateBox.Text -notmatch '^https://dns\.nextdns\.io/') {
            $dnsTemplateBox.Text = [string]$dohPresets[$selectedPreset]
        }
    }
    else {
        $dnsTemplateBox.Text = [string]$dohPresets[$selectedPreset]
    }
})

function Set-FeatureSelection {
    param([string[]]$FeatureIds)

    Clear-FeatureSelection

    foreach ($id in $FeatureIds) {
        if ($script:checkboxById.ContainsKey($id)) {
            $script:checkboxById[$id].Checked = $true
        }
    }
}

function Clear-FeatureSelection {
    foreach ($cb in $script:allCheckboxes) {
        $cb.Checked = $false
    }
}

function Update-PresetDescription {
    $selectedPreset = [string]$presetDropdown.SelectedItem
    if ($presetDescriptions.Contains($selectedPreset)) {
        $presetDescriptionLabel.Text = [string]$presetDescriptions[$selectedPreset]
    }
    else {
        $presetDescriptionLabel.Text = [string]$presetDescriptions['Custom']
    }
}

function Get-CurrentFeatureIdSet {
    return @((Get-SelectedFeatureObjects) | ForEach-Object { $_.Id } | Sort-Object)
}

function Get-MatchingPresetName {
    $currentIds = @(Get-CurrentFeatureIdSet)
    foreach ($name in $presets.Keys) {
        if ($name -eq 'Custom') { continue }
        $presetIds = @($presets[$name] | Sort-Object)
        if ($currentIds.Count -ne $presetIds.Count) { continue }
        $same = $true
        for ($i = 0; $i -lt $currentIds.Count; $i++) {
            if ($currentIds[$i] -ne $presetIds[$i]) {
                $same = $false
                break
            }
        }
        if ($same) { return $name }
    }
    return 'Custom'
}

$applyPresetButton.Add_Click({
    $selectedPreset = [string]$presetDropdown.SelectedItem
    if (-not $presets.Contains($selectedPreset)) {
        return
    }
    Set-FeatureSelection -FeatureIds $presets[$selectedPreset]
    $statusLabel.Text = "Loaded preset: $selectedPreset"
    Update-PresetDescription
})

$clearSelectionButton.Add_Click({
    Clear-FeatureSelection
    if ($presetDropdown.Items.Contains('Custom')) {
        $presetDropdown.SelectedItem = 'Custom'
    }
    Update-PresetDescription
    $statusLabel.Text = 'Cleared all checkbox selections. Review DNS/scope and click Apply only if you want to write changes.'
})

$presetDropdown.Add_SelectedIndexChanged({
    Update-PresetDescription
})

function Initialize-CurrentSettings {
    $scopeSummary = Get-ManagedScopeSummary
    $detectedScope = [string]$scopeSummary.PreferredScope

    foreach ($cb in $script:allCheckboxes) {
        $feature = $cb.Tag
        $policy = Get-PolicySetting -Key $feature.Key
        if ($null -eq $policy) {
            $cb.Checked = $false
            continue
        }

        if ($feature.Type -eq 'DWord') {
            $cb.Checked = ([int]$policy.Value -eq [int]$feature.Value)
        }
        else {
            $cb.Checked = ($policy.Value.ToString() -eq $feature.Value.ToString())
        }
    }

    $dnsModePolicy = Get-PolicySetting -Key 'DnsOverHttpsMode'
    $dnsTemplatePolicy = Get-PolicySetting -Key 'DnsOverHttpsTemplates'

    if ($dnsTemplatePolicy -and -not [string]::IsNullOrWhiteSpace($dnsTemplatePolicy.Value)) {
        $dnsDropdown.SelectedItem = 'custom'
        $dnsTemplateBox.Text = [string]$dnsTemplatePolicy.Value
    }
    elseif ($dnsModePolicy -and -not [string]::IsNullOrWhiteSpace($dnsModePolicy.Value)) {
        $modeValue = [string]$dnsModePolicy.Value
        if (@('browser default (unset)','off','automatic','secure','custom') -contains $modeValue) {
            $dnsDropdown.SelectedItem = $modeValue
        }
        else {
            $dnsDropdown.SelectedItem = 'browser default (unset)'
        }
        $dnsTemplateBox.Text = ''
    }
    else {
        $dnsDropdown.SelectedItem = 'browser default (unset)'
        $dnsTemplateBox.Text = ''
    }

    $dnsPresetDropdown.SelectedItem = Detect-DnsPresetName -Template $dnsTemplateBox.Text

    if ($detectedScope -eq 'Machine') {
        $scopeDropdown.SelectedIndex = 1
    }
    else {
        $scopeDropdown.SelectedIndex = 0
    }

    $matchingPreset = Get-MatchingPresetName
    if ((Get-CurrentFeatureIdSet).Count -eq 0) {
        $presetDropdown.SelectedItem = 'Origin + Hardening — Recommended'
    }
    elseif ($presetDropdown.Items.Contains($matchingPreset)) {
        $presetDropdown.SelectedItem = $matchingPreset
    }
    else {
        $presetDropdown.SelectedItem = 'Origin + Hardening — Recommended'
    }

    Update-PresetDescription

    if ($scopeSummary.IsMixed) {
        $statusLabel.Text = 'Detected mixed HKLM/HKCU Brave policy state. Machine policies override User for overlapping keys.'
    }
    elseif ($scopeSummary.HasMachine) {
        $statusLabel.Text = 'Detected existing Machine (HKLM) Brave policies.'
    }
    elseif ($scopeSummary.HasUser) {
        $statusLabel.Text = 'Detected existing User (HKCU) Brave policies.'
    }
    else {
        $statusLabel.Text = 'Ready. Scope-aware apply is enabled.'
    }
}

