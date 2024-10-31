local Factory = require("/Factory/Factory")
local Condition = require("/Factory/Conditions/Condition")

---@class CompareFactoryItemTotalCondition: Condition
---@field private _item string
---@field private _value integer
---@field private _comparator fun(value1: integer, value2: integer): boolean
local CompareFactoryItemTotalCondition = {}

CompareFactoryItemTotalCondition.__index = CompareFactoryItemTotalCondition
setmetatable(CompareFactoryItemTotalCondition, { __index = Condition })

---Create new CompareFactoryItemTotalCondition instance
---@param item string
---@param value integer
---@param comparator fun(value1: integer, value2: integer): boolean
---@return CompareFactoryItemTotalCondition
function CompareFactoryItemTotalCondition:New(item, value, comparator)
	local o = Condition:New() --[[@as CompareFactoryItemTotalCondition]]
    setmetatable(o, self)

    o._item = item
    o._value = value
    o._comparator = comparator

	return o
end

---@return boolean
function CompareFactoryItemTotalCondition:Invoke()
    local current = Factory.GetItemTotalById(self._item)
    local result = self._comparator(current, self._value)

    return result
end

return CompareFactoryItemTotalCondition