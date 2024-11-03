local Factory = require("/Factory/Factory")
local InventoryManager = require("/Factory/InventoryManager")
local Condition = require("/Factory/Conditions/Condition")
local CompareTotalCondition = require("/Factory/Conditions/CompareTotalCondition")
local CompareItemTotalCondition = require("/Factory/Conditions/CompareItemTotalCondition")
local CompareFactoryItemTotalCondition = require("/Factory/Conditions/CompareFactoryItemTotalCondition")

local Action = require("/Factory/Actions/Action")

---@class TransferItemActionContext
---@field public source string|nil
---@field public item string|nil
---@field public count integer|nil
---@field public interval integer|nil
---@field public destination string|nil
---@field public slot integer|nil
local TransferItemActionContext = {}

---@class TransferItemAction: Action
---@field private _source Inventory
---@field private _destination Inventory
---@field private _item string|nil
---@field private _count integer|nil
---@field private _interval integer|nil
---@field private _slot integer|nil
local TransferItemAction = {}

TransferItemAction.__index = TransferItemAction
setmetatable(TransferItemAction, { __index = Action })

---Transfer an item from a source to a destination
---@param context TransferItemActionContext
---@return TransferItemAction
function TransferItemAction:New(context)
	local o = Action:New() --[[@as TransferItemAction]]
    setmetatable(o, self)

    if context.source == context.destination then
        error("Source should not match destination")
    end

    local source = Factory.GetStorage()
    local destination =  Factory.GetStorage()
    if context.source ~= nil then
        source = InventoryManager.GetByName(context.source)
    end

    if context.destination ~= nil then
        destination = InventoryManager.GetByName(context.destination)
    end

    o._source = source
    o._destination = destination
    o._item = context.item
    o._count = context.count
    o._interval = context.interval
    o._slot = context.slot

	return o
end

function TransferItemAction:Invoke()
    if self._item ~= nil then
        local target = self._interval or self._count
        local amount = self._source:TransferItemsById(self._item, target, self._destination, self._slot)
    
        return amount == target
    end

    local result = true
    for _,item in pairs(self._source:GetItems()) do
        local target = item:GetTotal()
        local amount = self._source:TransferItemsById(item:GetId(), target, self._destination, self._slot)
        result = result and (amount == target)
    end

    return result
end

---@return Condition[]
function TransferItemAction:CreateConditions()
    ---@type Condition[]
    local result = {}

    local soureConditionThreshold = self._interval or self._count or 1
    if self._item == nil then
        result[#result + 1] = CompareTotalCondition:New(self._source, soureConditionThreshold, Condition.GreaterThanOrEqualTo)
    else
        result[#result + 1] = CompareItemTotalCondition:New(self._source, self._item, soureConditionThreshold, Condition.GreaterThanOrEqualTo)
    end

    if self._count ~= nil and self._item ~= nil then
        local destinationConditionThreshold = self._count - (self._interval or self._count)
        result[#result + 1] = CompareItemTotalCondition:New(self._destination, self._item, destinationConditionThreshold, Condition.LessThanOrEqualTo)
    end

    return result
end

return TransferItemAction