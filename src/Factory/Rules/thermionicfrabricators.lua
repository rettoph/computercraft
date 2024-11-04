local Rule = require("/Factory/Rule")

local Condition = require("/Factory/Conditions/Condition")
local CompareFactoryItemTotalCondition = require("/Factory/Conditions/CompareFactoryItemTotalCondition")
local TransferItemAction = require("/Factory/Actions/TransferItemAction")
local FactoryQueueItemAction = require("/Factory/Actions/FactoryQueueItemAction")

return {
    Rule:New({
        name = "Thermo Fab to Barrels",
        enabled = true,
        interval = 1000,
        actions = {
            TransferItemAction:New({
                source = "forestry:fabricator_0",
            })
        }
    })
}