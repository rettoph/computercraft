local Rule = require("/Factory/Rule")

local Condition = require("/Factory/Conditions/Condition")
local CompareItemTotalCondition = require("/Factory/Conditions/CompareItemTotalCondition")
local TransferItemAction = require("/Factory/Actions/TransferItemAction")
local FactoryQueueItemAction = require("/Factory/Actions/FactoryQueueItemAction")

return {
    Rule:New({
        name = "Copper Cables",
        enabled = true,
        interval = 10000,
        conditions = {
            CompareItemTotalCondition:New({
                item = "ic2:cable__ic2.cable.copper_cable_0__0__6bb68012b7e2124aff32a619bef741de",
                value = 32,
                comparator = Condition.LessThan
            })
        },
        actions = {
            TransferItemAction:New({
                destination = "ic2:metal_former_0",
                item = "thermalfoundation:material__item.thermalfoundation.material.ingotCopper__128",
                count = 2,
                interval = 1
            })
        },
        success = {
            FactoryQueueItemAction:New({
                item = "ic2:cable__ic2.cable.copper_cable_0__0__6bb68012b7e2124aff32a619bef741de",
                value = 3
            })
        }
    }),
    Rule:New({
        name = "Metal Former to Barrels",
        enabled = true,
        interval = 30000,
        actions = {
            TransferItemAction:New({
                source = "ic2:metal_former_0",
                sourceSlot = 2
            })
        }
    }),
}