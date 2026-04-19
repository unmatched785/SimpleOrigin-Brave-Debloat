function New-SectionPanel {
    param(
        [string]$Title,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height
    )

    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location = New-Object System.Drawing.Point($X, $Y)
    $panel.Size = New-Object System.Drawing.Size($Width, $Height)
    $panel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $panel.AutoScroll = $true
    $form.Controls.Add($panel)
    Register-ThemedPanel $panel

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Title
    $label.Location = New-Object System.Drawing.Point(18, 10)
    $label.Size = New-Object System.Drawing.Size(($Width - 36), 24)
    $label.Font = New-Object System.Drawing.Font('Segoe UI', 10.5, [System.Drawing.FontStyle]::Bold)
    $label.AutoEllipsis = $true
    $label.UseMnemonic = $false
    $panel.Controls.Add($label)
    Register-SectionLabel $label

    return $panel
}

$leftPanel  = New-SectionPanel -Title 'Telemetry and Privacy' -X 24 -Y 136 -Width 565 -Height 786
$rightPanel = New-SectionPanel -Title 'Brave Features and Performance' -X 607 -Y 136 -Width 565 -Height 786

function Add-FeatureCheckboxes {
    param(
        [System.Windows.Forms.Panel]$Panel,
        [array]$Features,
        [int]$StartY,
        [switch]$ShowSubheaders
    )

    $currentY = $StartY
    $grouped = $Features | Group-Object Category
    foreach ($group in $grouped) {
        if ($ShowSubheaders) {
            $subheader = New-Object System.Windows.Forms.Label
            $subheader.Text = switch ($group.Name) {
                'Telemetry'   { 'Telemetry and Reporting' }
                'Privacy'     { 'Privacy & Security' }
                'Brave'       { 'Brave Features' }
                'Performance' { 'Performance & Bloat' }
                default       { $group.Name }
            }
            $subheader.Location = New-Object System.Drawing.Point(18, $currentY)
            $subheader.Size = New-Object System.Drawing.Size(($Panel.Width - 36), 22)
            $subheader.Font = New-Object System.Drawing.Font('Segoe UI', 9.5, [System.Drawing.FontStyle]::Bold)
            $subheader.AutoEllipsis = $true
            $Panel.Controls.Add($subheader)
            Register-SubheaderLabel $subheader
            $currentY += 28
        }

        foreach ($feature in $group.Group) {
            $cb = New-Object SimpleOriginCheckBox
            $cb.Text = $feature.Name
            $cb.Tag = $feature
            $cb.Location = New-Object System.Drawing.Point(20, $currentY)
            $cb.Size = New-Object System.Drawing.Size(($Panel.ClientSize.Width - 42), 30)
            $cb.AutoEllipsis = $true
            $cb.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
            $cb.Cursor = [System.Windows.Forms.Cursors]::Hand
            $cb.UseCompatibleTextRendering = $true
            $cb.UseMnemonic = $false
            $Panel.Controls.Add($cb)
            Register-ThemedControl $cb
            $script:allCheckboxes += $cb
            $script:checkboxById[$feature.Id] = $cb

            if ($feature.ContainsKey('ExclusiveGroup')) {
                $cb.Add_CheckedChanged({
                    if ($this.Checked) {
                        foreach ($otherCb in $script:allCheckboxes) {
                            if ($otherCb -ne $this -and $otherCb.Tag.ContainsKey('ExclusiveGroup') -and $otherCb.Tag.ExclusiveGroup -eq $this.Tag.ExclusiveGroup) {
                                $otherCb.Checked = $false
                            }
                        }
                    }
                })
            }

            $currentY += 30
        }
        $currentY += 10
    }
}

Add-FeatureCheckboxes -Panel $leftPanel  -Features ($featureCatalog | Where-Object { $_.Category -in @('Telemetry','Privacy') }) -StartY 38 -ShowSubheaders
Add-FeatureCheckboxes -Panel $rightPanel -Features ($featureCatalog | Where-Object { $_.Category -in @('Brave','Performance') }) -StartY 38 -ShowSubheaders

$dnsGroup = New-SectionPanel -Title 'DNS Over HTTPS' -X 24 -Y 935 -Width 1148 -Height 120

$dnsPresetLabel = New-Object System.Windows.Forms.Label
$dnsPresetLabel.Text = 'Preset:'
$dnsPresetLabel.Location = New-Object System.Drawing.Point(20, 42)
$dnsPresetLabel.Size = New-Object System.Drawing.Size(48, 22)
$dnsGroup.Controls.Add($dnsPresetLabel)
Register-ThemedControl $dnsPresetLabel

$dnsPresetDropdown = New-Object System.Windows.Forms.ComboBox
$dnsPresetDropdown.Location = New-Object System.Drawing.Point(72, 40)
$dnsPresetDropdown.Size = New-Object System.Drawing.Size(280, 28)
$dnsPresetDropdown.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$dnsPresetDropdown.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$dnsPresetDropdown.Items.AddRange([string[]]$dohPresets.Keys)
$dnsPresetDropdown.SelectedItem = 'Manual'
$dnsGroup.Controls.Add($dnsPresetDropdown)
Register-ThemedControl $dnsPresetDropdown

$dnsModeLabel = New-Object System.Windows.Forms.Label
$dnsModeLabel.Text = 'Mode:'
$dnsModeLabel.Location = New-Object System.Drawing.Point(372, 42)
$dnsModeLabel.Size = New-Object System.Drawing.Size(45, 22)
$dnsGroup.Controls.Add($dnsModeLabel)
Register-ThemedControl $dnsModeLabel

$dnsDropdown = New-Object System.Windows.Forms.ComboBox
$dnsDropdown.Location = New-Object System.Drawing.Point(420, 40)
$dnsDropdown.Size = New-Object System.Drawing.Size(170, 28)
$dnsDropdown.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$dnsDropdown.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$dnsDropdown.Items.AddRange(@('browser default (unset)','off','automatic','secure','custom'))
$dnsDropdown.SelectedItem = 'browser default (unset)'
$dnsGroup.Controls.Add($dnsDropdown)
Register-ThemedControl $dnsDropdown

$dnsTemplateLabel = New-Object System.Windows.Forms.Label
$dnsTemplateLabel.Text = 'Template URL:'
$dnsTemplateLabel.Location = New-Object System.Drawing.Point(610, 42)
$dnsTemplateLabel.Size = New-Object System.Drawing.Size(98, 22)
$dnsGroup.Controls.Add($dnsTemplateLabel)
Register-ThemedControl $dnsTemplateLabel

$dnsTemplateBox = New-Object System.Windows.Forms.TextBox
$dnsTemplateBox.Location = New-Object System.Drawing.Point(714, 40)
$dnsTemplateBox.Size = New-Object System.Drawing.Size(394, 27)
$dnsTemplateBox.Enabled = $false
$dnsGroup.Controls.Add($dnsTemplateBox)
Register-ThemedControl $dnsTemplateBox

$dnsHintLabel = New-Object System.Windows.Forms.Label
$dnsHintLabel.Text = 'Browser default (unset) removes DoH policy. Selecting a preset fills the template and switches Mode to custom in the UI.'
$dnsHintLabel.Location = New-Object System.Drawing.Point(20, 76)
$dnsHintLabel.Size = New-Object System.Drawing.Size(700, 18)
$dnsGroup.Controls.Add($dnsHintLabel)
Register-MutedLabel $dnsHintLabel

$exportButton = New-Object System.Windows.Forms.Button
$exportButton.Text = 'Export'
$exportButton.Location = New-Object System.Drawing.Point(24, 1066)
$exportButton.Size = New-Object System.Drawing.Size(112, 32)
$exportButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$form.Controls.Add($exportButton)
Register-ThemedControl $exportButton
$script:actionButtons['export'] = $exportButton

$importButton = New-Object System.Windows.Forms.Button
$importButton.Text = 'Import'
$importButton.Location = New-Object System.Drawing.Point(148, 1066)
$importButton.Size = New-Object System.Drawing.Size(112, 32)
$importButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$form.Controls.Add($importButton)
Register-ThemedControl $importButton
$script:actionButtons['import'] = $importButton

$applyButton = New-Object System.Windows.Forms.Button
$applyButton.Text = 'Apply'
$applyButton.Location = New-Object System.Drawing.Point(936, 1066)
$applyButton.Size = New-Object System.Drawing.Size(112, 32)
$applyButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$form.Controls.Add($applyButton)
Register-ThemedControl $applyButton
$script:actionButtons['apply'] = $applyButton

$resetButton = New-Object System.Windows.Forms.Button
$resetButton.Text = 'Reset Managed`nPolicies'
$resetButton.Location = New-Object System.Drawing.Point(1060, 1066)
$resetButton.Size = New-Object System.Drawing.Size(112, 40)
$resetButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$form.Controls.Add($resetButton)
Register-ThemedControl $resetButton
$script:actionButtons['reset'] = $resetButton

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = 'Ready. Scope-aware apply is enabled.'
$statusLabel.Location = New-Object System.Drawing.Point(290, 1072)
$statusLabel.Size = New-Object System.Drawing.Size(620, 20)
$statusLabel.AutoEllipsis = $true
$statusLabel.UseMnemonic = $false
$form.Controls.Add($statusLabel)
Register-MutedLabel $statusLabel

