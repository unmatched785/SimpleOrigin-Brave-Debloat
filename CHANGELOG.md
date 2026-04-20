# Changelog

All notable changes to this project will be documented in this file.

## 0.4.1 - 2026-04-20

### Fixed

- Hardened startup sizing so the laptop-friendly layout falls back safely if working-area detection is unavailable.
- Updated the one-line launcher bootstrap to write the temp script as UTF-8 with BOM for Windows PowerShell 5.1 compatibility.
- Replaced non-ASCII UI text in the published launcher and now build `SimpleOrigin.ps1` with UTF-8 BOM to reduce locale-sensitive parse failures on some laptops.

### Notes

- This is a stabilization patch for `0.4.0`. The main user-facing goal is to make `irm https://raw.githubusercontent.com/unmatched785/SimpleOrigin/main/SimpleOrigin.ps1 | iex` behave consistently across desktops and laptops.

## 0.4.0 - 2026-04-20

### Added

- Added a `Clear Checks` button so every policy checkbox can be cleared without immediately applying registry changes.

### Changed

- Bumped the app version to `0.4.0`.
- Made the main window screen-aware and scrollable so smaller laptop displays can still reach the bottom action row, including `Apply`.
- Updated the README to document the selection-clearing workflow and point readers to the changelog for release history.

### Fixed

- Fixed the one-line launcher bootstrap used by `irm https://raw.githubusercontent.com/unmatched785/SimpleOrigin/main/SimpleOrigin.ps1 | iex` so the temp-file UTF-8 write path no longer throws a PowerShell parser error during raw launches.
