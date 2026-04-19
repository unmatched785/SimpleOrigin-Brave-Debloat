Apply-Theme -DarkMode $false
$scopeDropdown.SelectedIndex = 0
$presetDropdown.SelectedIndex = 0
Update-PresetDescription
Initialize-CurrentSettings
$form.Add_Shown({
    $scopeDropdown.SelectedIndex = if ([string]$scopeDropdown.SelectedItem -like 'Machine*') { 1 } else { 0 }
    if (-not $presetDropdown.SelectedItem) { $presetDropdown.SelectedIndex = 0 }
    Update-PresetDescription
})
[void]$form.ShowDialog()
