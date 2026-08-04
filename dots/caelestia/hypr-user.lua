-- Caelestia user Hyprland config
-- Editable: changes here apply on shell restart (Ctrl+Super+Alt+R).
hl.monitor({
    output   = "DP-1",
    mode     = "2560x1440@180",
    position = "auto",
    scale    = 1,
})

-- Mouse: no acceleration (Hyprland >= 0.55: accel_speed was removed,
-- force_no_accel is the replacement)
hl.config({
    input = {
        force_no_accel = true,
    },
})

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("jamesdsp --tray --watch")
end)

-- SUPER+W: toggle the "web" special workspace and place Chrome in it.
-- (SUPER+D communication / SUPER+M music are bound by the dots' defaults.)
local fn = require("utils.functions")
hl.bind("SUPER + W", fn.toggle("web"))
