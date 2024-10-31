local Factory = require("/Factory/Factory")
local Condition = require("/Factory/Conditions/Condition")
local CompareItemTotalCondition = require("/Factory/Conditions/CompareItemTotalCondition")
local CompareFactoryItemTotalCondition = require("/Factory/Conditions/CompareFactoryItemTotalCondition")

local Action = require("/Factory/Actions/Action")


---@class TransferItemAction: Action
---@field private _source Inventory|nil
---@field private _item string
---@field private _count integer|nil
---@field private _interval integer|nil
---@field private _destination Inventory
---@field private _slot integer|nil
local TransferItemAction = {}

TransferItemAction.__index = TransferItemAction
setmetatable(TransferItemAction, { __index = Action })

---Transfer an item from a source to a destination
---@param source Inventory|nil
---@param item string
---@param count integer|nil
---@param interval integer|nil
---@param destination Inventory
---@param slot integer|nil
---@return TransferItemAction
function TransferItemAction:New(source, item, count, interval, destination, slot)
	local o = Action:New() --[[@as TransferItemAction]]
    setmetatable(o, self)

    o._source = source
    o._item = item
    o._count = count
    o._interval = interval
    o._destination = destination
    o._slot = slot

	return o
end

function TransferItemAction:Invoke()
    local amount = self._interval or self._count

    if self._source == nil then
        Factory.TransferItemsById(self._item, amount, self._destination, self._slot)
    else
        self._source:TransferItemsById(self._item, amount, self._destination, self._slot)
    end
end

---@return Condition[]
function TransferItemAction:CreateConditions()
    ---@type Condition[]
    local result = {}

    local soureConditionThreshold = self._interval or self._count or 1
    result[#result + 1] = TransferItemAction.CreateSourceCondition(self._source, self._item, soureConditionThreshold);

    if self._count ~= nil then
        local destinationConditionThreshold = self._count - (self._interval or 0)
        result[#result + 1] = CompareItemTotalCondition:New(self._destination, self._item, destinationConditionThreshold, Condition.LessThanOrEqualTo)
    end

    return result
end

---Create condition for item transfer source
---@private
---@param source Inventory|nil
---@param item string
---@param amount number
---@return Condition
function TransferItemAction.CreateSourceCondition(source, item, amount)
    if source == nil then
        return CompareFactoryItemTotalCondition:New(item, amount, Condition.GreaterThanOrEqualTo)
    end

    return CompareItemTotalCondition:New(source, item, amount, Condition.GreaterThanOrEqualTo)
end

return TransferItemAction