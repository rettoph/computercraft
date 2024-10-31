local Logger = require("/Core/Logger")
local Factory = require("/Factory/Factory")
local InventoryManager = require("/Factory/InventoryManager")
local TransferItemAction = require("/Factory/Actions/TransferItemAction")

local logger = Logger:New({ Logger.Console:New(Logger.Level.VERBOSE), Logger.File:New(Logger.Level.ERROR) })

InventoryManager.Initialize(logger)

-- local left = InventoryManager.GetByName("minecraft:chest_9")
-- local right = InventoryManager.GetByName("right")

-- left:TransferItemsById("minecraft:bone__item.bone__0", nil, right)
-- local bones = left:GetItemById("minecraft:bone__item.bone__0")

Factory.Initialize(logger, InventoryManager.GetByName("yabba:item_barrel_connector_1"))

local inventory = Factory.GetInventoryByName("minecraft:chest_9")
local test = TransferItemAction:New(nil, "minecraft:sugar__item.sugar__0", 5, 1, inventory, nil)
local conditions = test:CreateConditions()
local result = true
for i,condition in pairs(conditions) do
    result = result and condition:Invoke()
end



