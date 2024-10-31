---@class Condition
local Condition = {}

Condition.__index = Condition

---Condition
---@return Condition
function Condition:New()
	local o = {}
    setmetatable(o, self)

	return o
end

---Determin if a condition is met
---@return boolean
function Condition:Invoke()
	error("NotImplemented - Condition:Invoke")
end

---GreaterThan
---@param value1 integer
---@param value2 integer
---@return boolean
function Condition.GreaterThan(value1, value2)
    return value1 > value2
end

---GreaterThanOrEqualTo
---@param value1 integer
---@param value2 integer
---@return boolean
function Condition.GreaterThanOrEqualTo(value1, value2)
    return value1 >= value2
end

---LessThan
---@param value1 integer
---@param value2 integer
---@return boolean
function Condition.LessThan(value1, value2)
    return value1 < value2
end

---LessThanOrEqualTo
---@param value1 integer
---@param value2 integer
---@return boolean
function Condition.LessThanOrEqualTo(value1, value2)
    return value1 <= value2
end

---EqualTo
---@param value1 integer
---@param value2 integer
---@return boolean
function Condition.EqualTo(value1, value2)
    return value1 == value2
end

return Condition

