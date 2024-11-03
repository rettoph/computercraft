local Condition = require("/Factory/Conditions/Condition")

---@class CompareTotalCondition: Condition
---@field private _source Inventory
---@field private _value integer
---@field private _comparator fun(value1: integer, value2: integer): boolean
local CompareTotalCondition = {}

CompareTotalCondition.__index = CompareTotalCondition
setmetatable(CompareTotalCondition, { __index = Condition })

---Create new CompareTotalCondition instance
---@param source Inventory
---@param value integer
---@param comparator fun(value1: integer, value2: integer): boolean
---@return CompareTotalCondition
function CompareTotalCondition:New(source, value, comparator)
	local o = Condition:New() --[[@as CompareTotalCondition]]
    setmetatable(o, self)

    o._source = source
    o._value = value
    o._comparator = comparator

	return o
end

---@return boolean
function CompareTotalCondition:Invoke()
    local current = 0
    for _,item in pairs(self._source:GetItems()) do
        current = current + item:GetTotal()
    end

    local result = self._comparator(current, self._value)

    return result
end

return CompareTotalCondition