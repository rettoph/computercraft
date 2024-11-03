local Rule = require("/Factory/Rule")

local Condition = require("/Factory/Conditions/Condition")
local CompareItemTotalCondition = require("/Factory/Conditions/CompareItemTotalCondition")
local TransferItemAction = require("/Factory/Actions/TransferItemAction")
local FactoryQueueItemAction = require("/Factory/Actions/FactoryQueueItemAction")

return {
    Rule:New({
        name = "Dense Steel Plates",
        enabled = true,
        interval = 6000,
        conditions = {
            CompareItemTotalCondition:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.ingotSteel__160",
                value = 512,
                comparator = Condition.LessThan
            })
        },
        actions = {
            TransferItemAction:New({
                destination = "ic2:compressor_0",
                item = "thermalfoundation:material__item.thermalfoundation.material.plateSteel__352",
                count = 9
            })
        },
        success = {
            FactoryQueueItemAction:New({
                item = "ic2:plate__ic2.plate.dense_steel__16",
                value = 1
            })
        }
    }),
    Rule:New({
        name = "Dense Steel Plates to Barrels",
        enabled = true,
        interval = 10000,
        actions = {
            TransferItemAction:New({
                source = "ic2:compressor_0",
                slot = 2
            })
        }
    }),
}