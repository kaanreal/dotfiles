local scheme = require("scheme.current")

hl.config({
    misc = {
        animate_manual_resizes       = false,
        animate_mouse_windowdragging = false,

        disable_hyprland_logo        = true,
        force_default_wallpaper      = 0,

        on_focus_under_fullscreen    = 2,
        allow_session_lock_restore   = true,
        middle_click_paste           = false,
        focus_on_activate            = true,
        session_lock_xray            = true,

        mouse_move_enables_dpms      = true,
        key_press_enables_dpms       = true,

        background_color             = "rgb(" .. scheme.surfaceContainer .. ")",
    },

    debug = {
        error_position = 1,
        -- Avoid continuous cursor/libinput log writes on the render thread.
        disable_logs   = true,
        disable_time   = true,
    },

    opengl = {
        -- Hyprland's Nvidia anti-flicker workaround can intentionally hold or
        -- drop frames. This desktop does not show the idle-flicker symptom and
        -- prioritises consistent pacing at 2560x1440@180 instead.
        nvidia_anti_flicker = false,
    },
})
