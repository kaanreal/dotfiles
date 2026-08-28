# Windows

Run this from PowerShell after cloning to `$HOME\dotfiles`:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/link-windows-dots.ps1
```

The script links Neovim, Windows-specific VS Code settings, and the Windows Git
configuration. Enable Windows Developer Mode first so file symlinks can be
created without an elevated shell. Existing files are backed up under
`$HOME\.local\state\dotfiles-backups\`.

`dots/minecraft/` is a profile snapshot, not the active `%APPDATA%\.minecraft`
directory. It is intentionally not linked automatically.
