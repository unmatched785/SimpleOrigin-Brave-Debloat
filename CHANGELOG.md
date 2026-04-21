# Changelog

All notable changes to this project will be documented in this file.

## 0.4.2 - 2026-04-21

### Added

- Added Privacy Guides-aligned hardening toggles for AMP redirects, language fingerprinting reduction, and tracking URL parameter filtering.
- Added a dedicated **Advanced / High Friction** section for restrictive policy toggles that are useful, but not good defaults for most users.

### Changed

- Switched the default recommendation to `Origin - Recommended` and kept `Origin + Hardening` as a separate privacy-oriented preset.
- Refined the hardening catalog to stay focused on practical Brave-compatible controls and retired stale or ignored policy toggles.

### Fixed

- Fixed preset labeling and layout flow so the Advanced section sits under Telemetry and Privacy, while older preset names still import cleanly.

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
