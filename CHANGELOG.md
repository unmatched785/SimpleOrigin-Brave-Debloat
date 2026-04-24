# Changelog

All notable changes to this project will be documented in this file.

## 0.6.0 - 2026-04-24

### Changed

- Changed the launch model to require administrator rights, matching the behavior of Windows utilities that manage system policy.
- Updated the README one-line launch instructions to tell users to open PowerShell as Administrator first.
- Simplified the expected permission model so protected HKCU/HKLM policy keys do not fail unpredictably during Apply.

## 0.5.4 - 2026-04-24

### Fixed

- Added a writeability preflight for the selected policy path before Apply writes policy values.
- Detected read-only HKCU policy keys created by elevated processes and offered an administrator relaunch instead of failing mid-apply.
- Switched policy writes to `New-ItemProperty -Force` and surfaced per-key write failures with clearer messages.

## 0.5.3 - 2026-04-24

### Fixed

- Added a WinForms thread exception handler so registry permission failures cannot surface the default component exception dialog.
- Avoided Machine-scope cleanup attempts entirely during non-admin User-scope Apply.
- Guarded startup policy detection so restricted registry reads cannot interrupt app startup.

## 0.5.2 - 2026-04-24

### Fixed

- Hardened registry reads so restricted HKLM policy keys cannot surface WinForms unhandled exception dialogs in non-admin sessions.
- Added top-level Apply and Reset error handling so unexpected registry failures are reported through the app instead of the default component exception dialog.

## 0.5.1 - 2026-04-24

### Fixed

- Fixed noisy HKLM permission errors when applying User (HKCU) policies without administrator rights.
- Skipped Machine-scope cleanup automatically in non-admin sessions while preserving the existing mixed-scope warning.

## 0.5.0 - 2026-04-24

### Added

- Added deferred elevation for Machine-scope Apply and Reset flows instead of prompting for administrator rights on launch.
- Added validation for custom DNS-over-HTTPS template URLs, including placeholder NextDNS profile detection.
- Added a GitHub Actions build verification workflow that parses source files, rebuilds `SimpleOrigin.ps1`, and checks that the published script is current.
- Added a release-pinned one-line launcher example to the README and release notes under `docs/releases/`.

### Changed

- Changed the default internal write path to User (HKCU), matching the recommended default scope in the UI and README.
- Updated README safety notes to clarify that administrator rights are requested only for Machine-scope operations.

## 0.4.2 - 2026-04-21

### Added

- Added Privacy Guides-aligned hardening toggles for AMP redirects, language fingerprinting reduction, and tracking URL parameter filtering.

### Changed

- Switched the default recommendation to `Origin - Recommended` and kept `Origin + Hardening` as a separate privacy-oriented preset.
- Refined the hardening catalog to stay focused on practical Brave-compatible controls and retired stale or ignored policy toggles.
- Restored the classic left/right/bottom layout, removed the separate Advanced panel, and kept higher-friction toggles available through the normal category lists.
- Removed the version number from the window title while keeping the internal release version at `0.4.2`.

### Fixed

- Fixed preset labeling so older preset names still import cleanly.

## 0.4.1 - 2026-04-20

### Fixed

- Hardened startup sizing so the laptop-friendly layout falls back safely if working-area detection is unavailable.
- Updated the one-line launcher bootstrap to write the temp script as UTF-8 without BOM so the `irm ... | iex` path does not surface `﻿param` parse failures.
- Replaced non-ASCII UI text in the published launcher and now build `SimpleOrigin.ps1` without BOM so the raw-launch path and the temp-file relaunch stay byte-for-byte aligned.

### Notes

- This is a stabilization patch for `0.4.0`. The main user-facing goal is to make `irm https://raw.githubusercontent.com/unmatched785/SimpleOrigin-Brave-Debloat/main/SimpleOrigin.ps1 | iex` behave consistently across desktops and laptops.

## 0.4.0 - 2026-04-20

### Added

- Added a `Clear Checks` button so every policy checkbox can be cleared without immediately applying registry changes.

### Changed

- Bumped the app version to `0.4.0`.
- Made the main window screen-aware and scrollable so smaller laptop displays can still reach the bottom action row, including `Apply`.
- Updated the README to document the selection-clearing workflow and point readers to the changelog for release history.

### Fixed

- Fixed the one-line launcher bootstrap used by `irm https://raw.githubusercontent.com/unmatched785/SimpleOrigin-Brave-Debloat/main/SimpleOrigin.ps1 | iex` so the temp-file UTF-8 write path no longer throws a PowerShell parser error during raw launches.
