@echo off
rem Kitsu's shell: fastfetch first, then pwsh.
rem pwsh needs ~300ms before the profile even runs, so printing fastfetch from the profile
rem left the window empty that long. fastfetch alone takes ~40ms, so now the window fills
rem right away and the prompt shows up underneath while you read. It runs next to pwsh
rem instead of before it (~40ms sooner prompt), and it's done long before pwsh prints
rem anything, so the output doesn't mix.
rem
rem The pwsh line is what Kitsu itself runs when the shell is pwsh.exe (its PowerShell
rem integration: prompt marks, cwd reporting). Going through cmd skips that, so it's done here.

set KITTY_SHELL_INTEGRATION=no-cursor
set KITSU_GREETED=1
start "" /b fastfetch
"%LOCALAPPDATA%\Programs\PowerShell\7\pwsh.exe" -NoLogo -NoExit -Command ". '%LOCALAPPDATA%\Programs\Kitsu\lib\kitty\shell-integration\powershell\kitty-integration.ps1'"
