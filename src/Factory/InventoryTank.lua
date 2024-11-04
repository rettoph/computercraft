---@class InventoryTank
---@field private _index integer
---@field private _amount integer
---@field private _capacity integer
---@field private _fluid InventoryFluid|nil
---@field private _inventory Inventory
local InventoryTank = {}

---comment
---@param index integer
---@param inventory Inventory
---@return InventoryTank
function InventoryTank:New(index, inventory)
    local o = {
        _index = index,
        _amount = 0,
        _capacity = 0,
        _inventory = inventory
    }

    setmetatable(o, self)
	self.__index = self

    return o
end

---comment
---@param amount integer
---@param fluid InventoryFluid
function InventoryTank:Clean(amount, capacity, fluid)
    self._amount = amount
    self._capacity = capacity
    self._fluid = fluid
end

---Get index
---@return integer # Index
function InventoryTank:GetIndex()
    return self._index
end

---Get amount
---@return integer # Amount
function InventoryTank:GetAmount()
    return self._amount
end

---Get capacity
---@return integer # Capacity
function InventoryTank:GetCapacity()
    return self._capacity
end

---Get fluid
---@return InventoryFluid|nil # Item
function InventoryTank:GetFluid()
    return self._fluid
end

---Remove an amount from the fluid amount
---@param amount integer
function InventoryTank:Remove(amount)
    self._amount = self._amount - amount
    self:GetFluid():Remove(amount)
end

return InventoryTank