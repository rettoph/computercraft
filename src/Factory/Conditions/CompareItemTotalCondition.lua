local Condition = require("/Factory/Conditions/Condition")

---@class CompareItemTotalCondition: Condition
---@field private _source Inventory
---@field private _item string
---@field private _value integer
---@field private _comparator fun(value1: integer, value2: integer): boolean
local CompareItemTotalCondition = {}

CompareItemTotalCondition.__index = CompareItemTotalCondition
setmetatable(CompareItemTotalCondition, { __index = Condition })

---Create new CompareItemTotalCondition instance
---@param source Inventory
---@param item string
---@param value integer
---@param comparator fun(value1: integer, value2: integer): boolean
---@return CompareItemTotalCondition
function CompareItemTotalCondition:New(source, item, value, comparator)
	local o = Condition:New() --[[@as CompareItemTotalCondition]]
    setmetatable(o, self)

    o._source = source
    o._item = item
    o._value = value
    o._comparator = comparator

	return o
end

---@return boolean
function CompareItemTotalCondition:Invoke()
    local current = self._source:GetItemById(self._item):GetTotal()
    local result = self._comparator(current, self._value)

    return result
end

return CompareItemTotalCondition