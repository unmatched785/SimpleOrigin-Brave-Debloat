# Simple Origin

Simple Origin is a Windows PowerShell GUI for configuring **Brave managed policies**.

It gives you:

- one-by-one policy toggles
- preset-based setup for common configurations
- DNS-over-HTTPS presets
- import/export for repeatable setups

## What this is

Simple Origin is a **policy UI for regular Brave**.

It aims to get close to **Brave Origin upgrade-like behavior** through managed policies. It does **not** modify Brave binaries, and it does **not** reproduce the separate compiled-out standalone build.

## Included presets

### Origin + Hardening — Recommended
The default recommended preset.

This combines an Origin-like Brave feature reduction set with a practical privacy-hardening layer.

It is the best starting point for most users who want a cleaner Brave configuration without manually selecting every toggle.

### Origin
The closest preset to **Brave Origin upgrade-like behavior** using managed policies.

It focuses on Brave feature removal and core telemetry reduction without bundling extra hardening choices that go beyond that scope.

### Hardening
A stricter privacy-oriented preset inspired by public Brave hardening guidance.

It focuses on the parts that map cleanly to managed policies, such as:

- reduced telemetry
- WebRTC non-proxied UDP restriction
- blocking third-party cookies
- disabling search suggestions
- disabling background mode
- disabling Rewards and Wallet

### Custom
Manual mode. Choose each policy toggle yourself.

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

## Safety notes

- Light theme is the default. Dark mode is optional via the top-right toggle.
- Restart Brave after applying settings.
- Verify results in `brave://policy` if needed.
- **Reset Managed Policies** removes the Brave policy values touched by this tool from both HKCU and HKLM.
- This tool is designed around managed policies first. Some Brave settings do not map cleanly to managed policies and are therefore not forced by this project.

## Roadmap

Planned next direction:

- refine preset behavior further
- improve preset-to-current-state detection
- investigate a future **experimental** layer for non-policy Brave settings that cannot be enforced safely through managed policies alone
