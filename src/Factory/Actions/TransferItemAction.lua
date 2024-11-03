local Factory = require("/Factory/Factory")
local InventoryManager = require("/Factory/InventoryManager")
local Condition = require("/Factory/Conditions/Condition")
local CompareItemTotalCondition = require("/Factory/Conditions/CompareItemTotalCondition")

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

---comment
---@return boolean
function TransferItemAction:Invoke()
    if self._item ~= nil then
        local target = self._interval or self._count
        local amount = self._source:TransferItemsById(self._item, target, self._destination, self._slot)
    
        self:Dequeue(self._item, amount)

        return target == nil or amount == target
    end

    if self._slot ~= nil then
        local target = self._interval or self._count
        local amount, item = self._source:TransferItemsBySlot(self._slot, target, self._destination)
    
        self:Dequeue(item, amount)

        return target == nil or amount == target       
    end

    local result = true
    for _,item in pairs(self._source:GetItems()) do
        local target = item:GetTotal()
        local amount = self._source:TransferItemsById(item:GetId(), target, self._destination, self._slot)

        self:Dequeue(item:GetId(), amount)

        result = result and (amount == target)
    end

    return result
end

function TransferItemAction:Dequeue(item, amount)
    if amount == 0 then
        return
    end

    if self._destination ~= Factory:GetStorage() then
        return
    end

    --If we are stranfering to factory storage then dequeue incoming items
    Factory.Queue(item, -amount)
end

---@return Condition[]
function TransferItemAction:CreateConditions()
    ---@type Condition[]
    local result = {}

    local soureConditionThreshold = self._interval or self._count or 1
    result[#result + 1] = CompareItemTotalCondition:New({
        source = self._source, 
        item = self._item, 
        slot = self._slot,
        value = soureConditionThreshold, 
        comparator = Condition.GreaterThanOrEqualTo
    })

    if self._count ~= nil and self._item ~= nil then
        local destinationConditionThreshold = self._count - (self._interval or self._count)
        result[#result + 1] = CompareItemTotalCondition:New({
            source = self._destination, 
            item = self._item, 
            slot = self._slot,
            value = destinationConditionThreshold, 
            comparator = Condition.LessThanOrEqualTo
        })
    end

    return result
end

return TransferItemAction