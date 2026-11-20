$ErrorActionPreference = "Stop"

$Repo = Split-Path -Parent $PSScriptRoot
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupRoot = Join-Path $HOME ".local\state\dotfiles-backups\$Stamp-windows"
$BackedUp = $false

function Link-Dotfile {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Target,
        [ValidateSet("SymbolicLink", "Junction")][string]$Type = "SymbolicLink"
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        throw "missing repo config: $Source"
    }

    $Current = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
    if ($null -ne $Current) {
        if ($Current.LinkType -and $Current.Target -eq $Source) {
            Write-Host "ok      $Target"
            return
        }

        $Relative = $Target.Substring($HOME.Length).TrimStart("\\")
        $Backup = Join-Path $BackupRoot $Relative
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Backup) | Out-Null
        Move-Item -LiteralPath $Target -Destination $Backup
        $script:BackedUp = $true
        Write-Host "backup  $Target"
    }

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Target) | Out-Null
    New-Item -ItemType $Type -Path $Target -Target $Source | Out-Null
    Write-Host "link    $Target -> $Source"
}

Link-Dotfile "$Repo\dots\nvim" "$env:LOCALAPPDATA\nvim" "Junction"
Link-Dotfile "$Repo\devices\windows\dots\vscode\settings.json" "$env:APPDATA\Code\User\settings.json"
Link-Dotfile "$Repo\devices\windows\dots\vscode\keybindings.json" "$env:APPDATA\Code\User\keybindings.json"
Link-Dotfile "$Repo\devices\windows\dots\git\gitconfig" "$HOME\.gitconfig"
Link-Dotfile "$Repo\dots\git\ignore_global" "$HOME\.gitignore_global"

# terminal: kitsu + pwsh + starship + fastfetch
Link-Dotfile "$Repo\devices\windows\dots\kitty\kitty.conf" "$HOME\.config\kitty\kitty.conf"
# window icon, same one the Mac uses (Kitsu still loads kitty.app.png like kitty on Linux)
Link-Dotfile "$Repo\devices\windows\dots\kitty\kitty.app.png" "$HOME\.config\kitty\kitty.app.png"
$Documents = [Environment]::GetFolderPath("MyDocuments")
Link-Dotfile "$Repo\devices\windows\dots\pwsh\profile.ps1" "$Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
Link-Dotfile "$Repo\dots\starship.toml" "$HOME\.config\starship.toml"
Link-Dotfile "$Repo\devices\windows\dots\fastfetch\config.jsonc" "$HOME\.config\fastfetch\config.jsonc"

# fast kitsu launch: Win+T and the Start menu entry reuse a running Kitsu (see kitty-hotkey.c)
function Set-Shortcut {
    param([string]$Path, [string]$Target, [string]$Arguments, [string]$Icon)

    $Shell = New-Object -ComObject WScript.Shell
    $Link = $Shell.CreateShortcut($Path)
    if ($Link.TargetPath -eq $Target -and $Link.Arguments -eq $Arguments -and (-not $Icon -or $Link.IconLocation -eq "$Icon,0")) {
        Write-Host "ok      $Path"
        return
    }
    $Link.TargetPath = $Target
    $Link.Arguments = $Arguments
    $Link.WorkingDirectory = $HOME
    if ($Icon) { $Link.IconLocation = "$Icon,0" }
    $Link.Save()
    Write-Host "lnk     $Path"
}

$Hotkey = "$Repo\devices\windows\dots\kitty\hotkey\kitty-hotkey.exe"
$Icon = "$Repo\devices\windows\dots\kitty\kitty.ico"
# The installer's Kitsu.lnk carries the AppUserModelID (fhaze.Kitsu) its windows use, so the
# taskbar takes name and icon from it. Renamed to kitty.lnk rather than recreated, to keep that ID.
# A Kitsu update brings Kitsu.lnk back, rerun this script then.
$Programs = [Environment]::GetFolderPath('Programs')
if (Test-Path "$Programs\Kitsu.lnk") {
    Move-Item "$Programs\Kitsu.lnk" "$Programs\kitty.lnk" -Force
    Write-Host "rename  $Programs\Kitsu.lnk -> kitty.lnk"
}
Set-Shortcut "$Programs\kitty.lnk" $Hotkey "--open" $Icon

# The rest of Windows still says Kitsu with the fox. Apps & features reads the installer's
# uninstall entry, notifications use Kitsu's logo file as their icon. A Kitsu update undoes
# both, rerun this script then. The name in the notification header and Task Manager come
# from Kitsu's signed binaries, those stay Kitsu.
$Uninstall = Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall" |
    Where-Object { (Get-ItemProperty $_.PSPath).Publisher -eq "FHaze" } | Select-Object -First 1
if ($Uninstall -and (Get-ItemProperty $Uninstall.PSPath).DisplayName -ne "kitty") {
    Set-ItemProperty $Uninstall.PSPath -Name DisplayName -Value "kitty"
    Set-ItemProperty $Uninstall.PSPath -Name DisplayIcon -Value $Icon
    Write-Host "reg     Apps & features: Kitsu -> kitty"
}
$KitsuLogo = "$env:LOCALAPPDATA\Programs\Kitsu\lib\kitty\logo\kitsu.png"
$AppIcon = "$Repo\devices\windows\dots\kitty\kitty.app.png"
if ((Test-Path $KitsuLogo) -and (Get-FileHash $KitsuLogo).Hash -ne (Get-FileHash $AppIcon).Hash) {
    Copy-Item $AppIcon $KitsuLogo -Force
    Write-Host "copy    kitty.app.png -> $KitsuLogo"
}

# Win+T opens kitty (see kitty-hotkey.c). Explorer gives up Win+T after the next sign-in.
$Advanced = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$Disabled = [string](Get-ItemProperty $Advanced -Name DisabledHotkeys -ErrorAction Ignore).DisabledHotkeys
if ($Disabled -cnotmatch "T") {
    Set-ItemProperty $Advanced -Name DisabledHotkeys -Value ($Disabled + "T")
    Write-Host "reg     DisabledHotkeys += T (sign out once so Explorer lets go of Win+T)"
}
Set-Shortcut "$([Environment]::GetFolderPath('Startup'))\kitty-hotkey.lnk" $Hotkey "" ""

if ($BackedUp) {
    Write-Host "old configs: $BackupRoot"
}
