# Simple Origin - Brave Debloat 0.5.0

## Highlights

- The app now opens without immediately requesting administrator rights.
- Machine-scope Apply and Reset actions ask for elevation only when HKLM access is actually needed.
- Custom DNS-over-HTTPS templates are validated before policies are written.
- The repository now includes build verification for the modular `src` files and the published `SimpleOrigin.ps1` launcher.

## Recommended launch

```powershell
irm https://raw.githubusercontent.com/unmatched785/SimpleOrigin-Brave-Debloat/refs/tags/0.5.0/SimpleOrigin.ps1|iex
```

## Notes

- User (HKCU) remains the recommended write scope for most personal PCs.
- Restart Brave after applying changes, then verify effective policies in `brave://policy`.
- Use Machine (HKLM) only when you intentionally want system-wide Brave policies for all users.
