local Condition = require("/Factory/Conditions/Condition")

---@class CompareSlotCountCondition: Condition
---@field private _source Inventory
---@field private _slot integer
---@field private _value integer
---@field private _comparator fun(value1: integer, value2: integer): boolean
local CompareSlotCountCondition = {}

CompareSlotCountCondition.__index = CompareSlotCountCondition
setmetatable(CompareSlotCountCondition, { __index = Condition })

---Create new CompareSlotCountCondition instance
---@param source Inventory
---@param slot integer
---@param value integer
---@param comparator fun(value1: integer, value2: integer): boolean
---@return CompareSlotCountCondition
function CompareSlotCountCondition:New(source, slot, value, comparator)
	local o = Condition:New() --[[@as CompareSlotCountCondition]]
    setmetatable(o, self)

    o._source = source
    o._slot = slot
    o._value = value
    o._comparator = comparator

	return o
end

---@return boolean
function CompareSlotCountCondition:Invoke()
    local current = self._source:GetSlotByIndex(self._slot):GetCount()
    local result = self._comparator(current, self._value)

    return result
end

return CompareSlotCountCondition