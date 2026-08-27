-- Caelestia user Hyprland config
-- Editable: changes here apply on shell restart (Ctrl+Super+Alt+R).
hl.monitor({
    output   = "DP-1",
    -- Keep this identical to the kernel console/Ly mode to avoid a black
    -- display-mode transition when the graphical session starts.
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

    -- Use adaptive sync only for fullscreen content. The monitor's EDID
    -- advertises a 48-180 Hz VRR range.
    misc = {
        vrr = 2,
    },

    -- Keep presentation synchronized. Tearing trades motion cleanliness for
    -- latency, which is the opposite of what we want for scrolling mania notes.
    general = {
        allow_tearing = false,
    },
})

-- osu! marks itself fullscreen internally, but Wine/XWayland does not pass
-- that state through here. Make it a real compositor fullscreen game so it
-- gets the monitor's complete 2560x1440 surface and fullscreen-only VRR.
hl.window_rule({
    name = "osu-mania-smooth-presentation",
    match = { class = "^osu!\\.exe$" },
    fullscreen = true,
    content = "game",
    immediate = false,
    no_anim = true,
    opaque = true,
    idle_inhibit = "always",
})

-- Autostart
hl.on("hyprland.start", function()
    hl.exec_cmd("jamesdsp --tray --watch")
end)

-- SUPER+W: toggle the "web" special workspace and place Chrome in it.
-- (SUPER+D communication / SUPER+M music are bound by the dots' defaults.)
local fn = require("utils.functions")
-- The dots default (kbBrowser) also assigns SUPER+W to launching the
-- browser (firefox). Hyprland stacks same-key binds, so drop that one first
-- and let the "web" workspace/Chrome toggle be the only SUPER+W action.
hl.unbind("SUPER + W")
hl.bind("SUPER + W", fn.toggle("web"))
