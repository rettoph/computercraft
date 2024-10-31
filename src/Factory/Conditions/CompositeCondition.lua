local Condition = require("/Factory/Conditions/Condition")

---@class CompositeCondition: Condition
---@field private _conditions Condition[]
---@field private _comparator fun(conditions: Condition[]): boolean
local CompositeCondition = {}

CompositeCondition.__index = CompositeCondition
setmetatable(CompositeCondition, { __index = Condition })

---Create new CompositeCondition instance
---@param conditions Condition[]
---@param comparator fun(conditions: Condition[]): boolean
---@return CompositeCondition
function CompositeCondition:New(conditions, comparator)
	local o = Condition:New() --[[@as CompositeCondition]]
    setmetatable(o, self)

    o._conditions = conditions
    o._comparator = comparator

	return o
end

---@return boolean
function CompositeCondition:Invoke()
    local result = self._comparator(self._conditions)

    return result
end

return CompositeCondition