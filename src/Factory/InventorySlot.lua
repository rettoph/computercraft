---@class InventorySlot
---@field private _index integer
---@field private _count integer
---@field private _item InventoryItem
---@field private _inventory Inventory
local InventorySlot = {}

---comment
---@param index integer
---@param inventory Inventory
---@return InventorySlot
function InventorySlot:New(index, inventory)
    local o = {
        _index = index,
        _count = 0,
        _inventory = inventory
    }

    setmetatable(o, self)
	self.__index = self

    return o
end

---comment
---@param count integer
---@param item InventoryItem
function InventorySlot:Clean(count, item)
    self._count = count
    self._item = item
end

---Get index
---@return integer # Index
function InventorySlot:GetIndex()
    return self._index
end

---Get count
---@return integer # Count
function InventorySlot:GetCount()
    return self._count
end

---Get item
---@return InventoryItem # Item
function InventorySlot:GetItem()
    return self._item
end

return InventorySlot