
hl.monitor({
    output = "DP-2",
    mode = "3840x2160@60",
    position = "0x0",
    scale = "1.5",
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "2560x1080@60",
    position = "1660x-1080",
    scale = "1",
})

hl.monitor({
    output = "DP-1",
    disabled = true,
})

hl.workspace_rule({
    workspace = "1",
    default_name = "browser",
    monitor = "DP-2",
    default = true,
})

hl.workspace_rule({
    workspace = "2",
    default_name = "code",
    monitor = "DP-2",
})

hl.workspace_rule({
    workspace = "3",
    default_name = "terminal",
    monitor = "DP-2",
})

hl.workspace_rule({
    workspace = "4",
    default_name = "DB",
    monitor = "DP-2",
})

hl.workspace_rule({
    workspace = "5",
    default_name = "chat",
    monitor = "HDMI-A-1",
})

hl.workspace_rule({
    workspace = "6",
    default_name = "music",
    monitor = "HDMI-A-1",
})

hl.workspace_rule({
    workspace = "7",
    default_name = "other",
    monitor = "HDMI-A-1",
})

hl.workspace_rule({
    workspace = "8",
    default_name = "whatever",
    monitor = "HDMI-A-1",
})

local terminal = "kitty"
local fileManager = "nautilus"
local menu = "walker"

hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "catppuccin-mocha-mauve-cursors")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "catppuccin-mocha-mauve-cursors")

hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("GSK_RENDERER", "ngl")

hl.layer_rule({
    name = "blur-waybar",
    match = {
        namespace = "^(waybar)$",
    },
    blur = true,
})

hl.layer_rule({
    name = "blur-walker",
    match = {
        namespace = "^(walker)$",
    },
    blur = true,
})

hl.layer_rule({
    name = "blur-notifications",
    match = {
        namespace = "^(notifications)$",
    },
    blur = true,
})

hl.layer_rule({
    name = "blur-wofi",
    match = {
        namespace = "^(wofi)$",
    },
    blur = true,
})

hl.curve("appleSpring", { type = "bezier", points = { { 0.22, 1.0 }, { 0.36, 1.0 } } })
hl.curve("appleSlow", { type = "bezier", points = { { 0.25, 1.0 }, { 0.32, 1.0 } } })
hl.curve("appleFast", { type = "bezier", points = { { 0.2, 0.9 }, { 0.1, 1.0 } } })
hl.curve("appleSettle", { type = "bezier", points = { { 0.12, 0.96 }, { 0.26, 1.0 } } })
hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 7,
    bezier = "appleSpring",
    style = "popin 92%",
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 5,
    bezier = "appleSlow",
    style = "popin 92%",
})
hl.animation({
    leaf = "windowsMove",
    enabled = true,
    speed = 6,
    bezier = "appleSettle",
})
hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 6,
    bezier = "appleSlow",
})
hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 5,
    bezier = "appleSlow",
})
hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 5,
    bezier = "appleSlow",
})
hl.animation({
    leaf = "fadeShadow",
    enabled = true,
    speed = 6,
    bezier = "appleSlow",
})
hl.animation({
    leaf = "fadeDim",
    enabled = true,
    speed = 6,
    bezier = "appleSlow",
})
hl.animation({
    leaf = "layers",
    enabled = true,
    speed = 5,
    bezier = "appleSlow",
    style = "fade",
})
hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 4,
    bezier = "appleSpring",
    style = "fade",
})
hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 4,
    bezier = "appleSlow",
    style = "fade",
})
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 6,
    bezier = "appleSettle",
    style = "slidefadevert 15%",
})
hl.animation({
    leaf = "workspacesIn",
    enabled = true,
    speed = 6,
    bezier = "appleSettle",
    style = "slidefadevert 15%",
})
hl.animation({
    leaf = "workspacesOut",
    enabled = true,
    speed = 5,
    bezier = "appleSlow",
    style = "slidefadevert 15%",
})
hl.animation({
    leaf = "specialWorkspace",
    enabled = true,
    speed = 7,
    bezier = "appleSettle",
    style = "slidefadevert -40%",
})
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 8,
    bezier = "appleSlow",
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

local mainMod = "SUPER"

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + CTRL + SHIFT + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + T", hl.dsp.layout("togglesplit"))

hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("hyprlock"))

hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("walker -m clipboard"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("cliphist wipe"))

hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd("hyprctl dispatch focuswindow class:org.keepassxc.KeePassXC || keepassxc"))

hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -a"))

hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpaper.sh"))

hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("grimblast --notify copy area"))
hl.bind(mainMod .. " + SHIFT + ALT + S", hl.dsp.exec_cmd("grimblast --notify save area - | swappy -f -"))
hl.bind(mainMod .. " + SHIFT + CTRL + S", hl.dsp.exec_cmd("grimblast --notify copy screen"))
hl.bind(mainMod .. " + SHIFT + ALT + A", hl.dsp.exec_cmd("grimblast --notify copy active"))

hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("voxtype record start"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("voxtype record stop"), { release = true })

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction ="l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction ="r" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction ="u" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction ="d" }))

hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction ="l" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction ="r" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction ="u" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction ="d" }))

hl.bind(mainMod .. " + code:10", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + code:11", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + code:12", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + code:13", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + code:14", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + code:15", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + code:16", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + code:17", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + code:18", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + code:19", hl.dsp.focus({ workspace = 10 }))

hl.bind(mainMod .. " + SHIFT + code:10", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + code:11", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + code:12", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + code:13", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + code:14", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + code:15", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + code:16", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + code:17", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + code:18", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + SHIFT + code:19", hl.dsp.window.move({ workspace = 10 }))

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("term"))
hl.bind(mainMod .. " + F2", hl.dsp.workspace.toggle_special("files"))
hl.bind(mainMod .. " + F3", hl.dsp.workspace.toggle_special("music"))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.window_rule({
    match = {
        class = "^.*$",
    },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "xwayland-drag-fix",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    match = {
        class = "^(blueman-manager)$",
    },
    float = true,
    move = "72% 3.5%",
    size = "700 550",
})

hl.window_rule({
    match = {
        class = "^(org.pulseaudio.pavucontrol)$",
    },
    float = true,
    move = "72% 3.5%",
    size = "700 550",
})

hl.window_rule({
    match = {
        class = "^(nm-connection-editor)$",
    },
    float = true,
    move = "72% 3.5%",
    size = "700 550",
})

hl.window_rule({
    match = {
        class = "^(popup-nmtui)$",
    },
    float = true,
    move = "72% 3.5%",
    size = "700 550",
})

-- Jeux : tearing autorisé (latence) + curseur confiné, sans blur ni arrondi.
-- `immediate` n'a d'effet que parce que general.allow_tearing = true.
hl.window_rule({
    name = "gaming",
    match = {
        class = "^(steam_app_.*|gamescope|cs2|factorio|.*\\.exe)$",
    },
    immediate = true,
    no_blur = true,
    rounding = 0,
})

-- popups moniteur système ouverts depuis le cluster hardware de waybar
hl.window_rule({
    match = {
        class = "^(popup-btop|popup-gpu|popup-docker|popup-updates)$",
    },
    float = true,
    move = "50% 3.5%",
    size = "1100 700",
})

hl.window_rule({
    match = {
        class = "^(helvum)$",
    },
    float = true,
    move = "72% 3.5%",
    size = "900 600",
})

hl.window_rule({
    match = {
        class = "^(org.keepassxc.KeePassXC)$",
    },
    float = true,
    center = true,
    size = "800 600",
})

hl.window_rule({
    match = {
        class = "^(org.gnome.Nautilus)$",
    },
    float = true,
    center = true,
    size = "900 600",
})

hl.window_rule({
    match = {
        class = "^(steam)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "^(steam)$",
        title = "^(Steam)$",
    },
    center = true,
    size = "1200 800",
})

hl.window_rule({
    match = {
        class = "^(scratch-term)$",
    },
    float = true,
    size = "80% 60%",
    move = "10% 5%",
})

hl.window_rule({
    match = {
        class = "^(scratch-files)$",
    },
    float = true,
    size = "70% 70%",
    center = true,
})

hl.window_rule({
    match = {
        class = "^(Cider)$",
    },
    float = true,
    size = "70% 70%",
    center = true,
})

hl.bind("SUPER + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("swaync-client -d -sw"))
hl.bind("SUPER + CTRL + N", hl.dsp.exec_cmd("swaync-client -C"))

hl.layer_rule({
    name = "blur-swaync-cc",
    match = {
        namespace = "^(swaync-control-center)$",
    },
    blur = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    name = "blur-swaync-notif",
    match = {
        namespace = "^(swaync-notification-window)$",
    },
    blur = true,
    ignore_alpha = 0.5,
})

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
    general = {
        gaps_in = 2,
        gaps_out = { top = 2, right = 8, bottom = 8, left = 8 },
        border_size = 2,
        col = {
            active_border = { colors = { "rgb(cba6f7)", "rgb(89b4fa)" }, angle = 45 },
            inactive_border = "rgba(313244cc)",
        },
        resize_on_border = true,
        layout = "dwindle",
        -- autorise le tearing ; effectif uniquement sur les fenêtres
        -- portant la règle `immediate` (voir window_rule "gaming")
        allow_tearing = true,
    },
    decoration = {
        rounding = 14,
        rounding_power = 3.0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        dim_inactive = true,
        dim_strength = 0.12,
        shadow = {
            enabled = true,
            range = 30,
            render_power = 2,
            color = "rgba(00000055)",
            offset = "0 6",
        },
        -- glow (0.55+) : halo coloré sur la fenêtre active, reprend le
        -- dégradé mauve→bleu de general.col.active_border
        glow = {
            enabled = true,
            range = 12,
            render_power = 3,
            color = { colors = { "rgba(cba6f766)", "rgba(89b4fa66)" }, angle = 45 },
        },
        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            xray = false,
            vibrancy = 0.15,
            vibrancy_darkness = 0.2,
            noise = 0.008,
            contrast = 0.95,
            brightness = 1.05,
        },
    },
    animations = {
        enabled = true,
    },
    binds = {
        -- re-presser SUPER+<n> sur le workspace courant y revient depuis le précédent
        workspace_back_and_forth = true,
    },
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        vrr = 1,
    },
    input = {
        kb_layout = "fr",
        kb_variant = "",
        kb_model = "",
        kb_options = "caps:escape",
        kb_rules = "",
        repeat_rate = 60,
        repeat_delay = 250,
        accel_profile = "flat",
        follow_mouse = 1,
        sensitivity = 0.15,
        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.on("hyprland.start", function()
    hl.exec_cmd("xrandr --output DP-2 --primary")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    -- nm-applet retiré : doublonnait le module network de waybar dans le tray
    hl.exec_cmd("waybar")
    hl.exec_cmd("env QT_QPA_PLATFORMTHEME=qt5ct keepassxc --keyfile ~/.local/share/keepassxc/keyfile.keyx ~/Documents/secrets/passwords.kdbx --minimized")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("until awww query &>/dev/null; do sleep 0.1; done; awww img ~/Images/wallpapers/l-art-numerique-avec-le-paysage-urbain-et-l-architecture.jpg --transition-type none")
    hl.exec_cmd("walker --gapplication-service")
    hl.exec_cmd("kitty --class scratch-term", { workspace = "special:term silent" })
    hl.exec_cmd("nautilus", { workspace = "special:files silent" })
    hl.exec_cmd("cider", { workspace = "special:music silent" })
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- DOIT rester en dernier : ramène le focus sur DP-2 une fois que
    -- keepassxc / cider / les scratchpads ont fini de s'ouvrir.
    hl.exec_cmd("~/.config/hypr/scripts/focus-primary.sh DP-2")
end)


-- Rebranchement d'écran : Hyprland redistribue les workspaces et le focus
-- atterrit souvent sur le mauvais moniteur. On le ramène sur DP-2.
-- Nom d'événement vérifié par sondage : "monitor.added" (les variantes
-- camelCase renvoient nil, donc aucun abonnement).
hl.on("monitor.added", function()
    hl.exec_cmd("~/.config/hypr/scripts/focus-primary.sh DP-2")
end)
