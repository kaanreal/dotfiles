// Win+T opens kitty (Kitsu), or a new tab when kitty is the focused window (what cmd+t
// does on the Mac; Kitsu never sees Win+T itself). `kitty-hotkey.exe --open` opens one
// window and exits, that's what the Start menu kitty.lnk runs.
//
// Windows only lets a shortcut have Ctrl+Alt hotkeys, so Win+T needs something running.
// This is as small as that gets: one RegisterHotKey, then it sleeps in GetMessage
// (no CPU, ~1MB RAM) until the key is pressed. No hook, so it never sees other keys.
//
// Explorer owns Win+T (focus taskbar) until DisabledHotkeys contains "T", which
// scripts/link-windows-dots.ps1 sets; Explorer reads it when it starts (sign out once).
//
// Kitsu has no --single-instance on Windows (fhaze/kitsu#87, not planned), so this fakes
// it. The first launch starts Kitsu listening on 127.0.0.1 with a fresh random password
// that may only `launch`, later launches ask that Kitsu for a window through kitten (~65ms
// instead of ~350ms). Closing the last window quits Kitsu as usual, so nothing stays
// around in the background. The password is in %LOCALAPPDATA%\Kitsu\instance. kitten also
// needs Kitsu's public key, which only Kitsu's own shells get, so the pwsh profile writes
// it there. This used to be a vbs run by wscript, which cost ~110ms more per launch.
//
// Build on the Mac, or on Windows after `winget install zig.zig` (prebuilt exe is next to this file):
//   zig cc -target x86_64-windows-gnu -Os -s -Wl,--subsystem,windows kitty-hotkey.c -o kitty-hotkey.exe -luser32 -lbcrypt
#include <windows.h>
#include <bcrypt.h>

#define PORT L"47811"  // the pwsh profile checks for it too

static int kitty_focused(void) {
    DWORD pid = 0;
    GetWindowThreadProcessId(GetForegroundWindow(), &pid);
    HANDLE p = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
    if (!p) return 0;
    wchar_t path[MAX_PATH];
    DWORD n = MAX_PATH;
    int ok = QueryFullProcessImageNameW(p, 0, path, &n) && n >= 10 && !lstrcmpiW(path + n - 10, L"\\kitsu.exe");
    CloseHandle(p);
    return ok;
}

// %LOCALAPPDATA%\Kitsu\instance\<name>, where the password and Kitsu's public key live
static void instance_path(const wchar_t *name, wchar_t *path) {
    ExpandEnvironmentStringsW(L"%LOCALAPPDATA%\\Kitsu\\instance\\", path, MAX_PATH);
    lstrcatW(path, name);
}

// 0 if the file isn't there
static int read_instance_file(const wchar_t *name, char *buf, DWORD size) {
    wchar_t path[MAX_PATH];
    instance_path(name, path);
    HANDLE f = CreateFileW(path, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, NULL, OPEN_EXISTING, 0, NULL);
    if (f == INVALID_HANDLE_VALUE) return 0;
    DWORD n = 0;
    ReadFile(f, buf, size - 1, &n, NULL);
    CloseHandle(f);
    while (n && (buf[n - 1] == '\r' || buf[n - 1] == '\n' || buf[n - 1] == ' ')) n--;
    buf[n] = 0;
    return n > 0;
}

// `kitten @ <cmd>` against the running Kitsu, 1 when it worked
static int ask_kitsu(const wchar_t *cmd) {
    char key[256], password[64];
    if (!read_instance_file(L"key", key, sizeof key) || !read_instance_file(L"password", password, sizeof password)) return 0;
    SetEnvironmentVariableA("KITTY_PUBLIC_KEY", key);

    wchar_t kitten[MAX_PATH], args[MAX_PATH * 2], line[1024];
    ExpandEnvironmentStringsW(L"%LOCALAPPDATA%\\Programs\\Kitsu\\bin\\kitten.exe", kitten, MAX_PATH);
    ExpandEnvironmentStringsW(cmd, args, MAX_PATH * 2);
    wsprintfW(line, L"\"%s\" @ --to tcp:127.0.0.1:" PORT L" --password %S %s", kitten, password, args);

    STARTUPINFOW si = {.cb = sizeof si};
    PROCESS_INFORMATION pi;
    if (!CreateProcessW(NULL, line, NULL, NULL, FALSE, CREATE_NO_WINDOW, NULL, NULL, &si, &pi)) return 0;
    CloseHandle(pi.hThread);
    DWORD rc = 1;
    if (WaitForSingleObject(pi.hProcess, 3000) == WAIT_OBJECT_0) GetExitCodeProcess(pi.hProcess, &rc);
    CloseHandle(pi.hProcess);
    return rc == 0;
}

// no Kitsu answered: start one listening for the next launches. The pwsh profile writes
// the key once its first shell runs.
static void start_kitsu(void) {
    // a second press (or a double click on the shortcut, that's another process) while that
    // Kitsu is still starting would start another one: a password from the last 3s means
    // one is on its way
    wchar_t path[MAX_PATH];
    WIN32_FILE_ATTRIBUTE_DATA attr;
    instance_path(L"password", path);
    if (GetFileAttributesExW(path, GetFileExInfoStandard, &attr)) {
        FILETIME now;
        GetSystemTimeAsFileTime(&now);
        ULARGE_INTEGER a = {.LowPart = attr.ftLastWriteTime.dwLowDateTime, .HighPart = attr.ftLastWriteTime.dwHighDateTime};
        ULARGE_INTEGER b = {.LowPart = now.dwLowDateTime, .HighPart = now.dwHighDateTime};
        if (b.QuadPart - a.QuadPart < 3 * 10000000ULL) return;
    }

    ExpandEnvironmentStringsW(L"%LOCALAPPDATA%\\Kitsu", path, MAX_PATH);
    CreateDirectoryW(path, NULL);
    lstrcatW(path, L"\\instance");
    CreateDirectoryW(path, NULL);
    instance_path(L"key", path);
    DeleteFileW(path);

    unsigned char rnd[16];
    char password[33];
    BCryptGenRandom(NULL, rnd, sizeof rnd, BCRYPT_USE_SYSTEM_PREFERRED_RNG);
    for (int i = 0; i < 16; i++) {
        password[i * 2] = "0123456789abcdef"[rnd[i] >> 4];
        password[i * 2 + 1] = "0123456789abcdef"[rnd[i] & 15];
    }
    password[32] = 0;
    instance_path(L"password", path);
    HANDLE f = CreateFileW(path, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, 0, NULL);
    if (f == INVALID_HANDLE_VALUE) return;
    DWORD n;
    WriteFile(f, password, 32, &n, NULL);
    CloseHandle(f);

    wchar_t kitsu[MAX_PATH], home[MAX_PATH], line[1024];
    ExpandEnvironmentStringsW(L"%LOCALAPPDATA%\\Programs\\Kitsu\\bin\\kitsu.exe", kitsu, MAX_PATH);
    ExpandEnvironmentStringsW(L"%USERPROFILE%", home, MAX_PATH);
    wsprintfW(line, L"\"%s\" --listen-on=tcp:127.0.0.1:" PORT L" -o allow_remote_control=password -o \"remote_control_password=%S launch\"", kitsu, password);

    // CreateProcess, not ShellExecute: that pulls in the shell's COM libraries (~3MB more)
    STARTUPINFOW si = {.cb = sizeof si};
    PROCESS_INFORMATION pi;
    if (CreateProcessW(NULL, line, NULL, NULL, FALSE, 0, NULL, home, &si, &pi)) {
        CloseHandle(pi.hThread);
        CloseHandle(pi.hProcess);
    }
}

static void open_window(void) {
    if (!ask_kitsu(L"launch --type=os-window --cwd \"%USERPROFILE%\"")) start_kitsu();
}

int WINAPI WinMain(HINSTANCE inst, HINSTANCE prev, LPSTR cmd, int show) {
    (void)inst; (void)prev; (void)show;

    // the Start menu entry: being started from there gives this process the right to bring
    // windows to the front, pass it on like a hotkey press below
    if (!lstrcmpiA(cmd, "--open")) {
        AllowSetForegroundWindow(ASFW_ANY);
        open_window();
        return 0;
    }

    // only one copy, the Startup shortcut and a manual start shouldn't both run
    CreateMutexW(NULL, FALSE, L"Local\\kitty-hotkey");
    if (GetLastError() == ERROR_ALREADY_EXISTS) return 0;

    // Explorer may still be starting at logon, give it a moment instead of failing
    int ok = 0;
    for (int i = 0; i < 30 && !(ok = RegisterHotKey(NULL, 1, MOD_WIN | MOD_NOREPEAT, 'T')); i++) Sleep(2000);
    if (!ok) return 1;

    MSG msg;
    while (GetMessageW(&msg, NULL, 0, 0) > 0) {
        if (msg.message == WM_HOTKEY) {
            // a hotkey press gives this process the right to bring windows to the front;
            // pass it on so the kitty window gets focus
            AllowSetForegroundWindow(ASFW_ANY);
            if (!kitty_focused() || !ask_kitsu(L"launch --type=tab --cwd=current")) open_window();
        }
    }
    return 0;
}
