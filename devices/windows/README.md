# Windows

Install the terminal stuff first (Windows 10 is fine):

```powershell
winget install --exact --id Microsoft.PowerShell
winget install --exact --id Starship.Starship
winget install --exact --id Fastfetch-cli.Fastfetch
winget install --exact --id ajeetdsouza.zoxide
winget install --exact --id eza-community.eza
winget install --exact --id JesseDuffield.lazygit
winget install --exact --id SourceFoundry.HackFonts
```

Then run this from PowerShell after cloning to `$HOME\dotfiles`:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/link-windows-dots.ps1
```

The script links Neovim, Windows-specific VS Code settings, the Windows Git
configuration, and the terminal setup. Enable Windows Developer Mode first so file symlinks can be
created without an elevated shell. Existing files are backed up under
`$HOME\.local\state\dotfiles-backups\`.

`dots/minecraft/` is a profile snapshot, not the active `%APPDATA%\.minecraft`
directory. It is intentionally not linked automatically.

## Terminal

Kitty itself has no official Windows build, so this uses
[Kitsu](https://github.com/fhaze/kitsu/releases), a native Win32 fork of kitty,
with the exact shared `dots/kitty/kitty.conf`. Install the `setup.exe` with the
PATH option. If it feels slow, run `kitsu +health-check --mode=native`: when it
says llvmpipe, it's rendering on the CPU and your GPU driver needs a look.

On NVIDIA the window stays solid even with `background_opacity`. In NVIDIA
Control Panel, add `kitsu.exe` under Manage 3D settings > Program settings and
set "Vulkan/OpenGL present method" to "Prefer native".

Fish only runs through MSYS2/Cygwin on
Windows, which is what made `cd` and the prompt slow, so the shell is
PowerShell 7 set up to feel like fish.

- `dots/kitty/kitty.conf`: includes the shared kitty.conf, then sets the shell
  to `pwsh` and turns off socket remote control. The MSYS2 fish line is there
  commented out if you want to compare. The Mac's cmd binds are on Ctrl here
  (Win+anything belongs to Explorer): Ctrl+T/W for tabs, Ctrl+1-9, Ctrl+C copies
  when something is selected, Ctrl+=/-/0 for the font size.
- `dots/pwsh/profile.ps1`: config.fish ported. Starship, zoxide as `cd`, eza
  as `ls`, the same abbrs (they expand on space like fish), history
  suggestions, the beige theme, `save` and `dots-update`.
- `dots/fastfetch/config.jsonc`: the shared layout with Windows things in it
  (Explorer, dark mode and accent, the real GPU, C:, the audio device). The Mori
  logo uses `kitty-direct`, since `kitten icat` isn't there.
- Starship uses the shared `dots/starship.toml` as is.

Kitsu has no `--single-instance` on Windows, so `kitty-hotkey.exe` fakes it,
for Win+T and for the Start menu `kitty` entry (`kitty-hotkey.exe --open`). The
first launch starts Kitsu listening on `127.0.0.1:47811` with a fresh random
password that may only `launch`, later launches ask that Kitsu for a window.
That's ~65ms with kitty open, ~350ms when Kitsu has to start. Win+T inside kitty
opens a tab. Closing the last window quits Kitsu, nothing runs in the background.

The ~350ms is mostly Windows and NVIDIA creating the window and its OpenGL
context, the config makes no difference. The prompt shows up ~450ms after the
window, that's pwsh itself (~290ms before the profile even runs). A spare window
kept ready in the background made it instant but cost ~270MB the whole time, so
that's gone again.

The link script also renames the Apps & features entry to kitty and swaps
Kitsu's fox for `kitty.app.png` in notifications. A Kitsu update undoes that
(and brings back `Kitsu.lnk`), rerun the script then. Task Manager and the name
in the notification header stay Kitsu, they come from Kitsu's signed binaries.

starship and zoxide init scripts are cached in `%LOCALAPPDATA%\pwsh-init` and
regenerate when either exe or the profile gets updated. The starship one is
patched on the way in (continuation prompt baked in, prompt called with `&`).
Delete that folder if the prompt acts weird.
