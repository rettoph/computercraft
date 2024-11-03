local Factory = require("/Factory/Factory")
local InventoryManager = require("/Factory/InventoryManager")
local Condition = require("/Factory/Conditions/Condition")
local CompareTotalCondition = require("/Factory/Conditions/CompareTotalCondition")
local CompareItemTotalCondition = require("/Factory/Conditions/CompareItemTotalCondition")
local CompareFactoryItemTotalCondition = require("/Factory/Conditions/CompareFactoryItemTotalCondition")

local Action = require("/Factory/Actions/Action")

---@class FactoryQueueItemActionContext
---@field public item string
---@field public value integer
local FactoryQueueItemActionContext = {}

---@class FactoryQueueItemAction: Action
---@field private _item string
---@field private _value integer
local FactoryQueueItemAction = {}

FactoryQueueItemAction.__index = FactoryQueueItemAction
setmetatable(FactoryQueueItemAction, { __index = Action })

---Transfer an item from a source to a destination
---@param context FactoryQueueItemActionContext
---@return FactoryQueueItemAction
function FactoryQueueItemAction:New(context)
	local o = Action:New() --[[@as FactoryQueueItemAction]]
    setmetatable(o, self)

    o._item = context.item
    o._value = context.value

	return o
end

---comment
---@return boolean
function FactoryQueueItemAction:Invoke()
    Factory.Queue(self._item, self._value)

    return true
end

---@return Condition[]
function FactoryQueueItemAction:CreateConditions()
    return {}
end

return FactoryQueueItemAction