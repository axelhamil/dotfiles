Name = "hyprland"
NamePretty = "Hyprland"
Icon = "preferences-desktop"
HideFromProviderlist = false
Cache = false

function GetEntries()
    local entries = {
        {
            Text = "Reload config",
            SubText = "hyprctl reload",
            Value = "reload",
            Actions = { default = "hyprctl reload" },
        },
        {
            Text = "Toggle gaps",
            SubText = "Bascule les gaps on/off",
            Value = "gaps",
            Actions = { default = "hyprctl --batch 'keyword general:gaps_in 0 ; keyword general:gaps_out 0' || hyprctl reload" },
        },
        {
            Text = "Toggle animations",
            SubText = "Bascule les animations",
            Value = "anim",
            Actions = { default = "hyprctl keyword animations:enabled $(hyprctl getoption animations:enabled -j | jq -r 'if .int == 1 then 0 else 1 end')" },
        },
        {
            Text = "Mode gaming on",
            SubText = "VRR + immediate + no animations",
            Value = "gaming-on",
            Actions = { default = "hyprctl --batch 'keyword animations:enabled 0 ; keyword misc:vrr 2'" },
        },
        {
            Text = "Mode gaming off",
            SubText = "Retour animations + VRR off",
            Value = "gaming-off",
            Actions = { default = "hyprctl --batch 'keyword animations:enabled 1 ; keyword misc:vrr 0'" },
        },
        {
            Text = "Kill hung windows",
            SubText = "Tue les fenêtres qui ne répondent plus",
            Value = "killhung",
            Actions = { default = "hyprctl kill" },
        },
    }

    local handle = io.popen("hyprctl monitors -j 2>/dev/null")
    if handle then
        local json = handle:read("*a")
        handle:close()
        for name, res, rate in json:gmatch('"name":%s*"([^"]+)".-"width":%s*(%d+).-"refreshRate":%s*([%d%.]+)') do
            local rate_int = math.floor(tonumber(rate) + 0.5)
            table.insert(entries, {
                Text = "Monitor " .. name,
                SubText = res .. "px @ " .. rate_int .. "Hz",
                Value = name,
                Actions = { default = "hyprctl dispatch focusmonitor " .. name },
            })
        end
    end

    return entries
end
