Name = "screenshots"
NamePretty = "Screenshot"
Icon = "camera-photo"
HideFromProviderlist = false
Cache = true

function GetEntries()
    local dir = os.getenv("HOME") .. "/Pictures/Screenshots"
    local mkdir = "mkdir -p '" .. dir .. "'"
    local stamp = '"' .. dir .. '/$(date +%Y-%m-%d_%H-%M-%S).png"'

    return {
        {
            Text = "Region",
            SubText = "Sélection à la souris → clipboard + fichier",
            Value = "region",
            Actions = {
                default = mkdir .. " && grim -g \"$(slurp)\" - | tee " .. stamp .. " | wl-copy --type image/png",
                edit = mkdir .. " && grim -g \"$(slurp)\" - | swappy -f -",
            },
        },
        {
            Text = "Window",
            SubText = "Fenêtre active (Hyprland)",
            Value = "window",
            Actions = {
                default = mkdir .. " && grim -g \"$(hyprctl activewindow -j | jq -r '\"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])\"')\" - | tee " .. stamp .. " | wl-copy --type image/png",
            },
        },
        {
            Text = "Fullscreen",
            SubText = "Capture tout l'écran actif",
            Value = "full",
            Actions = {
                default = mkdir .. " && grim -o \"$(hyprctl activeworkspace -j | jq -r '.monitor')\" - | tee " .. stamp .. " | wl-copy --type image/png",
            },
        },
        {
            Text = "All monitors",
            SubText = "Capture tous les écrans",
            Value = "all",
            Actions = {
                default = mkdir .. " && grim - | tee " .. stamp .. " | wl-copy --type image/png",
            },
        },
        {
            Text = "Open Screenshots folder",
            SubText = dir,
            Value = "open",
            Actions = { default = "xdg-open '" .. dir .. "'" },
        },
    }
end
