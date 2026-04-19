# Simple Origin

Simple Origin is a Windows PowerShell GUI for configuring **Brave managed policies** on **regular Brave**.

It gives you:

- one-by-one policy toggles
- preset-based setup for common configurations
- DNS-over-HTTPS presets
- import/export for repeatable setups

## What this project is

Simple Origin is a **policy UI for regular Brave**.

Its goal is to get close to **Brave Origin-like feature reduction** using **officially supported Brave / Chromium policy surfaces**. It does **not** patch Brave binaries, and it does **not** try to reproduce the separate standalone Brave Origin build.

## Why the Brave Origin context matters

Brave Origin itself is an official minimal Brave variant / upgrade.  
Simple Origin is **not** that product.

This repo exists for users who want a cleaner, more controlled **regular Brave** setup through managed policies, while staying on the documented configuration path that Brave already supports.

## Included presets

### Origin + Hardening — Recommended
The default recommended preset.

This combines an Origin-like Brave feature reduction set with a practical privacy-hardening layer.

It is the best starting point for most users who want a cleaner Brave configuration without manually selecting every toggle.

### Origin
The closest preset to **Brave Origin-like behavior** using managed policies.

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

## Write scope behavior

**Recommended default: User (HKCU).**

Use **User (HKCU) — Recommended** for most personal PCs.  
Use **Machine (HKLM)** only when you intentionally want system-wide Brave policy for all users on the device.

### v0.3.0 scope behavior

In v0.3.0, **Apply is scope-aware**.

For the keys managed by this tool, Apply now tries to make the **selected scope authoritative** by:

1. writing the selected state to the chosen scope, and
2. clearing the same managed keys from the other scope when possible

This avoids stale mixed HKCU/HKLM states where the UI says one thing but Brave still prefers another because of policy precedence.

If Machine-scope keys cannot be cleared while writing to User scope, Simple Origin will warn you that Brave may still prefer the Machine values.

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

Selecting a DNS preset fills the template URL and switches the UI mode to `custom`.

### DoH behavior in this project

- `browser default (unset)` removes the tool-managed DoH policy values
- `custom` means the UI will write a DoH template and set the managed mode needed for template-based DoH
- preset selection is just a convenience layer over the same policy fields

## Policy coverage and limits

This project is **managed-policy first**.

That means:

- it only exposes settings that map cleanly to Brave / Chromium policy
- it intentionally avoids pretending that every Brave setting has a safe policy equivalent
- it prefers correctness over “more toggles”

### Important note about Brave Shields

v0.3.0 intentionally **does not** expose a global **Disable Brave Shields** toggle.

The Brave policy surface for Shields uses **site lists**, not a true “disable Shields everywhere” global policy.  
Because of that, exposing a fake global toggle would be misleading.

A future release may add a **site-specific Shields allow/disable list editor**, but that is separate from a global toggle.

## Compatibility

Brave supports Chromium policies plus Brave-specific policies, but **policy availability depends on Brave version**.

Because of that:

- some newer Brave-specific policies may only work on newer Brave builds
- `brave://policy` is the best place to verify what actually took effect
- unsupported policy keys may not show or may simply be ignored by older versions

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
- If you declined elevation, User-scope Apply still works, but clearing conflicting Machine-scope values may fail.
- This tool does not modify Brave binaries and does not try to impersonate the separate Brave Origin product.

## Roadmap

Near-term follow-up items after v0.3.0:

- deferred elevation instead of admin prompt on launch
- better mixed-scope conflict reporting
- site-specific Brave Shields list management
- clearer per-policy compatibility / minimum-version notes
- possible future **experimental** layer for non-policy Brave settings that cannot be enforced safely through managed policies
