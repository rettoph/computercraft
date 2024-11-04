local ArrayHelper = require("/Core/ArrayHelper")

---@class InventoryFluid
---@field private _id string
---@field private _inventory Inventory
---@field private _update integer
---@field private _tanks InventoryTank[]
---@field private _total integer
local InventoryFluid = {}

function InventoryFluid:New(id, inventory)
    local o = {
        _id = id,
        _inventory = inventory,
        _tanks = {},
        _total = 0
    }

    setmetatable(o, self)
	self.__index = self

    return o
end

---comment
---@param update number
---@param tank InventoryTank|nil
function InventoryFluid:Clean(update, tank)
    if update ~= self._update then
        ArrayHelper.Clear(self._tanks)
        self._total = 0
        self._update = update
    end

    if tank == nil then
        return
    end

    self._total = self._total + tank:GetAmount()
    ArrayHelper.Add(self._tanks, tank)
end

---Get item id
---@return string # Id
function InventoryFluid:GetId()
    return self._id
end

---Get slots containing item
---@return InventoryTank[] # Tanks
function InventoryFluid:GetTanks()
    return self._tanks
end

---Get total
---@return integer # Total
function InventoryFluid:GetTotal()
    return self._total
end

---Remove an amount from the item total
---@param amount integer
function InventoryFluid:Remove(amount)
    self._total = self._total - amount
end

return InventoryFluid