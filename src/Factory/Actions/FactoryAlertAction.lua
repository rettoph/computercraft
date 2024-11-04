local Factory = require("/Factory/Factory")

local Action = require("/Factory/Actions/Action")

---@class FactoryAlertActionContext
---@field public message string
local FactoryAlertActionContext = {}

---@class FactoryAlertAction: Action
---@field private _message string
local FactoryAlertAction = {}

FactoryAlertAction.__index = FactoryAlertAction
setmetatable(FactoryAlertAction, { __index = Action })

---Transfer an item from a source to a destination
---@param context FactoryAlertActionContext
---@return FactoryAlertAction
function FactoryAlertAction:New(context)
	local o = Action:New() --[[@as FactoryAlertAction]]
    setmetatable(o, self)

    o._message = context.message

	return o
end

---comment
---@return boolean
function FactoryAlertAction:Invoke()
    Factory.Alert(self._message)

    return true
end

---@return Condition[]
function FactoryAlertAction:CreateConditions()
    return {}
end

return FactoryAlertAction