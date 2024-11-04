local Rule = require("/Factory/Rule")

local Condition = require("/Factory/Conditions/Condition")
local CompareFactoryItemTotalCondition = require("/Factory/Conditions/CompareFactoryItemTotalCondition")
local TransferItemAction = require("/Factory/Actions/TransferItemAction")
local FactoryQueueItemAction = require("/Factory/Actions/FactoryQueueItemAction")
return {
    Rule:New({
        name = "Plates to Barrels",
        enabled = true,
        interval = 60000,
        actions = {
            TransferItemAction:New({
                source = "minecraft:chest_17",
            })
        }
    }),
    Rule:New({
        name = "Bronze Plates",
        enabled = true,
        interval = 4000,
        conditions = {
            CompareFactoryItemTotalCondition:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.plateBronze__355",
                value = 64,
                comparator = Condition.LessThan
            })
        },
        actions = {
            TransferItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.ingotBronze__163",
                count = 1,
                destination = "minecraft:hopper_2"
            })
        },
        success = {
            FactoryQueueItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.plateBronze__355",
                value = 1
            })
        }
    }),
    Rule:New({
        name = "Iron Plates",
        enabled = true,
        interval = 4000,
        conditions = {
            CompareFactoryItemTotalCondition:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.plateIron__32",
                value = 64,
                comparator = Condition.LessThan
            })
        },
        actions = {
            TransferItemAction:New({
                item = "minecraft:iron_ingot__item.ingotIron__0",
                count = 1,
                destination = "minecraft:hopper_2"
            })
        },
        success = {
            FactoryQueueItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.plateIron__32",
                value = 1
            })
        }
    }),
    Rule:New({
        name = "Gold Plates",
        enabled = true,
        interval = 4000,
        conditions = {
            CompareFactoryItemTotalCondition:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.plateGold__33",
                value = 64,
                comparator = Condition.LessThan
            })
        },
        actions = {
            TransferItemAction:New({
                item = "minecraft:gold_ingot__item.ingotGold__0",
                count = 1,
                destination = "minecraft:hopper_2"
            })
        },
        success = {
            FactoryQueueItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.plateGold__33",
                value = 1
            })
        }
    }),
    Rule:New({
        name = "Steel Plates",
        enabled = true,
        interval = 4000,
        conditions = {
            CompareFactoryItemTotalCondition:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.plateSteel__352",
                value = 64,
                comparator = Condition.LessThan
            })
        },
        actions = {
            TransferItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.ingotSteel__160",
                count = 1,
                destination = "minecraft:hopper_2"
            })
        },
        success = {
            FactoryQueueItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.plateSteel__352",
                value = 1
            })
        }
    }),
    Rule:New({
        name = "Copper Plates",
        enabled = true,
        interval = 4000,
        conditions = {
            CompareFactoryItemTotalCondition:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.plateCopper__320",
                value = 32,
                comparator = Condition.LessThan
            })
        },
        actions = {
            TransferItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.ingotCopper__128",
                count = 1,
                destination = "minecraft:hopper_2"
            })
        },
        success = {
            FactoryQueueItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.plateCopper__320",
                value = 1
            })
        }
    }),
    Rule:New({
        name = "Tin Plates",
        enabled = true,
        interval = 4000,
        conditions = {
            CompareFactoryItemTotalCondition:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.plateTin__321",
                value = 32,
                comparator = Condition.LessThan
            })
        },
        actions = {
            TransferItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.ingotTin__129",
                count = 1,
                destination = "minecraft:hopper_2"
            })
        },
        success = {
            FactoryQueueItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.plateTin__321",
                value = 1
            })
        }
    }),
    Rule:New({
        name = "Lead Plates",
        enabled = true,
        interval = 4000,
        conditions = {
            CompareFactoryItemTotalCondition:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.plateLead__323",
                value = 32,
                comparator = Condition.LessThan
            })
        },
        actions = {
            TransferItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.ingotLead__131",
                count = 1,
                destination = "minecraft:hopper_2"
            })
        },
        success = {
            FactoryQueueItemAction:New({
                item = "thermalfoundation:material__item.thermalfoundation.material.plateLead__323",
                value = 1
            })
        }
    })
}