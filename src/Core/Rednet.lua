---@class Rednet
---@field private _channel integer
local Rednet = {}
Rednet.channels = {}

---comment
---@private
---@return any
function Rednet.GetWirelessModem()
    local modems = table.pack(peripheral.find("modem"))
    for _,modem in pairs(modems) do
        if modem.isWireless() == true then
            return modem
        end
    end

    return nil
end

return Rednet