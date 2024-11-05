local Rule = require("/Factory/Rule")

local Condition = require("/Factory/Conditions/Condition")
local CompareFactoryItemTotalCondition = require("/Factory/Conditions/CompareFactoryItemTotalCondition")
local TransferItemAction = require("/Factory/Actions/TransferItemAction")
local FactoryQueueItemAction = require("/Factory/Actions/FactoryQueueItemAction")

return Rule.Concat(
    {
        Rule:New({
            name = "Red Chipsets",
            enabled = true,
            interval = 2000,
            conditions = {
                CompareFactoryItemTotalCondition:New({
                    item = "buildcraftsilicon:redstone_chipset__item.redstone_red_chipset__0",
                    value = 64,
                    comparator = Condition.LessThan
                })
            },
            actions = {
                TransferItemAction:New({
                    item = "minecraft:redstone__item.redstone__0",
                    count = 2,
                    interval = 1,
                    destination = "buildcraftsilicon:assembly_table_0"
                })
            },
            success = {
                FactoryQueueItemAction:New({
                    item = "buildcraftsilicon:redstone_chipset__item.redstone_red_chipset__0",
                    value = 1
                })
            }
        })
    },
    Rule.CreateMany(
        {
            "minecraft:chest_18"
        },
        function(name)
            return Rule:New({
                name = name .. " to Storage",
                enabled = true,
                interval = 60000,
                actions = {
                    TransferItemAction:New({
                        source = name
                    })
                }
            })
        end
    )
)