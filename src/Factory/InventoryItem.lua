local ArrayHelper = require("/Core/ArrayHelper")

---@class InventoryItem
---@field private _id string
---@field private _inventory Inventory
---@field private _update integer
---@field private _slots InventorySlot[]
---@field private _total integer
local InventoryItem = {}

function InventoryItem:New(id, inventory)
    local o = {
        _id = id,
        _inventory = inventory,
        _slots = {},
        _total = 0
    }

    setmetatable(o, self)
	self.__index = self

    return o
end

---comment
---@param update number
---@param slot InventorySlot|nil
function InventoryItem:Clean(update, slot)
    if update ~= self._update then
        ArrayHelper.Clear(self._slots)
        self._total = 0
        self._update = update
    end

    if slot == nil then
        return
    end

    self._total = self._total + slot:GetCount()
    ArrayHelper.Add(self._slots, slot)
end

---Get item id
---@return string # Id
function InventoryItem:GetId()
    return self._id
end

---Get slots containing item
---@return InventorySlot[] # Slots
function InventoryItem:GetSlots()
    return self._slots
end

---Get total
---@return integer # Total
function InventoryItem:GetTotal()
    return self._total
end

---Remove an amount from the item total
---@param amount integer
function InventoryItem:Remove(amount)
    self._total = self._total - amount
end

return InventoryItem