local Rule = require("/Factory/Rule")

local CompareFactoryItemTotalCondition = require("/Factory/Conditions/CompareFactoryItemTotalCondition")
local TransferItemAction = require("/Factory/Actions/TransferItemAction")

return {
    Rule:New({
        name = "Pulverizers to Barrels",
        enabled = true,
        interval = 60000,
        actions = {
            TransferItemAction:New({
                source = "immersiveengineering:woodencrate_0",
            })
        }
    })
}