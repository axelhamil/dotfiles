Name = "system"
NamePretty = "System"
Icon = "system-shutdown"
HideFromProviderlist = false
Cache = true

function GetEntries()
    return {
        {
            Text = "Lock",
            SubText = "Verrouiller la session",
            Value = "lock",
            Icon = "system-lock-screen",
            Actions = { default = "hyprlock" },
        },
        {
            Text = "Suspend",
            SubText = "Mettre en veille",
            Value = "suspend",
            Icon = "system-suspend",
            Actions = { default = "systemctl suspend" },
        },
        {
            Text = "Reboot",
            SubText = "Redémarrer le système",
            Value = "reboot",
            Icon = "system-reboot",
            Actions = { default = "systemctl reboot" },
        },
        {
            Text = "Shutdown",
            SubText = "Éteindre le système",
            Value = "shutdown",
            Icon = "system-shutdown",
            Actions = { default = "systemctl poweroff" },
        },
        {
            Text = "Logout Hyprland",
            SubText = "Fermer la session Hyprland",
            Value = "logout",
            Icon = "system-log-out",
            Actions = { default = "hyprctl dispatch exit" },
        },
        {
            Text = "Reload Hyprland",
            SubText = "Recharger la config Hyprland",
            Value = "reload",
            Icon = "view-refresh",
            Actions = { default = "hyprctl reload" },
        },
        {
            Text = "Reload Waybar",
            SubText = "Redémarrer la barre",
            Value = "waybar",
            Icon = "view-refresh",
            Actions = { default = "pkill -SIGUSR2 waybar" },
        },
        {
            Text = "Restart Elephant",
            SubText = "Recharger les menus et providers Walker",
            Value = "elephant",
            Icon = "view-refresh",
            Actions = { default = "systemctl --user restart elephant" },
        },
    }
end
