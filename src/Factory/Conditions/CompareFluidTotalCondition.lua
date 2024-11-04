local InventoryManager = require("/Factory/InventoryManager")
local Factory = require("/Factory/Factory")

local Condition = require("/Factory/Conditions/Condition")

---@class CompareFluidTotalConditionContext
---@field public source Inventory|string|nil
---@field public fluid string|nil
---@field public tank integer|nil
---@field public value integer
---@field public comparator fun(value1: integer, value2: integer): boolean

---@class CompareFluidTotalCondition: Condition
---@field private _source Inventory
---@field private _fluid string
---@field private _tank integer|nil
---@field private _value integer
---@field private _comparator fun(value1: integer, value2: integer): boolean
local CompareFluidTotalCondition = {}

CompareFluidTotalCondition.__index = CompareFluidTotalCondition
setmetatable(CompareFluidTotalCondition, { __index = Condition })

---Create new CompareFluidTotalCondition instance
---@param context CompareFluidTotalConditionContext
---@return CompareFluidTotalCondition
function CompareFluidTotalCondition:New(context)
	local o = Condition:New() --[[@as CompareFluidTotalCondition]]
    setmetatable(o, self)

    if context.source == nil then
        o._source = Factory:GetStorage()
    elseif type(context.source) == "string" then
        o._source = InventoryManager.GetByName(context.source --[[@as string]])
    else
        o._source = context.source --[[@as Inventory]]
    end

    o._fluid = context.fluid
    o._tank = context.tank
    o._value = context.value
    o._comparator = context.comparator

	return o
end

---@return boolean
function CompareFluidTotalCondition:Invoke()
    local current = 0

    -- get the number of specific fluids in the specified spot
    if self._tank ~= nil and self._fluid ~= nil then
        local tank = self._source:GetTankByIndex(self._tank)

        if tank:GetFluid():GetId() ~= self._fluid then
            return false
        end
        
        current = tank:GetAmount()
        return self._comparator(current, self._value)
    end

    -- get the number of the specified fluid
    if self._fluid ~= nil then
        current = self._source:GetFluidById(self._fluid):GetTotal()
        return self._comparator(current, self._value)
    end

    -- get the number of fluids in the specified tank
    if self._tank ~= nil then
        local tank = self._source:GetTankByIndex(self._tank)
        current = tank:GetAmount()
        return self._comparator(current, self._value)
    end

    -- calculate the total number of all fluids in the entire inventory
    for _,fluid in pairs(self._source:GetFluids()) do
        current = current + fluid:GetTotal()
    end
    return self._comparator(current, self._value)
end

return CompareFluidTotalCondition