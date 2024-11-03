

---@class Console
---@field private _enabled boolean
local Console = {
    _enabled = true
}

---@enum Console.Color
Console.Color = {
    Red = colors.red,
    Orange = colors.orange,
    Green = colors.green,
    White = colors.white,
    Cyan = colors.cyan,
    Purple = colors.purple
}

---Write to console
---@param message string
function Console.WriteLine(message)
    if Console._enabled == false then
        return
    end

    print(message)
end

---Set console foreground color
---@param color Console.Color
function Console.SetForegroundColor(color)
    term.setTextColor(color)
end

---comment
---@param value boolean
function Console.SetEnabled(value)
    Console._enabled = value
end

return Console