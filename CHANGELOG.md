# Changelog

All notable changes to this project will be documented in this file.

## 0.4.0 - 2026-04-20

### Added

- Added a `Clear Checks` button so every policy checkbox can be cleared without immediately applying registry changes.

### Changed

- Bumped the app version to `0.4.0`.
- Made the main window screen-aware and scrollable so smaller laptop displays can still reach the bottom action row, including `Apply`.
- Hardened startup sizing so the laptop-friendly layout falls back safely if working-area detection is unavailable.
- Updated the README to document the selection-clearing workflow and point readers to the changelog for release history.

### Fixed

- Fixed the one-line launcher bootstrap used by `irm https://raw.githubusercontent.com/unmatched785/SimpleOrigin/main/SimpleOrigin.ps1 | iex` so the temp-file UTF-8 write path no longer throws a PowerShell parser error during raw launches.
- Updated the bootstrap temp-file encoding to UTF-8 with BOM so Windows PowerShell 5.1 machines don't misread non-ASCII script content during raw launches.
