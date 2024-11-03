local Rule = require("/Factory/Rule")

local Condition = require("/Factory/Conditions/Condition")
local CompareItemTotalCondition = require("/Factory/Conditions/CompareItemTotalCondition")
local TransferItemAction = require("/Factory/Actions/TransferItemAction")
local FactoryQueueItemAction = require("/Factory/Actions/FactoryQueueItemAction")

return {
    Rule:New({
        name = "Coal Coke",
        enabled = true,
        interval = 60000,
        conditions = {
            CompareItemTotalCondition:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.ingotSignalum__165",
                value = 32,
                comparator = Condition.LessThan
            })
        },
        actions = {
            TransferItemAction:New({
                destination = "enderio:tile_alloy_smelter_0",
                item = "thermalfoundation:material__item.thermalfoundation.material.ingotCopper__128",
                count = 3
            }),
            TransferItemAction:New({
                destination = "enderio:tile_alloy_smelter_0",
                item = "thermalfoundation:material__item.thermalfoundation.material.ingotSilver__130",
                count = 1
            }),
            TransferItemAction:New({
                destination = "enderio:tile_alloy_smelter_0",
                item = "minecraft:redstone__item.redstone__0",
                count = 10
            })
        },
        success = {
            FactoryQueueItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.ingotSignalum__165",
                value = 4
            })
        }
    }),
    Rule:New({
        name = "Signalum to Barrels",
        enabled = true,
        interval = 60000,
        actions = {
            TransferItemAction:New({
                source = "enderio:tile_alloy_smelter_0",
                slot = 4
            })
        }
    }),
}