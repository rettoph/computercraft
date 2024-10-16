local ItemMetaCache = require("/Factory/ItemMetaCache")
local Inventory = require("/Factory/Inventory")

---@class InventoryManager
---@field private _inventories { [string]: Inventory }
---@field private _logger Logger
local InventoryManager = {
    _update = 0
}

---comment
---@param logger Logger
function InventoryManager.Initialize(logger)
	ItemMetaCache.Initialize(logger)
	
	InventoryManager._logger = logger
    InventoryManager._inventories = {}

	InventoryManager._logger:Verbose("Initializing InventoryManager...")
end

---comment
---@param name string
---@return Inventory
function InventoryManager.GetByName(name)
    local result = InventoryManager._inventories[name]

    if result == nil then
        result = Inventory:New(name, InventoryManager._logger)
        
        local connected, _ = Inventory.TryGetModule(name)
        if connected == true then
            InventoryManager._inventories[name] = result
        end
    end

    return result
end

function InventoryManager.Update()
	for name,_ in pairs(InventoryManager._inventories) do
        local result, _ = Inventory.TryGetModule(name)
		if result == true then
            InventoryManager._inventories[name]:SetDirty(true)
        else
			InventoryManager._inventories[name] = nil
            InventoryManager._logger:Warning("Inventory disconnected: '" .. name .. "'")
		end
	end
end

return InventoryManager