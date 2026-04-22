Name = "quicklinks"
NamePretty = "Quick Links"
Icon = "bookmarks"
HideFromProviderlist = false
Cache = true

local function link(text, sub, url, icon)
    return {
        Text = text,
        SubText = sub,
        Value = url,
        Icon = icon or "applications-internet",
        Actions = {
            default = "xdg-open '" .. url .. "'",
            copy = "echo -n '" .. url .. "' | wl-copy",
        },
    }
end

function GetEntries()
    return {
        link("openup-app", "Capacitor + Vite + TanStack + Hono", "https://github.com/axel-hamilcaro/raphael-openup-app"),
        link("scormpilot", "Clone Scormi — DO + Postgres", "https://github.com/axel-hamilcaro/moa-scormpilot-app"),
        link("pignon", "Sites vitrines — Astro + Payload + Hono", "https://pignon.studio"),
        link("axel.com", "Coffre-fort + signature", "https://axel.com"),
        link("murmur", "Clone Twitchat — Rust/WASM + Nuxt", "https://github.com/axel-hamilcaro/murmur"),

        link("galvorn (npm)", "Option/Result pour TS", "https://www.npmjs.com/package/galvorn"),
        link("inwire (npm)", "DI type-safe zero decorators", "https://www.npmjs.com/package/inwire"),

        link("GitHub — mes repos", "github.com/axel-hamilcaro", "https://github.com/axel-hamilcaro?tab=repositories"),
        link("GitHub — notifications", "Inbox GitHub", "https://github.com/notifications"),
        link("Linear", "Tickets", "https://linear.app"),
        link("Railway", "Prod infra", "https://railway.app/dashboard"),
        link("Vercel", "Deploys", "https://vercel.com/dashboard"),
        link("Claude", "claude.ai", "https://claude.ai"),

        link("Arch Wiki", "wiki.archlinux.org", "https://wiki.archlinux.org"),
        link("Hyprland wiki", "wiki.hypr.land", "https://wiki.hypr.land"),
        link("AUR", "aur.archlinux.org", "https://aur.archlinux.org"),

        link("Dotfiles", "Local: ~/.dotfiles", "file:///home/axel/.dotfiles", "folder"),
        link("DEV folder", "Local: ~/DEV", "file:///home/axel/DEV", "folder"),
    }
end
