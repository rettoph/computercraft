local InventoryItem = require("/Factory/InventoryItem")
local InventorySlot = require("/Factory/InventorySlot")
local ItemMetaCache = require("/Factory/ItemMetaCache")

---@class Inventory
---@field private _name string
---@field private _logger Logger
---@field private _dirty boolean
---@field private _items { [string]: InventoryItem }
---@field private _slots { [integer]: InventorySlot }
---@field private _itemCache { [string]: InventoryItem }
---@field private _slotCache { [integer]: InventorySlot }
---@field private _update integer
local Inventory = {}

---comment
---@param self Inventory
---@param name string
---@param logger Logger
---@return Inventory
function Inventory:New(name, logger)
    local o = {
        _name = name,
        _logger = logger,
        _itemCache = {},
        _slotCache = {},
        _update = 0
    }

    setmetatable(o, self)
	self.__index = self

    return o
end

---comment Get the current inventory name
---@param self Inventory
---@return string # name
function Inventory:GetName()
    return self._name
end

---comment
---@param self Inventory
---@return table|nil # The module, if successful
function Inventory:GetModule()
    return peripheral.wrap(self._name)
end

---Set the dirty state
---@param self Inventory
---@param value boolean
function Inventory:SetDirty(value)
    self._dirty = value
end

---Return all items
---@param self Inventory
---@return { [string]: InventoryItem }
---@public
function Inventory:GetItems()
    self:Clean()

    return self._items
end

---Return an item
---@param self Inventory
---@param id string
---@return InventoryItem
function Inventory:GetItemById(id)
    self:Clean()

    local result = self._items[id]
    if result ~= nil then
        return result
    end

    result = self._itemCache[id]
    if result ~= nil then
        self._items[id] = result
        return result
    end

    result = InventoryItem:New(id, self)
    self._itemCache[id] = result
    self._items[id] = result

    return result
end

---Return all slots
---@param self Inventory
---@return { [integer]: InventorySlot }
function Inventory:GetSlots()
    self:Clean()

    return self._slots
end

---Return a slot
---@param self Inventory
---@param index integer
---@return InventorySlot
function Inventory:GetSlot(index)
    self:Clean()

    local result = self._slot[index]
    if result ~= nil then
        return result
    end

    result = self._slotCache[index]
    if result ~= nil then
        self._slot[index] = result
        return result
    end

    result = InventorySlot:New(index, self)
    self._slotCache[index] = result
    self._slot[index] = result

    return result
end

---Refresh all internal item and slot caches
---@param self Inventory
---@return boolean
---@private
function Inventory:Clean()
    if self._dirty == false then
        return true
    end

    self._logger:Verbose("Cleaning Inventory: " .. self:GetName())

    self._update = self._update + 1
    self._slots = {}
    self._items = {}

    local module = self:GetModule()
    if module == nil then
        self._logger:Warning("Inventory not found: " .. self:GetName())
        return false
    end

    local list = module.list()
	if list == nil then
        return false
    end

    for index,data in pairs(list) do
		if data ~= nil then
			local meta = ItemMetaCache.GetByItem(data, index, module) or {}

            ---@type InventorySlot
			local slot = self:GetCachedSlotByIndex(index)
            local item = self:GetCachedItemById(meta.id)

            slot:Clean(data.count, item)
            item:Clean(self._update, slot);

            self._slots[index] = slot
            self._items[meta.id] = item
		end
	end

    ItemMetaCache:Clean()
    Inventory:SetDirty(false)
    return true
end

---Transfer items matching a specific id
---@param self Inventory
---@param id string
---@param count integer|nil
---@param destination Inventory
---@param destinationSlotIndex integer|nil
---@return integer
function Inventory:TransferItemsById(id, count, destination, destinationSlotIndex)
	local item = self:GetItemById(id)
	if item:GetTotal() == 0 then
		return 0
	end
	
	if #item:GetSlots() == 0 then
		return 0
	end

    if count == nil then
        count = item:GetTotal()
    end

	if count <= 0 then
		return 0
	end
	
    local module = self:GetModule()
    if module == nil then
        self._logger:Warning("Inventory not found: " .. self:GetName())
        return 0
    end

	local result = 0
	for i,slot in pairs(item:GetSlots()) do
		local amount = math.min(slot:GetCount(), count)
		
		repeat
			amount = module.pushItems(destination:GetName(), slot:GetIndex(), amount, destinationSlotIndex)

			slot:Remove(amount)
			result = result + amount
		until result >= count or slot:GetCount() == 0 or amount <= 0
		
		if result >= count then
            
			self._logger:Verbose("Transfered " .. result .. "/" .. count .. " '" .. id .. "' from '" .. self:GetName() .. "' to '" .. destination:GetName() .. "'")
			return result
		end
	end

	self._logger:Verbose("Transfered " .. result .. "/" .. count .. " '" .. id .. "' from '" .. self:GetName() .. "' to '" .. destination:GetName() .. "'")
	return result
end

---Transfer items from a specific slot
---@param self Inventory
---@param slotIndex integer # Slot index
---@param count integer|nil
---@param destination Inventory
---@param destinationSlotIndex integer|nil
---@return integer
function Inventory:TransferItemsBySlot(slotIndex, count, destination, destinationSlotIndex)
    local slot = self:GetSlot(slotIndex)
	if slot:GetCount() == 0 then
		return 0
	end

	if count <= 0 then
		return 0
	end
	
    local module = self:GetModule()
    if module == nil then
        self._logger:Warning("Inventory not found: " .. self:GetName())
        return 0
    end

	local result = 0
    local amount = math.min(slot.count, count)
		
    repeat
        amount = module.pushItems(destination:GetName(), slot.index, amount, destinationSlotIndex)

        slot:Remove(amount)
        result = result + amount
    until result >= count or slot.count == 0 or amount <= 0
    
    if result >= count then
        self._logger:Debug("Transfered " .. result .. "/" .. count .. " '" .. slot:GetItem():GetId() .. "' from '" .. self:GetName() .. "' to '" .. destination:GetName() .. "'")
        return result
    end

	self._logger:Debug("Transfered " .. result .. "/" .. count .. " '" .. slot:GetItem():GetId() .. "' from '" .. self:GetName() .. "' to '" .. destination:GetName() .. "'")
	return result
end

---Push all current items already within the destination inventory
---@param self Inventory
---@param destination Inventory
function Inventory:Squash(destination)
	for _,destinationItem in pairs(destination:GetItems()) do
		local sourceItem = self:GetItemById(destinationItem.id)
		if sourceItem.total > 0 then
			self._logger:Debug("Squash '" .. destinationItem.id .. "' from '" .. self:GetName() .. "' to '" .. destination:GetName() .. "'")
			self:TransferItemsById(destinationItem.id, nil, destination)
		end
	end
end

---Transfer unstacked items from current inventory into destination inventory and vice versa
---@param self Inventory
---@param destination Inventory
---@return boolean
function Inventory:TransferUnstackedItems(destination)
	local function cleanup()
		-- Stacked -> Unstacked
		for _,slot in pairs(self:GetSlots()) do
			if slot.count == 1 then
				self._logger:Info("Transfering unstacked item from stacked to unstacked: " .. slot.id)
				self:TransferItemsById(slot.id, 1, destination)
				return true
			end
		end
	
		-- Unstacked -> Stacked
		for _,slot in pairs(destination:GetSlots()) do
			if slot.count > 1 then
				self._logger:Info("Transfering stacked items from unstacked to stacked: " .. slot.id)
				destination:TransferItemsById(slot.id, slot.count, self)
				return true
			end
		end
	
		return false
	end

	local count = 0
	while cleanup() and count < 100 do
		count = count + 1
	end

	if count >= 100 then
		self._logger:Warning("TransferUnstackedItems - overflow?")
		return false
	end

	return true
end

---Return an item from the item cache
---@param self Inventory
---@param id string
---@return InventoryItem
---@private
function Inventory:GetCachedItemById(id)
    local result = self._itemCache[id]
    if result == nil then
        result = InventoryItem:New(id, self)
        self._itemCache[id] = result
    end

    return result
end

---Return a slot from the slot cache
---@param self Inventory
---@param index integer
---@return InventorySlot
---@private
function Inventory:GetCachedSlotByIndex(index)
    local result = self._slotCache[index]
    if result == nil then
        result = InventorySlot:New(index, self)
        self._slotCache[index] = result
    end

    return result
end

---Get module by name
---@param name string Peripheral name
---@return boolean # Success result
---@return table|nil # The module, if successful
function Inventory.TryGetModule(name)
    local module = peripheral.wrap(name)

    return module ~= nil, module
end

return Inventory