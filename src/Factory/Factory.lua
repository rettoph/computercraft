local InventoryManager = require "/Factory/InventoryManager"

---@class Factory
---@field private _logger Logger
---@field private _queue { [string]: integer }
---@field private _storage Inventory
local Factory = {
	_queue = {},
}

---Initialize factory
---@param logger Logger
---@param storage Inventory
function Factory.Initialize(logger, storage)
	Factory._storage = storage
	Factory._logger = logger
end

---Update factory
function Factory.Update()
	InventoryManager.Update()
end

---Get an inventory by name
---@param name string
---@return Inventory
function Factory.GetInventoryByName(name)
	return InventoryManager.GetByName(name)
end

---Transfer items from factory storage to a target destination
---@param id string
---@param amount integer
---@param destination Inventory
---@param destinationSlot integer|nil
---@return integer
function Factory.TransferItemsById(id, amount, destination, destinationSlot)
	local result = Factory._storage:TransferItemsById(id, amount, destination, destinationSlot)
	return result
end

---comment
---@param id string
---@return integer
function Factory.GetItemTotalById(id)
	local total = Factory._queue[id] or 0
	total = total + Factory._storage:GetItemById(id):GetTotal()

    return total
end

---Queue a number of items to the factory. Will not allow values below 0
---@param id string
---@param count integer
function Factory.Queue(id, count)
	Factory._queue[id] = math.max(0, (Factory._queue[id] or 0) + count)
	Factory._logger:Debug("Queued " .. count .. " '" .. id .. "', " .. Factory._queue[id] .. " total")
end

function Factory.StoreAll(inventoryName)
	local inventory = Factory.GetInventoryByName(inventoryName)
	if not inventory then 
		Factory._logger:Warning("StoreAll:Unknown inventory '" .. inventoryName .. "'")
		return 0 
	end

	local success = true
	for _,slot in pairs(inventory:GetSlots()) do
		local result = inventory:TransferItemsBySlot(slot:GetIndex(), slot:GetCount(), Factory._storage)

		Factory.Queue(slot:GetItem():GetId(), -result)

		if slot:GetCount() ~= 0 then
			success = false
		end
	end

	return success
end

function Factory.StoreSlot(inventoryName, slotIndex)
	local inventory = Factory.GetInventoryByName(inventoryName)
	if inventory  == nil then 
		Factory._logger:Warning("StoreSlot:Unknown inventory '" .. inventoryName .. "'")
		return 0 
	end

	local slot = inventory:GetSlotByIndex(slotIndex)
    local item = slot:GetItem()
	if item == nil then
		return false
	end

	if slot:GetCount() == 0 then
		return false
	end

	local result = inventory:TransferItemsBySlot(slot:GetIndex(), slot:GetCount(), Factory._storage)

	Factory.Queue(item:GetId(), -result)

	return slot:GetCount() == 0
end

return Factory