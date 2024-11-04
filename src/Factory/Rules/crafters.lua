local Rule = require("/Factory/Rule")

local Condition = require("/Factory/Conditions/Condition")
local CompareFactoryItemTotalCondition = require("/Factory/Conditions/CompareFactoryItemTotalCondition")
local TransferItemAction = require("/Factory/Actions/TransferItemAction")
local FactoryQueueItemAction = require("/Factory/Actions/FactoryQueueItemAction")

return {
    Rule:New({
        name = "Signalum Nuggets",
        enabled = true,
        interval = 10000,
        conditions = {
            CompareFactoryItemTotalCondition:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.nuggetSignalum__229",
                value = 64,
                comparator = Condition.LessThan
            })
        },
        actions = {
            TransferItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.ingotSignalum__165",
                count = 2,
                interval = 1,
                destination = "buildcraftfactory:autoworkbench_item_2"
            })
        },
        success = {
            FactoryQueueItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.nuggetSignalum__229",
                value = 9
            })
        }
    }),
    Rule:New({
        name = "Crafters to Barrels",
        enabled = true,
        interval = 10000,
        actions = {
            TransferItemAction:New({
                source = "buildcraftfactory:autoworkbench_item_2",
                slot = 10
            })
        }
    }),
}