local Rule = require("/Factory/Rule")

local Condition = require("/Factory/Conditions/Condition")
local CompareItemTotalCondition = require("/Factory/Conditions/CompareItemTotalCondition")
local TransferItemAction = require("/Factory/Actions/TransferItemAction")
local FactoryQueueItemAction = require("/Factory/Actions/FactoryQueueItemAction")

return {
    Rule:New({
        name = "Steel Ingots (Coal Coke)",
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
                destination = "minecraft:chest_11",
                item = "thermalfoundation:material__item.thermalfoundation.material.fuelCoke__802",
                count = 8,
                interval = 1
            })
        }
    }),
    Rule:New({
        name = "Steel Ingots (Iron Ingots)",
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
                destination = "minecraft:chest_11",
                item = "minecraft:iron_ingot__item.ingotIron__0",
                count = 8,
                interval = 1
            })
        },
        success = {
            FactoryQueueItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.ingotSteel__160",
                value = 1
            })
        }
    }),
    Rule:New({
        name = "Coal Coke",
        enabled = true,
        interval = 6000,
        conditions = {
            CompareItemTotalCondition:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.fuelCoke__802",
                value = 512,
                comparator = Condition.LessThan
            })
        },
        actions = {
            TransferItemAction:New({
                destination = "minecraft:chest_11",
                item = "minecraft:coal__item.coal__0",
                count = 8,
                interval = 1
            })
        },
        success = {
            FactoryQueueItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.fuelCoke__802",
                value = 1
            })
        }
    }),
    Rule:New({
        name = "Blast Furnace/Coke Oven to Barrels",
        enabled = true,
        interval = 60000,
        actions = {
            TransferItemAction:New({
                source = "minecraft:chest_10",
            })
        }
    }),
}