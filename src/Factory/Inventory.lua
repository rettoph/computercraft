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
---@return string # name
function Inventory:GetName()
    return self._name
end

---comment
---@return table|nil # The module, if successful
function Inventory:GetModule()
    return peripheral.wrap(self._name)
end

---Set the dirty state
---@param value boolean
function Inventory:SetDirty(value)
    self._dirty = value
end

---Return all items
---@return { [string]: InventoryItem }
---@public
function Inventory:GetItems()
    self:Clean()

    return self._items
end

---Return an item
---@param id string
---@return InventoryItem
function Inventory:GetItemById(id)
    self:Clean()

    local result = self._cache[id]
    if result == nil then
        result = InventoryItem:New(id, self)
        self._cache[id] = result
    end

    return result
end

---Return all slots
---@return { [integer]: InventorySlot }
function Inventory:GetSlots()
    self:Clean()

    return self._slots
end

---Return a slot
---@param index integer
---@return InventorySlot
function Inventory:GetSlot(index)
    self:Clean()

    return self._slots[index]
end

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
end

---comment
---@param name string Peripheral name
---@return boolean # Success result
---@return table|nil # The module, if successful
function Inventory.TryGetModule(name)
    local module = peripheral.wrap(name)

    return module ~= nil, module
end

---Return an item from the item cache
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

return Inventory