# PowerShell 7 port of dots/fish/config.fish for Windows.
# Fish has no native Windows build (only Cygwin/MSYS2/WSL), so this stays native.

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$Dots = "$HOME\dotfiles"

# Reload PATH from the registry. Explorer keeps a stale copy after installs,
# so anything started from it (Kitsu too) would miss new tools until re-login.
$env:PATH = [Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [Environment]::GetEnvironmentVariable('Path', 'Machine')

# kitty-hotkey.exe fakes --single-instance and needs Kitsu's public key, which only
# Kitsu's own shells get. The first shell of a listening Kitsu writes it down.
if ($env:KITTY_PUBLIC_KEY -and $env:KITTY_LISTEN_ON -like '*127.0.0.1:47811') {
    $keyFile = "$env:LOCALAPPDATA\Kitsu\instance\key"
    if (-not (Test-Path $keyFile)) { [IO.File]::WriteAllText($keyFile, $env:KITTY_PUBLIC_KEY) }
    Remove-Variable keyFile
}

foreach ($dir in "$HOME\.local\bin", "$HOME\.bun\bin", "$HOME\.cargo\bin") {
    if ((Test-Path $dir) -and ($env:PATH -notlike "*$dir*")) {
        $env:PATH = "$dir;$env:PATH"
    }
}

# starship/zoxide init output is cached, spawning them on every start costs ~100ms.
# The cache refreshes when the exe or this profile gets updated. Its first line is the exe
# it came from, so a normal start never searches PATH (the first lookup costs ~20ms).
function Get-InitCache {
    param([string]$Name, [string[]]$InitArgs, [scriptblock]$Patch)

    $cache = "$env:LOCALAPPDATA\pwsh-init\$Name.ps1"
    $cached = Get-Item $cache -ErrorAction Ignore
    $exe = if ($cached) { (Get-Content $cache -TotalCount 1) -replace '^# ' }
    $profileTime = (Get-Item "$Dots\devices\windows\dots\pwsh\profile.ps1").LastWriteTime
    if (-not $cached -or -not $exe -or -not (Test-Path $exe) -or
        (Get-Item $exe).LastWriteTime -gt $cached.LastWriteTime -or $profileTime -gt $cached.LastWriteTime) {
        $exe = (Get-Command $Name -CommandType Application -ErrorAction Ignore | Select-Object -First 1).Source
        if (-not $exe) { return $null }
        $init = (& $exe @InitArgs) -join "`n"
        if ($Patch) { $init = & $Patch $exe $init }
        New-Item -ItemType Directory -Force -Path (Split-Path $cache) | Out-Null
        Set-Content $cache "# $exe`n$init" -Encoding utf8
    }
    return $cache
}

# Starship custom prompt. Its init asks starship for the continuation prompt on every start
# and runs the prompt through System.Diagnostics.Process, ~20ms more than baking the
# continuation prompt in and calling it with &.
$init = Get-InitCache starship 'init', 'powershell', '--print-full-init' -Patch {
    param($exe, $init)
    $continuation = ((& $exe prompt --continuation) -join "`n").Replace("'", "''")
    $init = $init -replace '(?s)Set-PSReadLineOption -ContinuationPrompt \(\s*Invoke-Native.*?\n    \)', "Set-PSReadLineOption -ContinuationPrompt '$continuation'"
    $init.Replace("Invoke-Native -Executable '$exe' -Arguments `$arguments", "(& '$exe' @arguments) -join `"``n`"")
}
if ($init) { . $init }

# Zoxide
$init = Get-InitCache zoxide 'init', 'powershell', '--cmd', 'cd'
if ($init) { . $init }
Remove-Variable init

# Better ls (checked when used, a PATH lookup at startup costs ~20ms)
Remove-Item Alias:ls -Force -ErrorAction Ignore
function ls {
    if (Get-Command eza -CommandType Application -ErrorAction Ignore) { eza --icons --group-directories-first -1 @args }
    else { Get-ChildItem @args }
}

# --- fish-ish line editing ---
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -PredictionSource History -PredictionViewStyle InlineView
Set-PSReadLineOption -HistoryNoDuplicates -BellStyle None
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+f -Function AcceptSuggestion
Set-PSReadLineKeyHandler -Key Alt+f -Function AcceptNextSuggestionWord

# Beige theme, same colors as dots/fish/conf.d/theme.fish
function Get-Rgb([string]$Hex, [switch]$Bg) {
    $r = [Convert]::ToInt32($Hex.Substring(1, 2), 16)
    $g = [Convert]::ToInt32($Hex.Substring(3, 2), 16)
    $b = [Convert]::ToInt32($Hex.Substring(5, 2), 16)
    "`e[$(if ($Bg) { 48 } else { 38 });2;$r;$g;${b}m"
}
Set-PSReadLineOption -Colors @{
    Default          = Get-Rgb '#d4a96a'
    Command          = Get-Rgb '#d4a96a'
    Parameter        = Get-Rgb '#d4a96a'
    Error            = Get-Rgb '#d4a96a'
    Keyword          = Get-Rgb '#d4a96a'
    Variable         = Get-Rgb '#d4a96a'
    Member           = Get-Rgb '#d4a96a'
    Number           = Get-Rgb '#d4a96a'
    Type             = Get-Rgb '#d4a96a'
    String           = Get-Rgb '#7db87d'
    Operator         = Get-Rgb '#7a9ec2'
    Comment          = Get-Rgb '#9a9389'
    Emphasis         = Get-Rgb '#d4a96a'
    Selection        = (Get-Rgb '#332C25' -Bg) + (Get-Rgb '#e8e6e3')
    InlinePrediction = Get-Rgb '#4a453b'
    ListPrediction   = Get-Rgb '#9a9389'
}

# --- Abbrs ---
# Expanded on space/enter like fish, so history keeps the real command.
# Also avoids fighting PowerShell's built-in gc/gl/gp aliases.
$Abbrs = @{
    lg   = 'lazygit'
    gd   = 'git diff'
    ga   = 'git add .'
    gc   = 'git commit -am'
    gl   = 'git log'
    gs   = 'git status'
    gst  = 'git stash'
    gsp  = 'git stash pop'
    gp   = 'git push'
    gpl  = 'git pull'
    gsw  = 'git switch'
    gsm  = 'git switch main'
    gb   = 'git branch'
    gbd  = 'git branch -d'
    gco  = 'git checkout'
    gsh  = 'git show'

    l    = 'ls'
    ll   = 'ls -l'
    la   = 'ls -a'
    lla  = 'ls -la'

    # Jump to the repo
    dots = 'cd $HOME/dotfiles'
}

function Expand-Abbr {
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ($cursor -ne $line.Length) { return }

    # only the word in command position, same as fish
    if ($line -match '(^|[;|]\s*|&&\s*|\|\|\s*)(\S+)$' -and $Abbrs.ContainsKey($Matches[2])) {
        $word = $Matches[2]
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($line.Length - $word.Length, $word.Length, $Abbrs[$word])
    }
}

Set-PSReadLineKeyHandler -Key Spacebar -ScriptBlock {
    Expand-Abbr
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert(' ')
}
Set-PSReadLineKeyHandler -Key Enter -ScriptBlock {
    Expand-Abbr
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# --- Functions (ports of dots/fish/functions) ---

# Commit + push a snapshot of ~/dotfiles (no empty commits, no force-push).
function save {
    $repo = $Dots

    if (-not (Test-Path "$repo\.git")) {
        Write-Host "skip: ~/dotfiles is not a git repository"
        return
    }

    Write-Host "==> saving ~/dotfiles"

    $hasOrigin = $null -ne (git -C $repo remote get-url origin 2>$null)
    if ($hasOrigin) {
        git -C $repo fetch origin
        if ($LASTEXITCODE) { Write-Host "fetch failed; nothing was staged or committed"; return }

        $branch = git -C $repo branch --show-current
        if (-not $branch) { Write-Host "refusing to save from a detached HEAD"; return }

        $upstream = "origin/$branch"
        git -C $repo rev-parse --verify $upstream 2>$null | Out-Null
        if ($LASTEXITCODE) { Write-Host "missing upstream branch: $upstream"; return }

        $behind = [int](-split (git -C $repo rev-list --left-right --count "HEAD...$upstream"))[1]
        if ($behind -ne 0) {
            Write-Host "remote has $behind commit(s) this checkout does not have"
            Write-Host "pull and resolve that first; nothing was staged or committed"
            return
        }
    }

    git -C $repo add -A
    if ($LASTEXITCODE) { Write-Host "failed to stage changes"; return }

    git -C $repo diff --cached --quiet
    if (-not $LASTEXITCODE) { Write-Host "    nothing new; skipping commit"; return }

    $emojis = '🌸', '🌷', '🍃', '🧁', '🐰', '❄️', '🧸', '🍓', '🐈'
    $msg = "$($emojis | Get-Random) $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    git -C $repo commit -m $msg
    if ($LASTEXITCODE) { Write-Host "commit failed"; return }

    if ($hasOrigin) {
        git -C $repo push origin
        if ($LASTEXITCODE) { Write-Host "    committed locally, but push failed" }
    } else {
        Write-Host "    no remote; committed locally, skipped push"
    }
}

# Pull upstream Caelestia config changes into dots/ (vendored subtree).
function dots-update {
    $repo = $Dots

    if (-not (Test-Path "$repo\.git")) { Write-Host "~/dotfiles is not a git repository"; return }
    if (git -C $repo status --porcelain) { Write-Host "dotfiles is not clean; commit or stash changes first"; return }

    git -C $repo fetch caelestia-upstream
    if ($LASTEXITCODE) { return }

    git -C $repo subtree pull --prefix dots caelestia-upstream main
    if ($LASTEXITCODE) { Write-Host "merge needs attention; resolve the conflicts in ~/dotfiles/dots"; return }

    Write-Host "Caelestia dots updated. Restart the shell."
}

# fish_greeting (inside Kitsu, kitsu-shell.cmd already printed it before pwsh started)
if (-not $env:KITSU_GREETED -and (Get-Command fastfetch -CommandType Application -ErrorAction Ignore)) { fastfetch }
Remove-Item Env:KITSU_GREETED -ErrorAction Ignore
