# Simple Origin

Simple Origin is a Windows PowerShell GUI for configuring **Brave managed policies**.

It focuses on three things:

- one-by-one policy toggles
- a built-in **Origin** preset for an Origin-upgrade-like setup
- a built-in **Hardening** preset for a stricter privacy setup

## What it is

Simple Origin is a **policy UI for regular Brave**.

It aims to get close to **Brave Origin upgrade-like behavior** through managed policies. It does **not** modify Brave binaries, and it does **not** reproduce the separate compiled-out standalone build.

## Included presets

### Origin
The **Origin** preset is the closest preset to Brave Origin upgrade-like behavior.

It focuses on Brave feature removal and telemetry reduction without bundling extra hardening choices that go beyond that scope.

### Hardening
The **Hardening** preset is stricter.

It adds privacy-oriented controls such as:

- Safe Browsing reporting off
- URL data collection off
- feedback surveys off
- browser sign-in off
- Global Privacy Control on
- Do Not Track on
- WebRTC non-proxied UDP restriction
- QUIC off
- third-party cookies blocked
- Sync off
- extra Brave UI/bloat reduction

Use **Origin** when you want the closest Origin-like preset.
Use **Hardening** when you want a broader privacy-oriented preset.

## Scope recommendation

**Recommended default: User (HKCU).**

Use **User (HKCU) — Recommended** for most personal PCs.
Use **Machine (HKLM)** only when you intentionally want system-wide Brave policy for all users on the device.

## DNS over HTTPS presets

Included presets:

- Manual
- Cloudflare (1.1.1.1)
- Cloudflare Security (1.1.1.2)
- Cloudflare Family (1.1.1.3)
- Quad9 Secure (9.9.9.9)
- Google Public DNS (8.8.8.8)
- NextDNS Public
- NextDNS Custom Profile

Selecting a DNS preset fills the template URL and switches the mode to `custom`.

## Running locally

Open PowerShell in the same folder and run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\SimpleOrigin.ps1
```

## One-line GitHub raw launch

For a public repository:

```powershell
iwr "https://raw.githubusercontent.com/unmatched785/SimpleOrigin/main/SimpleOrigin.ps1" -OutFile "SimpleOrigin.ps1"; .\SimpleOrigin.ps1
```

If Windows blocks direct local script execution:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr 'https://raw.githubusercontent.com/unmatched785/SimpleOrigin/main/SimpleOrigin.ps1' -OutFile $env:TEMP\SimpleOrigin.ps1; & $env:TEMP\SimpleOrigin.ps1"
```

## Notes

- Light theme is the default. Dark mode is optional via the top-right toggle.
- Restart Brave after applying settings.
- Verify results in `brave://policy` if needed.
- **Reset Managed Policies** removes the Brave policy values touched by this tool from both HKCU and HKLM.
