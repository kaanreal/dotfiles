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

if ($BackedUp) {
    Write-Host "old configs: $BackupRoot"
}
