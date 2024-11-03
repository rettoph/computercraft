local Rule = require("/Factory/Rule")

local Condition = require("/Factory/Conditions/Condition")
local CompareFactoryItemTotalCondition = require("/Factory/Conditions/CompareFactoryItemTotalCondition")
local TransferItemAction = require("/Factory/Actions/TransferItemAction")
local FactoryQueueItemAction = require("/Factory/Actions/FactoryQueueItemAction")

return {} or {
    Rule:New({
        name = "Pulverizers to Barrels",
        enabled = true,
        interval = 60000,
        actions = {
            TransferItemAction:New({
                source = "immersiveengineering:woodencrate_0",
            })
        }
    }),
    Rule:New({
        name = "Nether Quartz Dust",
        enabled = true,
        interval = 2000,
        conditions = {
            CompareFactoryItemTotalCondition:New({
                item = "appliedenergistics2:material__item.appliedenergistics2.material.nether_quartz_dust__3",
                value = 64,
                comparator = Condition.LessThan
            })
        },
        actions = {
            TransferItemAction:New({
                item = "minecraft:quartz__item.netherquartz__0",
                count = 4,
                destination = "immersiveengineering:woodencrate_1"
            })
        },
        success = {
            FactoryQueueItemAction:New({
                item = "appliedenergistics2:material__item.appliedenergistics2.material.nether_quartz_dust__3",
                value = 2
            })
        }
    }),
    Rule:New({
        name = "Lapis Lazuli Dust",
        enabled = true,
        interval = 2000,
        conditions = {
            CompareFactoryItemTotalCondition:New({
                item = "ic2:dust__ic2.dust.lapis__9",
                value = 16,
                comparator = Condition.LessThan
            })
        },
        actions = {
            TransferItemAction:New({
                item = "minecraft:dye__item.dyePowder.blue__4",
                count = 4,
                destination = "immersiveengineering:woodencrate_1"
            })
        },
        success = {
            FactoryQueueItemAction:New({
                item = "ic2:dust__ic2.dust.lapis__9",
                value = 2
            })
        }
    }),
    Rule:New({
        name = "Coal Dust",
        enabled = true,
        interval = 2000,
        conditions = {
            CompareFactoryItemTotalCondition:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.dustCoal__768",
                value = 64,
                comparator = Condition.LessThan
            })
        },
        actions = {
            TransferItemAction:New({
                item = "minecraft:coal__item.coal__0",
                count = 4,
                destination = "immersiveengineering:woodencrate_1"
            })
        },
        success = {
            FactoryQueueItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.dustCoal__768",
                value = 2
            })
        }
    })
}