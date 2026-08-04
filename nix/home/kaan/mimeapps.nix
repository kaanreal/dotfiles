# Default apps: what opens files / links.
# home-manager owns ~/.config/mimeapps.list; force overwrites the files
# GNOME/chrome already created.
{ ... }:

{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Code / text -> VS Code
      "text/plain" = [ "code.desktop" ];
      "application/json" = [ "code.desktop" ];
      "text/markdown" = [ "code.desktop" ];
      "text/x-python" = [ "code.desktop" ];
      "text/x-shellscript" = [ "code.desktop" ];
      "text/javascript" = [ "code.desktop" ];
      "text/xml" = [ "code.desktop" ];
      "text/x-csrc" = [ "code.desktop" ];
      "text/x-c++src" = [ "code.desktop" ];
      # Folders -> Nautilus
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      # Web -> Chrome
      "text/html" = [ "google-chrome.desktop" ];
      "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      "x-scheme-handler/https" = [ "google-chrome.desktop" ];
      "x-scheme-handler/about" = [ "google-chrome.desktop" ];
      "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
    };
  };
  xdg.configFile."mimeapps.list".force = true;
  xdg.dataFile."applications/mimeapps.list".force = true;
}
