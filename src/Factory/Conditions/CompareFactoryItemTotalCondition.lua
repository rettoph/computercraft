local Factory = require("/Factory/Factory")
local Condition = require("/Factory/Conditions/Condition")

---@class CompareFactoryItemTotalConditionContext
---@field public item string
---@field public value integer
---@field public comparator fun(value1: integer, value2: integer): boolean

---@class CompareFactoryItemTotalCondition: Condition
---@field private _item string
---@field private _value integer
---@field private _comparator fun(value1: integer, value2: integer): boolean
local CompareFactoryItemTotalCondition = {}

CompareFactoryItemTotalCondition.__index = CompareFactoryItemTotalCondition
setmetatable(CompareFactoryItemTotalCondition, { __index = Condition })

---Create new CompareFactoryItemTotalCondition instance
---@param context CompareFactoryItemTotalConditionContext
---@return CompareFactoryItemTotalCondition
function CompareFactoryItemTotalCondition:New(context)
	local o = Condition:New() --[[@as CompareFactoryItemTotalCondition]]
    setmetatable(o, self)

    o._item = context.item
    o._value = context.value
    o._comparator = context.comparator

	return o
end

---@return boolean
function CompareFactoryItemTotalCondition:Invoke()
    local current = Factory.GetItemTotalById(self._item)
    local result = self._comparator(current, self._value)

    return result
end

return CompareFactoryItemTotalCondition