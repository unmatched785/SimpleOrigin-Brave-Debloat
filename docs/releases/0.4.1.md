# Simple Origin - Brave Debloat 0.4.1

`0.4.1` is a stabilization patch for the `0.4.0` release.

This update focuses on one thing: making the one-line launcher and the desktop app start more reliably across different Windows laptops and desktops.

## Highlights

- Improved startup sizing fallback so the app still opens safely when working-area detection behaves differently on some laptops.
- Updated the `irm ... | iex` bootstrap path to write the temp script as UTF-8 without BOM so the launcher no longer trips over `﻿param` at line 1.
- Replaced non-ASCII UI text in the published launcher and now build `SimpleOrigin.ps1` without BOM so the raw-launch path stays parser-safe.

## Why this patch exists

Some systems could launch the app normally while others failed immediately with PowerShell parse errors near the top of the script. The main goal of `0.4.1` is to make that startup path behave more predictably across mixed Windows environments.

## Upgrade

You can keep using the same one-line command:

```powershell
irm https://raw.githubusercontent.com/unmatched785/SimpleOrigin-Brave-Debloat/main/SimpleOrigin.ps1|iex
```

## Included from 0.4.0

- `Clear Checks` button to clear all policy selections without applying changes.
- Screen-aware, scrollable window layout so smaller laptop displays can still reach the bottom action row.
