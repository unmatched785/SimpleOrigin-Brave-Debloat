# Dependency Updates

SimpleOrigin is mostly PowerShell, so Dependabot is used for GitHub Actions
updates rather than package dependency updates.

## Policy

- GitHub Actions dependencies are checked weekly.
- Action updates are grouped into one pull request.
- A Dependabot PR should be merged only after the `Verify build` workflow
  passes.
- The workflow parses source files, rebuilds `SimpleOrigin.ps1`, and confirms
  the generated script is current.

## Why This Is Enough For Now

SimpleOrigin does not currently depend on npm, NuGet, Cargo, or another package
manifest that Dependabot should manage. The useful automation is keeping
workflow actions current while CI protects the packaged PowerShell script.
