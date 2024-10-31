---@class Action
local Action = {}

Action.__index = Action

---Action
---@return Action
function Action:New()
	local o = {}
    setmetatable(o, self)

	return o
end

---Determin if a Action is met
---@return boolean
function Action:Invoke()
	error("NotImplemented - Action:Invoke")
end

---Create a Condition prereq
---@return Condition[]
function Action:CreateConditions()
    error("NotImplemented - Action:CreateCondition")
end

return Action

