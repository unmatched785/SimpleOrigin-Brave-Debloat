param(
    [switch]$NoAdminRelaunch
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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
            "Administrator rights were not granted. The app will continue, but Apply/Reset may fail if machine-level policy writes are blocked.",
            "Simple Origin",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
    }
}

$machineRegistryPath = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"
$userRegistryPath    = "HKCU:\SOFTWARE\Policies\BraveSoftware\Brave"
$script:registryPath = $machineRegistryPath

foreach ($path in @($machineRegistryPath, $userRegistryPath)) {
    if (-not (Test-Path -Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
}

# ---------------------------------------------------------------------------
# Feature catalog
# ---------------------------------------------------------------------------

$featureCatalog = @(
    @{ Id = 'telemetry.metrics';           Name = 'Disable Metrics Reporting';        Key = 'MetricsReportingEnabled';              Value = 0;                                Type = 'DWord'; Category = 'Telemetry'; Origin = $true  },
    @{ Id = 'telemetry.safebrowsing_rep';  Name = 'Disable Safe Browsing Reporting';  Key = 'SafeBrowsingExtendedReportingEnabled'; Value = 0;                                Type = 'DWord'; Category = 'Telemetry'; Origin = $false },
    @{ Id = 'telemetry.url_data';          Name = 'Disable URL Data Collection';      Key = 'UrlKeyedAnonymizedDataCollectionEnabled'; Value = 0;                           Type = 'DWord'; Category = 'Telemetry'; Origin = $false },
    @{ Id = 'telemetry.feedback';          Name = 'Disable Feedback Surveys';         Key = 'FeedbackSurveysEnabled';               Value = 0;                                Type = 'DWord'; Category = 'Telemetry'; Origin = $false },
    @{ Id = 'telemetry.p3a';               Name = 'Disable P3A Analytics';            Key = 'BraveP3AEnabled';                     Value = 0;                                Type = 'DWord'; Category = 'Telemetry'; Origin = $true  },
    @{ Id = 'telemetry.stats_ping';        Name = 'Disable Stats Ping';               Key = 'BraveStatsPingEnabled';               Value = 0;                                Type = 'DWord'; Category = 'Telemetry'; Origin = $true  },

    @{ Id = 'privacy.safe_browsing';       Name = 'Disable Safe Browsing';            Key = 'SafeBrowsingProtectionLevel';         Value = 0;                                Type = 'DWord'; Category = 'Privacy';   Origin = $false },
    @{ Id = 'privacy.autofill_addr';       Name = 'Disable Autofill (Addresses)';     Key = 'AutofillAddressEnabled';              Value = 0;                                Type = 'DWord'; Category = 'Privacy';   Origin = $false },
    @{ Id = 'privacy.autofill_cards';      Name = 'Disable Autofill (Credit Cards)';  Key = 'AutofillCreditCardEnabled';           Value = 0;                                Type = 'DWord'; Category = 'Privacy';   Origin = $false },
    @{ Id = 'privacy.password_manager';    Name = 'Disable Password Manager';         Key = 'PasswordManagerEnabled';              Value = 0;                                Type = 'DWord'; Category = 'Privacy';   Origin = $false },
    @{ Id = 'privacy.browser_signin';      Name = 'Disable Browser Sign-in';          Key = 'BrowserSignin';                       Value = 0;                                Type = 'DWord'; Category = 'Privacy';   Origin = $false },
    @{ Id = 'privacy.dnt';                 Name = 'Enable Do Not Track';              Key = 'EnableDoNotTrack';                    Value = 1;                                Type = 'DWord'; Category = 'Privacy';   Origin = $false },
    @{ Id = 'privacy.gpc';                 Name = 'Enable Global Privacy Control';    Key = 'BraveGlobalPrivacyControlEnabled';    Value = 1;                                Type = 'DWord'; Category = 'Privacy';   Origin = $false },
    @{ Id = 'privacy.webrtc';              Name = 'Disable WebRTC IP Leak';           Key = 'WebRtcIPHandling';                    Value = 'disable_non_proxied_udp';         Type = 'String'; Category = 'Privacy';  Origin = $false },
    @{ Id = 'privacy.quic';                Name = 'Disable QUIC Protocol';            Key = 'QuicAllowed';                         Value = 0;                                Type = 'DWord'; Category = 'Privacy';   Origin = $false },
    @{ Id = 'privacy.third_party_cookies'; Name = 'Block Third Party Cookies';        Key = 'BlockThirdPartyCookies';              Value = 1;                                Type = 'DWord'; Category = 'Privacy';   Origin = $false },
    @{ Id = 'privacy.safe_search';         Name = 'Force Google SafeSearch';          Key = 'ForceGoogleSafeSearch';               Value = 1;                                Type = 'DWord'; Category = 'Privacy';   Origin = $false },
    @{ Id = 'privacy.disable_incognito';   Name = 'Disable Incognito Mode';           Key = 'IncognitoModeAvailability';           Value = 1;                                Type = 'DWord'; Category = 'Privacy';   Origin = $false; ExclusiveGroup = 'incognito_mode' },
    @{ Id = 'privacy.force_incognito';     Name = 'Force Incognito Mode';             Key = 'IncognitoModeAvailability';           Value = 2;                                Type = 'DWord'; Category = 'Privacy';   Origin = $false; ExclusiveGroup = 'incognito_mode' },

    @{ Id = 'brave.rewards';               Name = 'Disable Brave Rewards';            Key = 'BraveRewardsDisabled';                Value = 1;                                Type = 'DWord'; Category = 'Brave';     Origin = $true  },
    @{ Id = 'brave.wallet';                Name = 'Disable Brave Wallet';             Key = 'BraveWalletDisabled';                 Value = 1;                                Type = 'DWord'; Category = 'Brave';     Origin = $true  },
    @{ Id = 'brave.vpn';                   Name = 'Disable Brave VPN';                Key = 'BraveVPNDisabled';                    Value = 1;                                Type = 'DWord'; Category = 'Brave';     Origin = $true  },
    @{ Id = 'brave.ai_chat';               Name = 'Disable Brave AI Chat';            Key = 'BraveAIChatEnabled';                  Value = 0;                                Type = 'DWord'; Category = 'Brave';     Origin = $true  },
    @{ Id = 'brave.shields';               Name = 'Disable Brave Shields';            Key = 'BraveShieldsDisabledForUrls';         Value = '["https://*", "http://*"]';      Type = 'String'; Category = 'Brave';    Origin = $false },
    @{ Id = 'brave.news';                  Name = 'Disable Brave News';               Key = 'BraveNewsDisabled';                   Value = 1;                                Type = 'DWord'; Category = 'Brave';     Origin = $true  },
    @{ Id = 'brave.talk';                  Name = 'Disable Brave Talk';               Key = 'BraveTalkDisabled';                   Value = 1;                                Type = 'DWord'; Category = 'Brave';     Origin = $true  },
    @{ Id = 'brave.playlist';              Name = 'Disable Brave Playlist';           Key = 'BravePlaylistEnabled';                Value = 0;                                Type = 'DWord'; Category = 'Brave';     Origin = $true  },
    @{ Id = 'brave.web_discovery';         Name = 'Disable Web Discovery';            Key = 'BraveWebDiscoveryEnabled';            Value = 0;                                Type = 'DWord'; Category = 'Brave';     Origin = $true  },
    @{ Id = 'brave.speedreader';           Name = 'Disable Speedreader';              Key = 'BraveSpeedreaderEnabled';             Value = 0;                                Type = 'DWord'; Category = 'Brave';     Origin = $true  },
    @{ Id = 'brave.tor';                   Name = 'Disable Tor';                      Key = 'TorDisabled';                         Value = 1;                                Type = 'DWord'; Category = 'Brave';     Origin = $true  },
    @{ Id = 'brave.sync';                  Name = 'Disable Sync';                     Key = 'SyncDisabled';                        Value = 1;                                Type = 'DWord'; Category = 'Brave';     Origin = $false },

    @{ Id = 'perf.background';             Name = 'Disable Background Mode';          Key = 'BackgroundModeEnabled';               Value = 0;                                Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.media_recs';             Name = 'Disable Media Recommendations';    Key = 'MediaRecommendationsEnabled';         Value = 0;                                Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.shopping';               Name = 'Disable Shopping List';            Key = 'ShoppingListEnabled';                 Value = 0;                                Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.pdf_external';           Name = 'Always Open PDF Externally';       Key = 'AlwaysOpenPdfExternally';             Value = 1;                                Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.translate';              Name = 'Disable Translate';                Key = 'TranslateEnabled';                    Value = 0;                                Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.spellcheck';             Name = 'Disable Spellcheck';               Key = 'SpellcheckEnabled';                   Value = 0;                                Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.promotions';             Name = 'Disable Promotions';               Key = 'PromotionsEnabled';                   Value = 0;                                Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.search_suggest';         Name = 'Disable Search Suggestions';       Key = 'SearchSuggestEnabled';                Value = 0;                                Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.printing';               Name = 'Disable Printing';                 Key = 'PrintingEnabled';                     Value = 0;                                Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.default_browser';        Name = 'Disable Default Browser Prompt';   Key = 'DefaultBrowserSettingEnabled';        Value = 0;                                Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.devtools';               Name = 'Disable Developer Tools';          Key = 'DeveloperToolsAvailability';          Value = 2;                                Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.wayback';                Name = 'Disable Wayback Machine';          Key = 'BraveWaybackMachineEnabled';          Value = 0;                                Type = 'DWord'; Category = 'Performance'; Origin = $true  }
)

$featureMap = @{}
foreach ($feature in $featureCatalog) {
    $featureMap[$feature.Id] = $feature
}

$presets = [ordered]@{
    'Custom' = @()
    'Origin' = ($featureCatalog | Where-Object { $_.Origin } | ForEach-Object { $_.Id })
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

function Set-DnsSettings {
    param(
        [string]$DnsMode,
        [string]$DnsTemplates
    )

    $resolvedMode = $DnsMode

    if ([string]::IsNullOrWhiteSpace($DnsMode)) {
        return $true
    }

    if ($DnsMode -eq 'custom') {
        if ([string]::IsNullOrWhiteSpace($DnsTemplates)) {
            [System.Windows.Forms.MessageBox]::Show(
                'Custom DoH requires a template URL, e.g. https://cloudflare-dns.com/dns-query',
                'Simple Origin',
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            ) | Out-Null
            return $false
        }
        $resolvedMode = 'secure'
        Set-ItemProperty -Path $script:registryPath -Name 'DnsOverHttpsTemplates' -Value $DnsTemplates -Type String -Force
        if (Test-Path $userRegistryPath) {
            Remove-ItemProperty -Path $userRegistryPath -Name 'DnsOverHttpsTemplates' -ErrorAction SilentlyContinue
        }
    }
    else {
        Remove-ItemProperty -Path $script:registryPath -Name 'DnsOverHttpsTemplates' -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $userRegistryPath -Name 'DnsOverHttpsTemplates' -ErrorAction SilentlyContinue
    }

    Set-ItemProperty -Path $script:registryPath -Name 'DnsOverHttpsMode' -Value $resolvedMode -Type String -Force
    Remove-ItemProperty -Path $userRegistryPath -Name 'DnsOverHttpsMode' -ErrorAction SilentlyContinue
    return $true
}

function Remove-ManagedProperty {
    param([string]$Key)
    Remove-ItemProperty -Path $machineRegistryPath -Name $Key -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $userRegistryPath -Name $Key -ErrorAction SilentlyContinue
}

# ---------------------------------------------------------------------------
# UI setup
# ---------------------------------------------------------------------------

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Simple Origin'
$form.ForeColor = [System.Drawing.Color]::White
$form.Size = New-Object System.Drawing.Size(860, 900)
$form.StartPosition = 'CenterScreen'
$form.BackColor = [System.Drawing.Color]::FromArgb(255, 25, 25, 25)
$form.MaximizeBox = $false
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = 'Simple Origin — Brave policy UI with an Origin preset'
$titleLabel.Location = New-Object System.Drawing.Point(24, 18)
$titleLabel.Size = New-Object System.Drawing.Size(560, 24)
$titleLabel.Font = New-Object System.Drawing.Font('Segoe UI', 11, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($titleLabel)

$subLabel = New-Object System.Windows.Forms.Label
$subLabel.Text = 'Preset "Origin" targets Brave Origin upgrade-like feature parity, not the standalone compiled-out build.'
$subLabel.Location = New-Object System.Drawing.Point(24, 44)
$subLabel.Size = New-Object System.Drawing.Size(700, 18)
$subLabel.ForeColor = [System.Drawing.Color]::Silver
$form.Controls.Add($subLabel)

$presetLabel = New-Object System.Windows.Forms.Label
$presetLabel.Text = 'Preset:'
$presetLabel.Location = New-Object System.Drawing.Point(24, 74)
$presetLabel.Size = New-Object System.Drawing.Size(45, 20)
$form.Controls.Add($presetLabel)

$presetDropdown = New-Object System.Windows.Forms.ComboBox
$presetDropdown.Location = New-Object System.Drawing.Point(76, 71)
$presetDropdown.Size = New-Object System.Drawing.Size(200, 24)
$presetDropdown.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$presetDropdown.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$presetDropdown.BackColor = [System.Drawing.Color]::FromArgb(255, 30, 30, 30)
$presetDropdown.ForeColor = [System.Drawing.Color]::White
$presetDropdown.Items.AddRange(@('Custom','Origin'))
$presetDropdown.SelectedItem = 'Custom'
$form.Controls.Add($presetDropdown)

$applyPresetButton = New-Object System.Windows.Forms.Button
$applyPresetButton.Text = 'Load Preset'
$applyPresetButton.Location = New-Object System.Drawing.Point(286, 70)
$applyPresetButton.Size = New-Object System.Drawing.Size(100, 26)
$applyPresetButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$applyPresetButton.ForeColor = [System.Drawing.Color]::LightSkyBlue
$form.Controls.Add($applyPresetButton)

$scopeLabel = New-Object System.Windows.Forms.Label
$scopeLabel.Text = 'Write scope:'
$scopeLabel.Location = New-Object System.Drawing.Point(430, 74)
$scopeLabel.Size = New-Object System.Drawing.Size(75, 20)
$form.Controls.Add($scopeLabel)

$scopeDropdown = New-Object System.Windows.Forms.ComboBox
$scopeDropdown.Location = New-Object System.Drawing.Point(510, 71)
$scopeDropdown.Size = New-Object System.Drawing.Size(140, 24)
$scopeDropdown.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$scopeDropdown.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$scopeDropdown.BackColor = [System.Drawing.Color]::FromArgb(255, 30, 30, 30)
$scopeDropdown.ForeColor = [System.Drawing.Color]::White
$scopeDropdown.Items.AddRange(@('Machine (HKLM)','User (HKCU)'))
$scopeDropdown.SelectedItem = 'Machine (HKLM)'
$form.Controls.Add($scopeDropdown)

$script:allCheckboxes = @()
$script:checkboxById = @{}

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
    $panel.BackColor = [System.Drawing.Color]::FromArgb(255, 35, 35, 35)
    $panel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $form.Controls.Add($panel)

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Title
    $label.Location = New-Object System.Drawing.Point(18, 10)
    $label.Size = New-Object System.Drawing.Size(($Width - 36), 22)
    $label.Font = New-Object System.Drawing.Font('Segoe UI', 10.5, [System.Drawing.FontStyle]::Bold)
    $label.ForeColor = [System.Drawing.Color]::LightSalmon
    $panel.Controls.Add($label)

    return $panel
}

$leftPanel  = New-SectionPanel -Title 'Telemetry & Privacy' -X 24 -Y 110 -Width 380 -Height 610
$rightPanel = New-SectionPanel -Title 'Brave Features & Performance' -X 432 -Y 110 -Width 390 -Height 610

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
                'Telemetry'   { 'Telemetry & Reporting' }
                'Privacy'     { 'Privacy & Security' }
                'Brave'       { 'Brave Features' }
                'Performance' { 'Performance & Bloat' }
                default       { $group.Name }
            }
            $subheader.Location = New-Object System.Drawing.Point(18, $currentY)
            $subheader.Size = New-Object System.Drawing.Size(320, 20)
            $subheader.Font = New-Object System.Drawing.Font('Segoe UI', 9.5, [System.Drawing.FontStyle]::Bold)
            $subheader.ForeColor = [System.Drawing.Color]::Gainsboro
            $Panel.Controls.Add($subheader)
            $currentY += 26
        }

        foreach ($feature in $group.Group) {
            $cb = New-Object System.Windows.Forms.CheckBox
            $cb.Text = $feature.Name
            $cb.Tag = $feature
            $cb.Location = New-Object System.Drawing.Point(20, $currentY)
            $cb.Size = New-Object System.Drawing.Size(($Panel.Width - 40), 22)
            $cb.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
            $cb.ForeColor = [System.Drawing.Color]::White
            $Panel.Controls.Add($cb)
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

            $currentY += 24
        }
        $currentY += 8
    }
}

Add-FeatureCheckboxes -Panel $leftPanel  -Features ($featureCatalog | Where-Object { $_.Category -in @('Telemetry','Privacy') }) -StartY 36 -ShowSubheaders
Add-FeatureCheckboxes -Panel $rightPanel -Features ($featureCatalog | Where-Object { $_.Category -in @('Brave','Performance') }) -StartY 36 -ShowSubheaders

# DNS block
$dnsGroup = New-SectionPanel -Title 'DNS Over HTTPS' -X 24 -Y 736 -Width 798 -Height 86

$dnsModeLabel = New-Object System.Windows.Forms.Label
$dnsModeLabel.Text = 'Mode:'
$dnsModeLabel.Location = New-Object System.Drawing.Point(20, 40)
$dnsModeLabel.Size = New-Object System.Drawing.Size(42, 20)
$dnsGroup.Controls.Add($dnsModeLabel)

$dnsDropdown = New-Object System.Windows.Forms.ComboBox
$dnsDropdown.Location = New-Object System.Drawing.Point(65, 37)
$dnsDropdown.Size = New-Object System.Drawing.Size(150, 24)
$dnsDropdown.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$dnsDropdown.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$dnsDropdown.BackColor = [System.Drawing.Color]::FromArgb(255, 30, 30, 30)
$dnsDropdown.ForeColor = [System.Drawing.Color]::White
$dnsDropdown.Items.AddRange(@('off','automatic','secure','custom'))
$dnsDropdown.SelectedItem = 'off'
$dnsGroup.Controls.Add($dnsDropdown)

$dnsTemplateLabel = New-Object System.Windows.Forms.Label
$dnsTemplateLabel.Text = 'Custom DoH template URL:'
$dnsTemplateLabel.Location = New-Object System.Drawing.Point(240, 40)
$dnsTemplateLabel.Size = New-Object System.Drawing.Size(160, 20)
$dnsGroup.Controls.Add($dnsTemplateLabel)

$dnsTemplateBox = New-Object System.Windows.Forms.TextBox
$dnsTemplateBox.Location = New-Object System.Drawing.Point(405, 38)
$dnsTemplateBox.Size = New-Object System.Drawing.Size(370, 20)
$dnsTemplateBox.Enabled = $false
$dnsTemplateBox.BackColor = [System.Drawing.Color]::FromArgb(255, 30, 30, 30)
$dnsTemplateBox.ForeColor = [System.Drawing.Color]::White
$dnsGroup.Controls.Add($dnsTemplateBox)

$dnsDropdown.Add_SelectedIndexChanged({
    $dnsTemplateBox.Enabled = ($dnsDropdown.SelectedItem -eq 'custom')
})

# Buttons
$exportButton = New-Object System.Windows.Forms.Button
$exportButton.Text = 'Export'
$exportButton.Location = New-Object System.Drawing.Point(24, 832)
$exportButton.Size = New-Object System.Drawing.Size(110, 30)
$exportButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$exportButton.ForeColor = [System.Drawing.Color]::LightSalmon
$form.Controls.Add($exportButton)

$importButton = New-Object System.Windows.Forms.Button
$importButton.Text = 'Import'
$importButton.Location = New-Object System.Drawing.Point(146, 832)
$importButton.Size = New-Object System.Drawing.Size(110, 30)
$importButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$importButton.ForeColor = [System.Drawing.Color]::LightSkyBlue
$form.Controls.Add($importButton)

$applyButton = New-Object System.Windows.Forms.Button
$applyButton.Text = 'Apply'
$applyButton.Location = New-Object System.Drawing.Point(590, 832)
$applyButton.Size = New-Object System.Drawing.Size(110, 30)
$applyButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$applyButton.ForeColor = [System.Drawing.Color]::LightGreen
$form.Controls.Add($applyButton)

$resetButton = New-Object System.Windows.Forms.Button
$resetButton.Text = 'Reset Managed Policies'
$resetButton.Location = New-Object System.Drawing.Point(712, 832)
$resetButton.Size = New-Object System.Drawing.Size(110, 30)
$resetButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$resetButton.ForeColor = [System.Drawing.Color]::LightCoral
$form.Controls.Add($resetButton)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = 'Ready.'
$statusLabel.Location = New-Object System.Drawing.Point(278, 838)
$statusLabel.Size = New-Object System.Drawing.Size(290, 20)
$statusLabel.ForeColor = [System.Drawing.Color]::Silver
$form.Controls.Add($statusLabel)

function Set-FeatureSelection {
    param([string[]]$FeatureIds)

    foreach ($cb in $script:allCheckboxes) {
        $cb.Checked = $false
    }

    foreach ($id in $FeatureIds) {
        if ($script:checkboxById.ContainsKey($id)) {
            $script:checkboxById[$id].Checked = $true
        }
    }
}

$applyPresetButton.Add_Click({
    $selectedPreset = [string]$presetDropdown.SelectedItem
    if (-not $presets.Contains($selectedPreset)) {
        return
    }
    Set-FeatureSelection -FeatureIds $presets[$selectedPreset]
    $statusLabel.Text = "Loaded preset: $selectedPreset"
})

function Initialize-CurrentSettings {
    foreach ($cb in $script:allCheckboxes) {
        $feature = $cb.Tag
        $policy = Get-PolicySetting -Key $feature.Key
        if ($null -eq $policy) {
            $cb.Checked = $false
            continue
        }

        if ($feature.Type -eq 'DWord') {
            $cb.Checked = ([int]$policy.Value -eq [int]$feature.Value)
        } else {
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
        if ([string]$dnsModePolicy.Value -eq 'secure' -and $dnsTemplatePolicy) {
            $dnsDropdown.SelectedItem = 'custom'
        } else {
            $dnsDropdown.SelectedItem = [string]$dnsModePolicy.Value
        }
    }
    else {
        $dnsDropdown.SelectedItem = 'off'
    }

    if (Test-IsAdmin) {
        $scopeDropdown.SelectedItem = 'Machine (HKLM)'
    } else {
        $scopeDropdown.SelectedItem = 'User (HKCU)'
    }
}

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
    $script:registryPath = if ($scopeDropdown.SelectedItem -eq 'User (HKCU)') { $userRegistryPath } else { $machineRegistryPath }

    if ($script:registryPath -eq $machineRegistryPath -and -not (Test-IsAdmin)) {
        [System.Windows.Forms.MessageBox]::Show(
            'Machine scope requires administrator rights. Switch Write scope to User (HKCU) or relaunch as admin.',
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

    $uniqueKeys = $featureCatalog | ForEach-Object { $_.Key } | Select-Object -Unique
    foreach ($key in $uniqueKeys) {
        if ($selectedFeatures.ContainsKey($key)) {
            $feature = $selectedFeatures[$key]
            Set-ItemProperty -Path $script:registryPath -Name $feature.Key -Value $feature.Value -Type $feature.Type -Force
            if ($script:registryPath -eq $machineRegistryPath) {
                Remove-ItemProperty -Path $userRegistryPath -Name $key -ErrorAction SilentlyContinue
            }
        }
        else {
            Remove-ManagedProperty -Key $key
        }
    }

    if (-not (Set-DnsSettings -DnsMode ([string]$dnsDropdown.SelectedItem) -DnsTemplates $dnsTemplateBox.Text)) {
        return
    }

    $statusLabel.Text = "Applied to $($scopeDropdown.SelectedItem). Restart Brave."
    [System.Windows.Forms.MessageBox]::Show(
        'Settings applied. Restart Brave and check brave://policy if you want to verify the result.',
        'Simple Origin',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
})

$resetButton.Add_Click({
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        'This removes the managed Brave policies touched by this tool from both HKLM and HKCU. Continue?',
        'Simple Origin',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) {
        return
    }

    $uniqueKeys = $featureCatalog | ForEach-Object { $_.Key } | Select-Object -Unique
    foreach ($key in $uniqueKeys) {
        Remove-ManagedProperty -Key $key
    }
    Remove-ManagedProperty -Key 'DnsOverHttpsMode'
    Remove-ManagedProperty -Key 'DnsOverHttpsTemplates'

    foreach ($cb in $script:allCheckboxes) {
        $cb.Checked = $false
    }
    $dnsDropdown.SelectedItem = 'off'
    $dnsTemplateBox.Text = ''
    $presetDropdown.SelectedItem = 'Custom'
    $statusLabel.Text = 'Managed policies reset.'
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
        AppVersion   = '0.1.0'
        Preset       = [string]$presetDropdown.SelectedItem
        FeatureIds   = @((Get-SelectedFeatureObjects) | ForEach-Object { $_.Id })
        FeatureKeys  = @((Get-SelectedFeatureObjects) | ForEach-Object { $_.Key })
        DnsMode      = [string]$dnsDropdown.SelectedItem
        DnsTemplates = [string]$dnsTemplateBox.Text
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
        foreach ($cb in $script:allCheckboxes) {
            $cb.Checked = $false
        }

        if ($payload.PSObject.Properties.Name -contains 'FeatureIds' -and $payload.FeatureIds) {
            Set-FeatureSelection -FeatureIds @($payload.FeatureIds)
        }
        elseif ($payload.PSObject.Properties.Name -contains 'Features' -and $payload.Features) {
            # SlimBrave Neo compatibility: import by policy keys
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
            $dnsDropdown.SelectedItem = [string]$payload.DnsMode
        }
        if ($payload.PSObject.Properties.Name -contains 'DnsTemplates' -and $payload.DnsTemplates) {
            $dnsTemplateBox.Text = [string]$payload.DnsTemplates
            if (-not $payload.DnsMode) {
                $dnsDropdown.SelectedItem = 'custom'
            }
        }

        if ($payload.PSObject.Properties.Name -contains 'Preset' -and $payload.Preset -and $presetDropdown.Items.Contains([string]$payload.Preset)) {
            $presetDropdown.SelectedItem = [string]$payload.Preset
        }
        else {
            $presetDropdown.SelectedItem = 'Custom'
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

Initialize-CurrentSettings
[void]$form.ShowDialog()
