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

