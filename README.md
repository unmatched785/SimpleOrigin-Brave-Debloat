# Simple Origin

Simple Origin is a Windows PowerShell GUI for configuring **Brave managed policies** with:

- one-by-one feature toggles
- an **Origin** preset that aims to match **Brave Origin upgrade** as closely as policy control allows
- DNS-over-HTTPS presets
- JSON import/export
- compatibility import for older SlimBrave Neo JSON exports

## What it is

Simple Origin is a **policy UI for regular Brave**.

It is designed to get close to **Brave Origin upgrade mode**, not to reproduce the separate **Brave Origin standalone** build.

That means:

- it can disable many Brave features through managed policies
- it cannot compile features out of the Brave binary
- it cannot become a true standalone Origin replacement without a separate Brave build

## Included preset

### Origin
The **Origin** preset targets the currently documented Brave Origin **upgrade-like** feature set through policy control:

- Leo / AI Chat
- News
- Playlist
- Rewards
- Speedreader
- P3A / daily usage ping / metrics reporting
- Talk
- Tor
- VPN
- Wallet
- Wayback Machine
- Web Discovery

It intentionally does **not** bundle unrelated hardening choices like QUIC disabling, third-party cookie blocking, password manager disabling, or DoH forcing, because those are not core Brave Origin behaviors.

## Scope recommendation

**Recommended default: User (HKCU).**

Use **User (HKCU) — Recommended** for most personal PCs.  
Use **Machine (HKLM)** only when you intentionally want system-wide Brave policy for all users on the device.

## DNS presets included

- Cloudflare (1.1.1.1)
- Cloudflare Security (1.1.1.2)
- Cloudflare Family (1.1.1.3)
- Quad9 Secure (9.9.9.9)
- Google Public DNS (8.8.8.8)
- NextDNS Public
- NextDNS Custom Profile
- Manual

Selecting a DNS preset fills the DoH template and switches the mode to `custom`.

## Running locally

Open PowerShell and run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\SimpleOrigin.ps1
```

## One-liner for GitHub raw hosting

Public repo example:

```powershell
iwr "https://raw.githubusercontent.com/unmatched785/SimpleOrigin/main/SimpleOrigin.ps1" -OutFile "SimpleOrigin.ps1"; .\SimpleOrigin.ps1
```

If Windows blocks local script execution, use:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr 'https://raw.githubusercontent.com/unmatched785/SimpleOrigin/main/SimpleOrigin.ps1' -OutFile $env:TEMP\SimpleOrigin.ps1; & $env:TEMP\SimpleOrigin.ps1"
```

## Notes

- Light theme is the default. Dark theme is optional via the top-right toggle.
- After applying settings, restart Brave and verify with `brave://policy`.
- **Reset Managed Policies** removes the Brave policy values touched by this tool from both HKCU and HKLM.
