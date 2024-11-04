local InventoryManager = require("/Factory/InventoryManager")
local Factory = require("/Factory/Factory")

local Condition = require("/Factory/Conditions/Condition")

---@class CompareItemTotalConditionContext
---@field public source Inventory|string|nil
---@field public item string|nil
---@field public slot integer|nil
---@field public value integer
---@field public comparator fun(value1: integer, value2: integer): boolean

---@class CompareItemTotalCondition: Condition
---@field private _source Inventory
---@field private _item string
---@field private _slot integer|nil
---@field private _value integer
---@field private _comparator fun(value1: integer, value2: integer): boolean
local CompareItemTotalCondition = {}

CompareItemTotalCondition.__index = CompareItemTotalCondition
setmetatable(CompareItemTotalCondition, { __index = Condition })

---Create new CompareItemTotalCondition instance
---@param context CompareItemTotalConditionContext
---@return CompareItemTotalCondition
function CompareItemTotalCondition:New(context)
	local o = Condition:New() --[[@as CompareItemTotalCondition]]
    setmetatable(o, self)

    if context.source == nil then
        o._source = Factory:GetStorage()
    elseif type(context.source) == "string" then
        o._source = InventoryManager.GetByName(context.source --[[@as string]])
    else
        o._source = context.source --[[@as Inventory]]
    end

    o._item = context.item
    o._slot = context.slot
    o._value = context.value
    o._comparator = context.comparator

	return o
end

---@return boolean
function CompareItemTotalCondition:Invoke()
    local current = 0

    -- get the number of specific items in the specified spot
    if self._slot ~= nil and self._item ~= nil then
        local slot = self._source:GetSlotByIndex(self._slot)
        local item = slot:GetItem()

        if item ~= nil and item:GetId() ~= self._item then
            return false
        end

        current = slot:GetCount()
        return self._comparator(current, self._value)
    end

    -- get the number of the specified item
    if self._item ~= nil then
        current = self._source:GetItemById(self._item):GetTotal()
        return self._comparator(current, self._value)
    end

    -- get the number of items in the specified slot
    if self._slot ~= nil then
        local slot = self._source:GetSlotByIndex(self._slot)
        current = slot:GetCount()
        return self._comparator(current, self._value)
    end

    -- calculate the total number of all items in the entire inventory
    for _,item in pairs(self._source:GetItems()) do
        current = current + item:GetTotal()
    end
    return self._comparator(current, self._value)
end

return CompareItemTotalCondition