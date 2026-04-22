Name = "processes"
NamePretty = "Kill Process"
Icon = "process-stop"
HideFromProviderlist = false
Cache = false

function GetEntries()
    local entries = {}
    local handle = io.popen("ps -eo pid,rss,comm,args --sort=-rss --no-headers | head -80")
    if not handle then return entries end

    for line in handle:lines() do
        local pid, rss, comm, args = line:match("^%s*(%d+)%s+(%d+)%s+(%S+)%s+(.*)$")
        if pid and comm then
            local mem_mb = math.floor(tonumber(rss) / 1024)
            local cmdline = args and args:sub(1, 80) or comm
            table.insert(entries, {
                Text = comm .. "  [" .. pid .. "]",
                SubText = mem_mb .. " MB  •  " .. cmdline,
                Value = pid,
                Icon = "process-stop",
                Actions = {
                    default = "kill " .. pid,
                    force = "kill -9 " .. pid,
                },
            })
        end
    end
    handle:close()
    return entries
end
