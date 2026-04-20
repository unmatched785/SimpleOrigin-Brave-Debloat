$form = New-Object System.Windows.Forms.Form
$designFormSize = New-Object System.Drawing.Size(1220, 1175)
$minimumFormSize = New-Object System.Drawing.Size(780, 600)
$initialFormWidth = $designFormSize.Width
$initialFormHeight = $designFormSize.Height

try {
    $workingArea = [System.Windows.Forms.SystemInformation]::WorkingArea
    if ($workingArea.Width -gt 0 -and $workingArea.Height -gt 0) {
        $initialFormWidth = [Math]::Min($designFormSize.Width, [Math]::Max($minimumFormSize.Width, ($workingArea.Width - 40)))
        $initialFormHeight = [Math]::Min($designFormSize.Height, [Math]::Max($minimumFormSize.Height, ($workingArea.Height - 40)))
    }
}
catch {
    $initialFormWidth = $designFormSize.Width
    $initialFormHeight = $designFormSize.Height
}

$form.Text = 'Simple Origin v0.4.1'
$form.Size = New-Object System.Drawing.Size($initialFormWidth, $initialFormHeight)
$form.MinimumSize = $minimumFormSize
$form.StartPosition = 'CenterScreen'
$form.MaximizeBox = $true
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Dpi
$form.AutoScroll = $true
$form.AutoScrollMinSize = $designFormSize

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = 'Simple Origin v0.4.1 - Brave policy UI'
$titleLabel.Location = New-Object System.Drawing.Point(24, 18)
$titleLabel.Size = New-Object System.Drawing.Size(940, 30)
$titleLabel.Font = New-Object System.Drawing.Font('Segoe UI', 11.5, [System.Drawing.FontStyle]::Bold)
$titleLabel.AutoEllipsis = $true
$titleLabel.UseMnemonic = $false
$form.Controls.Add($titleLabel)
Register-ThemedControl $titleLabel

$subLabel = New-Object System.Windows.Forms.Label
$subLabel.Text = 'Managed-policy UI for Brave. Includes Origin, Hardening, and Origin + Hardening presets. Scope-aware apply; no binary patching.'
$subLabel.Location = New-Object System.Drawing.Point(24, 46)
$subLabel.Size = New-Object System.Drawing.Size(1015, 20)
$subLabel.AutoEllipsis = $true
$subLabel.UseMnemonic = $false
$form.Controls.Add($subLabel)
Register-MutedLabel $subLabel

$themeButton = New-Object System.Windows.Forms.Button
$themeButton.Text = 'Dark'
$themeButton.Location = New-Object System.Drawing.Point(1124, 18)
$themeButton.Size = New-Object System.Drawing.Size(52, 34)
$themeButton.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)
$themeButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$themeButton.TabStop = $false
$form.Controls.Add($themeButton)
Register-ThemedControl $themeButton
$script:actionButtons['theme'] = $themeButton

$presetLabel = New-Object System.Windows.Forms.Label
$presetLabel.Text = 'Preset:'
$presetLabel.Location = New-Object System.Drawing.Point(24, 80)
$presetLabel.Size = New-Object System.Drawing.Size(52, 22)
$form.Controls.Add($presetLabel)
Register-ThemedControl $presetLabel

$presetDropdown = New-Object System.Windows.Forms.ComboBox
$presetDropdown.Location = New-Object System.Drawing.Point(82, 78)
$presetDropdown.Size = New-Object System.Drawing.Size(230, 28)
$presetDropdown.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$presetDropdown.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$presetDropdown.Items.AddRange([string[]]$presets.Keys)
$presetDropdown.SelectedIndex = 0
$form.Controls.Add($presetDropdown)
Register-ThemedControl $presetDropdown

$applyPresetButton = New-Object System.Windows.Forms.Button
$applyPresetButton.Text = 'Load Preset'
$applyPresetButton.Location = New-Object System.Drawing.Point(322, 77)
$applyPresetButton.Size = New-Object System.Drawing.Size(112, 30)
$applyPresetButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$form.Controls.Add($applyPresetButton)
Register-ThemedControl $applyPresetButton
$script:actionButtons['loadPreset'] = $applyPresetButton

$clearSelectionButton = New-Object System.Windows.Forms.Button
$clearSelectionButton.Text = 'Clear Checks'
$clearSelectionButton.Location = New-Object System.Drawing.Point(444, 77)
$clearSelectionButton.Size = New-Object System.Drawing.Size(108, 30)
$clearSelectionButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$form.Controls.Add($clearSelectionButton)
Register-ThemedControl $clearSelectionButton
$script:actionButtons['clearSelection'] = $clearSelectionButton

$scopeLabel = New-Object System.Windows.Forms.Label
$scopeLabel.Text = 'Write scope:'
$scopeLabel.Location = New-Object System.Drawing.Point(566, 80)
$scopeLabel.Size = New-Object System.Drawing.Size(78, 22)
$form.Controls.Add($scopeLabel)
Register-ThemedControl $scopeLabel

$scopeDropdown = New-Object System.Windows.Forms.ComboBox
$scopeDropdown.Location = New-Object System.Drawing.Point(651, 78)
$scopeDropdown.Size = New-Object System.Drawing.Size(205, 28)
$scopeDropdown.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$scopeDropdown.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$scopeDropdown.Items.AddRange(@('User (HKCU) - Recommended','Machine (HKLM)'))
$scopeDropdown.SelectedItem = 'User (HKCU) - Recommended'
$form.Controls.Add($scopeDropdown)
Register-ThemedControl $scopeDropdown

$scopeHintLabel = New-Object System.Windows.Forms.Label
$scopeHintLabel.Text = 'Recommended: User (HKCU) for most personal PCs. Apply makes the selected scope authoritative for Simple Origin-managed keys when possible.'
$scopeHintLabel.Location = New-Object System.Drawing.Point(868, 76)
$scopeHintLabel.Size = New-Object System.Drawing.Size(297, 40)
$scopeHintLabel.AutoEllipsis = $true
$scopeHintLabel.UseMnemonic = $false
$form.Controls.Add($scopeHintLabel)
Register-MutedLabel $scopeHintLabel

$presetDescriptionLabel = New-Object System.Windows.Forms.Label
$presetDescriptionLabel.Text = [string]$presetDescriptions['Origin + Hardening - Recommended']
$presetDescriptionLabel.Location = New-Object System.Drawing.Point(24, 108)
$presetDescriptionLabel.Size = New-Object System.Drawing.Size(1140, 20)
$presetDescriptionLabel.AutoEllipsis = $true
$presetDescriptionLabel.UseMnemonic = $false
$form.Controls.Add($presetDescriptionLabel)
Register-MutedLabel $presetDescriptionLabel

$script:allCheckboxes = @()
$script:checkboxById = @{}

