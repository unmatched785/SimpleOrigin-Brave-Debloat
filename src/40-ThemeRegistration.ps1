$script:isDarkTheme = $false
$script:themeControls = New-Object System.Collections.ArrayList
$script:themePanels = New-Object System.Collections.ArrayList
$script:sectionLabels = New-Object System.Collections.ArrayList
$script:subheaderLabels = New-Object System.Collections.ArrayList
$script:mutedLabels = New-Object System.Collections.ArrayList
$script:actionButtons = @{}

function Register-ThemedControl {
    param($Control)
    [void]$script:themeControls.Add($Control)
}

function Register-ThemedPanel {
    param($Panel)
    [void]$script:themePanels.Add($Panel)
}

function Register-SectionLabel {
    param($Label)
    [void]$script:sectionLabels.Add($Label)
}

function Register-SubheaderLabel {
    param($Label)
    [void]$script:subheaderLabels.Add($Label)
}

function Register-MutedLabel {
    param($Label)
    [void]$script:mutedLabels.Add($Label)
}

