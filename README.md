# Simple Origin

A Windows PowerShell GUI for Brave managed policies, with:

- one-by-one feature toggles
- an **Origin** preset that aims to match **Brave Origin upgrade** as closely as policy control allows
- import/export of JSON settings
- DNS-over-HTTPS controls
- compatibility import for older SlimBrave Neo JSON exports

## What it is

Simple Origin is a **policy UI** for regular Brave.
It is designed to get close to **Brave Origin upgrade mode**, not to reproduce the separate **Brave Origin standalone** build.

That means:

- it can disable many Brave features through managed policies
- it cannot compile features out of the binary
- it cannot become a true standalone Origin replacement without a separate Brave build

## Included preset

### Origin
Targets the official Brave Origin feature set as closely as possible through policy control:

- Leo / AI Chat
- News
- Playlist
- Rewards
- Speedreader
- P3A / stats ping / metrics reporting
- Talk
- Tor
- VPN
- Wallet
- Wayback Machine
- Web Discovery

DNS is intentionally left separate from the preset, because Brave Origin itself is not primarily a DoH preset.

## Running locally

Open PowerShell and run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\SimpleOrigin.ps1
```

## One-liner for GitHub raw hosting

After uploading `SimpleOrigin.ps1` to your repo, the intended one-liner is:

```powershell
iwr "https://raw.githubusercontent.com/unmatched785/SimpleOrigin/main/SimpleOrigin.ps1" -OutFile "SimpleOrigin.ps1"; .\SimpleOrigin.ps1
```

## Notes

- The script defaults to **Machine (HKLM)** when elevated and **User (HKCU)** otherwise.
- After applying settings, restart Brave and verify with `brave://policy`.
- Import supports both this tool's JSON format and SlimBrave Neo's `Features` key format.
