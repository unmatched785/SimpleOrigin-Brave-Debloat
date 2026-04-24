param(
    [switch]$NoAdminRelaunch,
    [switch]$Bootstrap
)

$script:repoOwner = 'unmatched785'
$script:repoName = 'SimpleOrigin-Brave-Debloat'
$script:scriptFileName = 'SimpleOrigin.ps1'
$script:tempFolderName = 'SimpleOrigin-Brave-Debloat'
$script:settingsFileName = 'SimpleOriginBraveDebloatSettings.json'
$script:appDisplayName = 'Simple Origin - Brave Debloat'
$script:RawSourceUrl = "https://raw.githubusercontent.com/$($script:repoOwner)/$($script:repoName)/main/$($script:scriptFileName)"

function Invoke-SimpleOriginBootstrap {
    param([switch]$NoAdminRelaunch)

    $tempRoot = Join-Path $env:TEMP $script:tempFolderName
    $tempPath = Join-Path $tempRoot $script:scriptFileName

    try {
        New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
        $content = Invoke-RestMethod -Uri $script:RawSourceUrl -Headers @{ 'Cache-Control' = 'no-cache' }
        [System.IO.File]::WriteAllText($tempPath, [string]$content, [System.Text.UTF8Encoding]::new($false))
        Unblock-File -Path $tempPath -ErrorAction SilentlyContinue

        $arguments = @(
            '-ExecutionPolicy', 'Bypass',
            '-File', $tempPath,
            '-Bootstrap'
        )

        if ($NoAdminRelaunch) {
            $arguments += '-NoAdminRelaunch'
        }

        Start-Process -FilePath 'powershell' -ArgumentList $arguments | Out-Null
        return $true
    }
    catch {
        Write-Error "$($script:appDisplayName) bootstrap failed: $($_.Exception.Message)"
        return $false
    }
}

if (-not $Bootstrap -and [string]::IsNullOrWhiteSpace($MyInvocation.MyCommand.Path)) {
    if (Invoke-SimpleOriginBootstrap -NoAdminRelaunch:$NoAdminRelaunch) {
        return
    }
    return
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::SetUnhandledExceptionMode([System.Windows.Forms.UnhandledExceptionMode]::CatchException)
[System.Windows.Forms.Application]::add_ThreadException({
    param($sender, $eventArgs)
    [System.Windows.Forms.MessageBox]::Show(
        "Unexpected error: $($eventArgs.Exception.Message)",
        $script:appDisplayName,
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
})

Add-Type -ReferencedAssemblies @('System.Windows.Forms', 'System.Drawing') -TypeDefinition @'
using System;
using System.Drawing;
using System.Windows.Forms;

public class SimpleOriginCheckBox : CheckBox
{
    public Color BoxBorderColor { get; set; }
    public Color BoxBackColor { get; set; }
    public Color CheckMarkColor { get; set; }
    public Color HoverBorderColor { get; set; }
    public Color DisabledBorderColor { get; set; }
    public Color DisabledCheckMarkColor { get; set; }
    public int BoxSize { get; set; }

    private bool _hovered;

    public SimpleOriginCheckBox()
    {
        SetStyle(
            ControlStyles.AllPaintingInWmPaint |
            ControlStyles.OptimizedDoubleBuffer |
            ControlStyles.ResizeRedraw |
            ControlStyles.UserPaint |
            ControlStyles.SupportsTransparentBackColor,
            true
        );

        AutoSize = false;
        UseVisualStyleBackColor = false;

        BoxBorderColor = Color.FromArgb(200, 205, 214);
        BoxBackColor = Color.White;
        CheckMarkColor = Color.FromArgb(53, 107, 187);
        HoverBorderColor = Color.FromArgb(90, 120, 170);
        DisabledBorderColor = Color.FromArgb(180, 180, 180);
        DisabledCheckMarkColor = Color.FromArgb(150, 150, 150);
        BoxSize = 16;
    }

    protected override void OnMouseEnter(EventArgs e)
    {
        _hovered = true;
        Invalidate();
        base.OnMouseEnter(e);
    }

    protected override void OnMouseLeave(EventArgs e)
    {
        _hovered = false;
        Invalidate();
        base.OnMouseLeave(e);
    }

    protected override void OnCheckedChanged(EventArgs e)
    {
        Invalidate();
        base.OnCheckedChanged(e);
    }

    protected override void OnEnabledChanged(EventArgs e)
    {
        Invalidate();
        base.OnEnabledChanged(e);
    }

    protected override void OnTextChanged(EventArgs e)
    {
        Invalidate();
        base.OnTextChanged(e);
    }

    protected override void OnBackColorChanged(EventArgs e)
    {
        Invalidate();
        base.OnBackColorChanged(e);
    }

    protected override void OnForeColorChanged(EventArgs e)
    {
        Invalidate();
        base.OnForeColorChanged(e);
    }

    protected override void OnFontChanged(EventArgs e)
    {
        Invalidate();
        base.OnFontChanged(e);
    }

    protected override void OnPaint(PaintEventArgs e)
    {
        Color surfaceColor = Parent != null ? Parent.BackColor : BackColor;
        using (SolidBrush surfaceBrush = new SolidBrush(surfaceColor))
        {
            e.Graphics.FillRectangle(surfaceBrush, ClientRectangle);
        }

        e.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;

        int boxTop = Math.Max(0, (Height - BoxSize) / 2);
        Rectangle boxRect = new Rectangle(0, boxTop, BoxSize, BoxSize);

        Color borderColor = Enabled
            ? (_hovered ? HoverBorderColor : BoxBorderColor)
            : DisabledBorderColor;

        using (SolidBrush fillBrush = new SolidBrush(BoxBackColor))
        {
            e.Graphics.FillRectangle(fillBrush, boxRect);
        }

        using (Pen borderPen = new Pen(borderColor, 1.4f))
        {
            e.Graphics.DrawRectangle(borderPen, boxRect);
        }

        if (Checked)
        {
            using (Pen checkPen = new Pen(Enabled ? CheckMarkColor : DisabledCheckMarkColor, 2.2f))
            {
                checkPen.StartCap = System.Drawing.Drawing2D.LineCap.Round;
                checkPen.EndCap = System.Drawing.Drawing2D.LineCap.Round;

                Point p1 = new Point(boxRect.Left + 3, boxRect.Top + (BoxSize / 2));
                Point p2 = new Point(boxRect.Left + 7, boxRect.Bottom - 4);
                Point p3 = new Point(boxRect.Right - 3, boxRect.Top + 4);

                e.Graphics.DrawLines(checkPen, new[] { p1, p2, p3 });
            }
        }

        Rectangle textRect = new Rectangle(boxRect.Right + 10, 0, Math.Max(0, Width - (boxRect.Right + 10)), Height);
        TextFormatFlags flags = TextFormatFlags.Left | TextFormatFlags.VerticalCenter | TextFormatFlags.EndEllipsis | TextFormatFlags.NoPrefix;
        Color textColor = Enabled ? ForeColor : SystemColors.GrayText;

        TextRenderer.DrawText(e.Graphics, Text ?? string.Empty, Font, textRect, textColor, flags);

        if (Focused && ShowFocusCues)
        {
            Size measured = TextRenderer.MeasureText(Text ?? string.Empty, Font);
            Rectangle focusRect = new Rectangle(textRect.Left, Math.Max(0, textRect.Top + 4), Math.Min(textRect.Width, measured.Width + 4), Math.Max(12, Height - 8));
            ControlPaint.DrawFocusRectangle(e.Graphics, focusRect);
        }
    }
}
'@


function Test-IsAdmin {
    $current = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($current)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$script:currentScriptPath = if ($PSCommandPath) { $PSCommandPath } else { $MyInvocation.MyCommand.Path }

function Request-ElevatedRelaunch {
    param([string]$Reason)

    if ([string]::IsNullOrWhiteSpace($script:currentScriptPath) -or -not (Test-Path -LiteralPath $script:currentScriptPath)) {
        [System.Windows.Forms.MessageBox]::Show(
            "$Reason Relaunch this script as administrator if you want to write or clear Machine (HKLM) policies.",
            $script:appDisplayName,
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return $false
    }

    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "$Reason`r`n`r`nRelaunch as administrator now?",
        $script:appDisplayName,
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) {
        return $false
    }

    try {
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$script:currentScriptPath`" -Bootstrap -NoAdminRelaunch" -Verb RunAs
        return $true
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Administrator rights were not granted. The app will continue in the current user context.",
            $script:appDisplayName,
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return $false
    }
}

$machineRegistryPath = "HKLM:\SOFTWARE\Policies\BraveSoftware\Brave"
$userRegistryPath    = "HKCU:\SOFTWARE\Policies\BraveSoftware\Brave"
$script:registryPath = $userRegistryPath
$script:toolVersion  = '0.5.4'
$script:appWindowTitle = $script:appDisplayName

function Test-IsMachinePolicyPath {
    param([string]$Path)
    return ([string]$Path -like 'HKLM:\*')
}

function Test-CanAccessPolicyPath {
    param([string]$Path)

    if ((Test-IsMachinePolicyPath -Path $Path) -and -not (Test-IsAdmin)) {
        return $false
    }

    try {
        return [bool](Test-Path -Path $Path -ErrorAction Stop)
    }
    catch {
        return $false
    }
}

function Ensure-PolicyPathExists {
    param([string]$Path)

    if ((Test-IsMachinePolicyPath -Path $Path) -and -not (Test-IsAdmin)) {
        return $false
    }

    if (-not (Test-CanAccessPolicyPath -Path $Path)) {
        New-Item -Path $Path -Force -ErrorAction Stop | Out-Null
    }

    return $true
}

function Test-CanWritePolicyPath {
    param([string]$Path)

    $testName = '__SimpleOriginWriteTest'

    try {
        if (-not (Ensure-PolicyPathExists -Path $Path)) {
            return $false
        }

        New-ItemProperty -Path $Path -Name $testName -Value 1 -PropertyType DWord -Force -ErrorAction Stop | Out-Null
        Remove-ItemProperty -Path $Path -Name $testName -ErrorAction SilentlyContinue
        return $true
    }
    catch {
        Remove-ItemProperty -Path $Path -Name $testName -ErrorAction SilentlyContinue
        return $false
    }
}

function Test-RegistryKeyIsEmpty {
    param([string]$Path)

    try {
        if (-not (Test-CanAccessPolicyPath -Path $Path)) { return $true }

        $item = Get-Item -Path $Path -ErrorAction Stop
        if (-not $item) { return $true }

        if ($item.GetSubKeyNames().Count -gt 0) { return $false }

        $props = (Get-ItemProperty -Path $Path -ErrorAction Stop).PSObject.Properties |
            Where-Object { $_.Name -notlike 'PS*' }

        return ($props.Count -eq 0)
    }
    catch {
        return $false
    }
}

function Cleanup-PolicyPathTree {
    param([string]$LeafPath)

    if ((Test-IsMachinePolicyPath -Path $LeafPath) -and -not (Test-IsAdmin)) {
        return $false
    }

    if (Test-RegistryKeyIsEmpty -Path $LeafPath) {
        Remove-Item -Path $LeafPath -Force -ErrorAction SilentlyContinue
    }

    $parent = Split-Path -Path $LeafPath -Parent
    if ($parent -and (Test-CanAccessPolicyPath -Path $parent) -and (Test-RegistryKeyIsEmpty -Path $parent)) {
        Remove-Item -Path $parent -Force -ErrorAction SilentlyContinue
    }

    return $true
}

$featureCatalog = @(
    @{ Id = 'telemetry.safebrowsing_rep';  Name = 'Disable Safe Browsing Reporting';  Key = 'SafeBrowsingExtendedReportingEnabled';    Value = 0;                           Type = 'DWord'; Category = 'Telemetry';   Origin = $false },
    @{ Id = 'telemetry.url_data';          Name = 'Disable URL Data Collection';      Key = 'UrlKeyedAnonymizedDataCollectionEnabled'; Value = 0;                           Type = 'DWord'; Category = 'Telemetry';   Origin = $false },
    @{ Id = 'telemetry.feedback';          Name = 'Disable Feedback Surveys';         Key = 'FeedbackSurveysEnabled';                  Value = 0;                           Type = 'DWord'; Category = 'Telemetry';   Origin = $false },
    @{ Id = 'telemetry.p3a';               Name = 'Disable P3A Analytics';            Key = 'BraveP3AEnabled';                        Value = 0;                           Type = 'DWord'; Category = 'Telemetry';   Origin = $true  },
    @{ Id = 'telemetry.stats_ping';        Name = 'Disable Stats Ping';               Key = 'BraveStatsPingEnabled';                  Value = 0;                           Type = 'DWord'; Category = 'Telemetry';   Origin = $true  },

    @{ Id = 'privacy.safe_browsing';       Name = 'Disable Safe Browsing';            Key = 'SafeBrowsingProtectionLevel';            Value = 0;                           Type = 'DWord'; Category = 'Privacy';     Origin = $false; Advanced = $true  },
    @{ Id = 'privacy.autofill_addr';       Name = 'Disable Autofill (Addresses)';     Key = 'AutofillAddressEnabled';                 Value = 0;                           Type = 'DWord'; Category = 'Privacy';     Origin = $false; Advanced = $true  },
    @{ Id = 'privacy.autofill_cards';      Name = 'Disable Autofill (Credit Cards)';  Key = 'AutofillCreditCardEnabled';              Value = 0;                           Type = 'DWord'; Category = 'Privacy';     Origin = $false; Advanced = $true  },
    @{ Id = 'privacy.password_manager';    Name = 'Disable Password Manager';         Key = 'PasswordManagerEnabled';                 Value = 0;                           Type = 'DWord'; Category = 'Privacy';     Origin = $false; Advanced = $true  },
    @{ Id = 'privacy.browser_signin';      Name = 'Disable Browser Sign-in';          Key = 'BrowserSignin';                          Value = 0;                           Type = 'DWord'; Category = 'Privacy';     Origin = $false; Advanced = $true  },
    @{ Id = 'privacy.gpc';                 Name = 'Enable Global Privacy Control';    Key = 'BraveGlobalPrivacyControlEnabled';       Value = 1;                           Type = 'DWord'; Category = 'Privacy';     Origin = $false },
    @{ Id = 'privacy.deamp';               Name = 'Auto-Redirect AMP Pages';          Key = 'BraveDeAmpEnabled';                      Value = 1;                           Type = 'DWord'; Category = 'Privacy';     Origin = $false },
    @{ Id = 'privacy.language_fp';         Name = 'Reduce Language Fingerprinting';   Key = 'BraveReduceLanguageEnabled';             Value = 1;                           Type = 'DWord'; Category = 'Privacy';     Origin = $false },
    @{ Id = 'privacy.webrtc';              Name = 'Disable WebRTC IP Leak';           Key = 'WebRtcIPHandling';                       Value = 'disable_non_proxied_udp';    Type = 'String'; Category = 'Privacy';    Origin = $false },
    @{ Id = 'privacy.quic';                Name = 'Disable QUIC Protocol';            Key = 'QuicAllowed';                            Value = 0;                           Type = 'DWord'; Category = 'Privacy';     Origin = $false },
    @{ Id = 'privacy.third_party_cookies'; Name = 'Block Third Party Cookies';        Key = 'BlockThirdPartyCookies';                 Value = 1;                           Type = 'DWord'; Category = 'Privacy';     Origin = $false },
    @{ Id = 'privacy.tracking_params';     Name = 'Filter Tracking URL Parameters';   Key = 'BraveTrackingQueryParametersFilteringEnabled'; Value = 1;                    Type = 'DWord'; Category = 'Privacy';     Origin = $false },
    @{ Id = 'privacy.safe_search';         Name = 'Force Google SafeSearch';          Key = 'ForceGoogleSafeSearch';                  Value = 1;                           Type = 'DWord'; Category = 'Privacy';     Origin = $false; Advanced = $true  },
    @{ Id = 'privacy.disable_incognito';   Name = 'Disable Incognito Mode';           Key = 'IncognitoModeAvailability';              Value = 1;                           Type = 'DWord'; Category = 'Privacy';     Origin = $false; Advanced = $true; ExclusiveGroup = 'incognito_mode' },
    @{ Id = 'privacy.force_incognito';     Name = 'Force Incognito Mode';             Key = 'IncognitoModeAvailability';              Value = 2;                           Type = 'DWord'; Category = 'Privacy';     Origin = $false; Advanced = $true; ExclusiveGroup = 'incognito_mode' },

    @{ Id = 'brave.rewards';               Name = 'Disable Brave Rewards';            Key = 'BraveRewardsDisabled';                   Value = 1;                           Type = 'DWord'; Category = 'Brave';       Origin = $true  },
    @{ Id = 'brave.wallet';                Name = 'Disable Brave Wallet';             Key = 'BraveWalletDisabled';                    Value = 1;                           Type = 'DWord'; Category = 'Brave';       Origin = $true  },
    @{ Id = 'brave.vpn';                   Name = 'Disable Brave VPN';                Key = 'BraveVPNDisabled';                       Value = 1;                           Type = 'DWord'; Category = 'Brave';       Origin = $true  },
    @{ Id = 'brave.ai_chat';               Name = 'Disable Brave AI Chat';            Key = 'BraveAIChatEnabled';                     Value = 0;                           Type = 'DWord'; Category = 'Brave';       Origin = $true  },
    @{ Id = 'brave.news';                  Name = 'Disable Brave News';               Key = 'BraveNewsDisabled';                      Value = 1;                           Type = 'DWord'; Category = 'Brave';       Origin = $true  },
    @{ Id = 'brave.talk';                  Name = 'Disable Brave Talk';               Key = 'BraveTalkDisabled';                      Value = 1;                           Type = 'DWord'; Category = 'Brave';       Origin = $true  },
    @{ Id = 'brave.playlist';              Name = 'Disable Brave Playlist';           Key = 'BravePlaylistEnabled';                   Value = 0;                           Type = 'DWord'; Category = 'Brave';       Origin = $true  },
    @{ Id = 'brave.web_discovery';         Name = 'Disable Web Discovery';            Key = 'BraveWebDiscoveryEnabled';               Value = 0;                           Type = 'DWord'; Category = 'Brave';       Origin = $true  },
    @{ Id = 'brave.speedreader';           Name = 'Disable Speedreader';              Key = 'BraveSpeedreaderEnabled';                Value = 0;                           Type = 'DWord'; Category = 'Brave';       Origin = $true  },
    @{ Id = 'brave.tor';                   Name = 'Disable Tor';                      Key = 'TorDisabled';                            Value = 1;                           Type = 'DWord'; Category = 'Brave';       Origin = $true  },
    @{ Id = 'brave.sync';                  Name = 'Disable Sync';                     Key = 'SyncDisabled';                           Value = 1;                           Type = 'DWord'; Category = 'Brave';       Origin = $false; Advanced = $true  },

    @{ Id = 'perf.background';             Name = 'Disable Background Mode';          Key = 'BackgroundModeEnabled';                  Value = 0;                           Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.media_recs';             Name = 'Disable Media Recommendations';    Key = 'MediaRecommendationsEnabled';            Value = 0;                           Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.shopping';               Name = 'Disable Shopping List';            Key = 'ShoppingListEnabled';                    Value = 0;                           Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.pdf_external';           Name = 'Always Open PDF Externally';       Key = 'AlwaysOpenPdfExternally';                Value = 1;                           Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.translate';              Name = 'Disable Translate';                Key = 'TranslateEnabled';                       Value = 0;                           Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.spellcheck';             Name = 'Disable Spellcheck';               Key = 'SpellcheckEnabled';                      Value = 0;                           Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.promotions';             Name = 'Disable Promotions';               Key = 'PromotionsEnabled';                      Value = 0;                           Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.search_suggest';         Name = 'Disable Search Suggestions';       Key = 'SearchSuggestEnabled';                   Value = 0;                           Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.printing';               Name = 'Disable Printing';                 Key = 'PrintingEnabled';                        Value = 0;                           Type = 'DWord'; Category = 'Performance'; Origin = $false; Advanced = $true  },
    @{ Id = 'perf.default_browser';        Name = 'Disable Default Browser Prompt';   Key = 'DefaultBrowserSettingEnabled';           Value = 0;                           Type = 'DWord'; Category = 'Performance'; Origin = $false },
    @{ Id = 'perf.devtools';               Name = 'Disable Developer Tools';          Key = 'DeveloperToolsAvailability';             Value = 2;                           Type = 'DWord'; Category = 'Performance'; Origin = $false; Advanced = $true  },
    @{ Id = 'perf.wayback';                Name = 'Disable Wayback Machine';          Key = 'BraveWaybackMachineEnabled';             Value = 0;                           Type = 'DWord'; Category = 'Performance'; Origin = $true  }
)

$legacyManagedPolicyKeys = @(
    'MetricsReportingEnabled'
)

$featureMap = @{}
foreach ($feature in $featureCatalog) {
    $featureMap[$feature.Id] = $feature
}

$originPreset = @(
    'telemetry.p3a',
    'telemetry.stats_ping',
    'brave.rewards',
    'brave.wallet',
    'brave.vpn',
    'brave.ai_chat',
    'brave.news',
    'brave.talk',
    'brave.playlist',
    'brave.web_discovery',
    'brave.speedreader',
    'brave.tor',
    'perf.wayback'
)

$hardeningPreset = @(
    'telemetry.url_data',
    'telemetry.p3a',
    'telemetry.stats_ping',
    'privacy.gpc',
    'privacy.deamp',
    'privacy.language_fp',
    'privacy.webrtc',
    'privacy.third_party_cookies',
    'privacy.tracking_params',
    'brave.rewards',
    'brave.wallet',
    'brave.ai_chat',
    'brave.web_discovery',
    'perf.background',
    'perf.search_suggest'
)

$originAndHardeningPreset = @($originPreset + $hardeningPreset | Select-Object -Unique)

$presets = [ordered]@{
    'Origin - Recommended' = $originPreset
    'Origin + Hardening'  = $originAndHardeningPreset
    'Hardening'           = $hardeningPreset
    'Custom'              = @()
}

$presetDescriptions = [ordered]@{
    'Origin - Recommended' = 'Recommended preset for most users: Origin-like debloating for regular Brave with low setup risk.'
    'Origin + Hardening'  = 'Privacy-oriented preset: Origin-like debloating plus practical privacy hardening.'
    'Hardening'           = 'Practical privacy hardening preset for regular Brave without high-friction lock-down policies.'
    'Custom'              = 'Manual selection. Choose each policy toggle yourself.'
}

$presetAliases = @{
    'Origin'                           = 'Origin - Recommended'
    'Origin + Hardening - Recommended' = 'Origin + Hardening'
}

$dohPresets = [ordered]@{
    'Manual'                         = ''
    'Cloudflare (1.1.1.1)'           = 'https://cloudflare-dns.com/dns-query'
    'Cloudflare Security (1.1.1.2)'  = 'https://security.cloudflare-dns.com/dns-query'
    'Cloudflare Family (1.1.1.3)'    = 'https://family.cloudflare-dns.com/dns-query'
    'Quad9 Secure (9.9.9.9)'         = 'https://dns.quad9.net/dns-query'
    'Google Public DNS (8.8.8.8)'    = 'https://dns.google/dns-query'
    'NextDNS Public'                 = 'https://dns.nextdns.io'
    'NextDNS Custom Profile'         = 'https://dns.nextdns.io/YOUR_PROFILE_ID'
}

function Get-ManagedPolicyKeys {
    $keys = @(
        ($featureCatalog | ForEach-Object { $_.Key } | Select-Object -Unique)
        $legacyManagedPolicyKeys
        'DnsOverHttpsMode'
        'DnsOverHttpsTemplates'
    ) | Select-Object -Unique

    return @($keys)
}

function Get-PolicyPropertiesAtPath {
    param([string]$Path)

    try {
        if (-not (Test-CanAccessPolicyPath -Path $Path)) {
            return $null
        }

        return Get-ItemProperty -Path $Path -ErrorAction Stop
    }
    catch {
        return $null
    }
}

function Get-PolicySetting {
    param([string]$Key)
    $machineSettings = Get-PolicyPropertiesAtPath -Path $machineRegistryPath
    $userSettings    = Get-PolicyPropertiesAtPath -Path $userRegistryPath

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
    $machineSettings = Get-PolicyPropertiesAtPath -Path $machineRegistryPath
    $userSettings    = Get-PolicyPropertiesAtPath -Path $userRegistryPath

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

    if (-not (Ensure-PolicyPathExists -Path $Path)) {
        return $false
    }

    try {
        New-ItemProperty -Path $Path -Name $Key -Value $Value -PropertyType $Type -Force -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Remove-ManagedPropertyFromPath {
    param(
        [string]$Key,
        [string]$Path
    )

    try {
        if ((Test-IsMachinePolicyPath -Path $Path) -and -not (Test-IsAdmin)) {
            return $false
        }

        if (-not (Test-CanAccessPolicyPath -Path $Path)) {
            return $true
        }

        $item = Get-ItemProperty -Path $Path -ErrorAction Stop
        if ($item -and ($item.PSObject.Properties.Name -contains $Key)) {
            Remove-ItemProperty -Path $Path -Name $Key -ErrorAction Stop
        }

        [void](Cleanup-PolicyPathTree -LeafPath $Path)
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

    if ((Test-IsMachinePolicyPath -Path $OtherPath) -and -not (Test-IsAdmin)) {
        Add-OtherScopeWarning -Warnings $OtherScopeWarnings -ScopeName $OtherScopeName -Key $Key
        return
    }

    if (-not (Remove-ManagedPropertyFromPath -Key $Key -Path $OtherPath)) {
        Add-OtherScopeWarning -Warnings $OtherScopeWarnings -ScopeName $OtherScopeName -Key $Key
    }
}

function Test-DohTemplate {
    param([string]$Template)

    if ([string]::IsNullOrWhiteSpace($Template)) {
        return 'Custom DoH requires a template URL, e.g. https://cloudflare-dns.com/dns-query'
    }

    $trimmed = $Template.Trim()
    if ($trimmed -match '\s') {
        return 'Custom DoH template URLs cannot contain whitespace.'
    }
    if ($trimmed -match 'YOUR_PROFILE_ID') {
        return 'Replace YOUR_PROFILE_ID with your real NextDNS profile ID before applying.'
    }

    $uri = $null
    if (-not [System.Uri]::TryCreate($trimmed, [System.UriKind]::Absolute, [ref]$uri) -or $uri.Scheme -ne 'https') {
        return 'Custom DoH requires an absolute https:// template URL.'
    }

    return $null
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
        $validationError = Test-DohTemplate -Template $DnsTemplates
        if ($validationError) {
            [System.Windows.Forms.MessageBox]::Show(
                $validationError,
                $script:appDisplayName,
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            ) | Out-Null
            return $false
        }

        $resolvedMode = 'secure'
        if (-not (Set-ManagedPropertyAtPath -Path $TargetPath -Key 'DnsOverHttpsTemplates' -Value $DnsTemplates.Trim() -Type String)) {
            return $false
        }
    }
    else {
        [void](Remove-ManagedPropertyFromPath -Key 'DnsOverHttpsTemplates' -Path $TargetPath)
    }

    if (-not (Set-ManagedPropertyAtPath -Path $TargetPath -Key 'DnsOverHttpsMode' -Value $resolvedMode -Type String)) {
        return $false
    }
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

$form.Text = $script:appWindowTitle
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
$titleLabel.Text = $script:appDisplayName
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
$scopeHintLabel.Text = "Recommended: User (HKCU) for most personal PCs. Apply makes the selected scope authoritative for this tool's managed keys when possible."
$scopeHintLabel.Location = New-Object System.Drawing.Point(868, 76)
$scopeHintLabel.Size = New-Object System.Drawing.Size(297, 40)
$scopeHintLabel.AutoEllipsis = $true
$scopeHintLabel.UseMnemonic = $false
$form.Controls.Add($scopeHintLabel)
Register-MutedLabel $scopeHintLabel

$presetDescriptionLabel = New-Object System.Windows.Forms.Label
$presetDescriptionLabel.Text = [string]$presetDescriptions['Origin - Recommended']
$presetDescriptionLabel.Location = New-Object System.Drawing.Point(24, 108)
$presetDescriptionLabel.Size = New-Object System.Drawing.Size(1140, 20)
$presetDescriptionLabel.AutoEllipsis = $true
$presetDescriptionLabel.UseMnemonic = $false
$form.Controls.Add($presetDescriptionLabel)
Register-MutedLabel $presetDescriptionLabel

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
$dnsHintLabel.AutoEllipsis = $true
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
        $themeButton.Text = 'Light'
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
        $themeButton.Text = 'Dark'
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
    if ($presetDropdown.Items.Contains($matchingPreset)) {
        $presetDropdown.SelectedItem = $matchingPreset
    }
    else {
        $presetDropdown.SelectedItem = 'Custom'
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
    try {
        $scopeInfo = Get-WriteScopeInfo -ScopeSelection ([string]$scopeDropdown.SelectedItem)
        $script:registryPath = [string]$scopeInfo.TargetPath

        if ($scopeInfo.ScopeName -eq 'Machine' -and -not (Test-IsAdmin)) {
            if (Request-ElevatedRelaunch -Reason 'Machine scope requires administrator rights.') {
                $form.Close()
            }
            return
        }

        if (-not (Test-CanWritePolicyPath -Path $scopeInfo.TargetPath)) {
            if (-not (Test-IsAdmin)) {
                if (Request-ElevatedRelaunch -Reason "$($scopeInfo.ScopeName) policy path is not writable in the current session. This can happen when existing Brave policy keys were created by an elevated process.") {
                    $form.Close()
                }
                return
            }

            throw "$($scopeInfo.ScopeName) policy path is not writable."
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
                if (-not (Set-ManagedPropertyAtPath -Path $scopeInfo.TargetPath -Key $feature.Key -Value $feature.Value -Type $feature.Type)) {
                    throw "Could not write policy key: $($feature.Key)"
                }
            }
            else {
                [void](Remove-ManagedPropertyFromPath -Key $key -Path $scopeInfo.TargetPath)
            }

            if ($scopeInfo.ScopeName -eq 'Machine' -or (Test-IsAdmin)) {
                Clear-OtherScopeManagedProperty -Key $key -OtherPath $scopeInfo.OtherPath -OtherScopeName $otherScopeName -OtherScopeWarnings $otherScopeWarnings
            }
        }

        foreach ($legacyKey in $legacyManagedPolicyKeys) {
            [void](Remove-ManagedPropertyFromPath -Key $legacyKey -Path $scopeInfo.TargetPath)
            if ($scopeInfo.ScopeName -eq 'Machine' -or (Test-IsAdmin)) {
                Clear-OtherScopeManagedProperty -Key $legacyKey -OtherPath $scopeInfo.OtherPath -OtherScopeName $otherScopeName -OtherScopeWarnings $otherScopeWarnings
            }
        }

        if (-not (Set-DnsSettings -DnsMode ([string]$dnsDropdown.SelectedItem) -DnsTemplates $dnsTemplateBox.Text -TargetPath $scopeInfo.TargetPath -OtherPath $scopeInfo.OtherPath -TargetScopeName $scopeInfo.ScopeName -OtherScopeWarnings $otherScopeWarnings)) {
            Initialize-CurrentSettings
            return
        }

        if (Test-IsAdmin) {
            [void](Cleanup-PolicyPathTree -LeafPath $machineRegistryPath)
        }
        [void](Cleanup-PolicyPathTree -LeafPath $userRegistryPath)

        Initialize-CurrentSettings

        if ($otherScopeWarnings.Count -gt 0) {
            $statusLabel.Text = "Applied to $($scopeInfo.ScopeName) scope. Some $otherScopeName-scope keys could not be cleared."
            [System.Windows.Forms.MessageBox]::Show(
                "Settings were written to $($scopeInfo.ScopeName) scope. However, some $otherScopeName-scope keys could not be cleared, so Brave may still prefer those values. Use Reset Managed Policies or relaunch as admin if you want a clean single-scope state.",
                $script:appDisplayName,
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            ) | Out-Null
        }
        else {
            $statusLabel.Text = "Applied to $($scopeInfo.ScopeName) scope. Restart Brave."
            [System.Windows.Forms.MessageBox]::Show(
                "Settings applied. For the keys managed by this tool, $($scopeInfo.ScopeName) scope is now authoritative. Restart Brave and check brave://policy if you want to verify the result.",
                $script:appDisplayName,
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            ) | Out-Null
        }
    }
    catch {
        $statusLabel.Text = 'Apply failed.'
        [System.Windows.Forms.MessageBox]::Show(
            "Apply failed: $($_.Exception.Message)",
            $script:appDisplayName,
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
})

$resetButton.Add_Click({
    try {
        $scopeSummary = Get-ManagedScopeSummary
        if ($scopeSummary.HasMachine -and -not (Test-IsAdmin)) {
            if (Request-ElevatedRelaunch -Reason 'Reset Managed Policies needs administrator rights because Machine (HKLM) keys are present.') {
                $form.Close()
            }
            return
        }

        $confirm = [System.Windows.Forms.MessageBox]::Show(
            'This removes the managed Brave policies touched by this tool from both HKLM and HKCU. Continue?',
            $script:appDisplayName,
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )

        if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) {
            return
        }

        foreach ($key in (Get-ManagedPolicyKeys)) {
            Remove-ManagedPropertyEverywhere -Key $key
        }

        [void](Cleanup-PolicyPathTree -LeafPath $machineRegistryPath)
        [void](Cleanup-PolicyPathTree -LeafPath $userRegistryPath)
        Initialize-CurrentSettings
        $statusLabel.Text = 'Managed policies reset from HKLM and HKCU.'
    }
    catch {
        $statusLabel.Text = 'Reset failed.'
        [System.Windows.Forms.MessageBox]::Show(
            "Reset failed: $($_.Exception.Message)",
            $script:appDisplayName,
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
})

$exportButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.SaveFileDialog
    $dialog.Filter = 'JSON files (*.json)|*.json|All files (*.*)|*.*'
    $dialog.Title = "Export $($script:appDisplayName) Settings"
    $dialog.InitialDirectory = [Environment]::GetFolderPath('MyDocuments')
    $dialog.FileName = $script:settingsFileName

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
    $dialog.Title = "Import $($script:appDisplayName) Settings"
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

        $importPreset = if ($payload.PSObject.Properties.Name -contains 'Preset' -and $payload.Preset) { [string]$payload.Preset } else { '' }
        if ($presetAliases.ContainsKey($importPreset)) {
            $importPreset = [string]$presetAliases[$importPreset]
        }

        if (-not [string]::IsNullOrWhiteSpace($importPreset) -and $presetDropdown.Items.Contains($importPreset)) {
            $presetDropdown.SelectedItem = $importPreset
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
            $script:appDisplayName,
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
})

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
