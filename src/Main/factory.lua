local Logger = require("/Core/Logger")
local Factory = require("/Factory/Factory")
local InventoryManager = require("/Factory/InventoryManager")

local logger = Logger:New({ Logger.Console:New(Logger.Level.VERBOSE), Logger.File:New(Logger.Level.ERROR) })

InventoryManager.Initialize(logger)

local left = InventoryManager.GetByName("left")
local right = InventoryManager.GetByName("right")

left:TransferItemsById("minecraft:bone__item.bone__0", nil, right)

local bones = left:GetItemById("minecraft:bone__item.bone__0")
print(bones:GetTotal())

for _,item in pairs(left:GetItems()) do
    print(item:GetId() .. " - " .. item:GetTotal())
end

-- Factory.Initialize(logger, InventoryManager.GetByName("yabba:item_barrel_connector_1"))


