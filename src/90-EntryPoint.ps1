Apply-Theme -DarkMode $false
$scopeDropdown.SelectedIndex = 0
$presetDropdown.SelectedIndex = 0
Update-PresetDescription
try {
    Initialize-CurrentSettings
}
catch {
    $statusLabel.Text = 'Ready. Existing policy detection was limited by registry permissions.'
}
$form.Add_Shown({
    try {
        $scopeDropdown.SelectedIndex = if ([string]$scopeDropdown.SelectedItem -like 'Machine*') { 1 } else { 0 }
        if (-not $presetDropdown.SelectedItem) { $presetDropdown.SelectedIndex = 0 }
        Update-PresetDescription
    }
    catch {
        $statusLabel.Text = 'Ready.'
    }
})
[void]$form.ShowDialog()
