local Rule = require("/Factory/Rule")

local Condition = require("/Factory/Conditions/Condition")
local CompareItemTotalCondition = require("/Factory/Conditions/CompareItemTotalCondition")
local TransferItemAction = require("/Factory/Actions/TransferItemAction")
local FactoryQueueItemAction = require("/Factory/Actions/FactoryQueueItemAction")

return Rule.CreateMany(
    {
        {
            name = "Hootch",
            interval = 60000,
            source = "minecraft:chest_23",
            input_a_item = "minecraft:potato__item.potato__0",
            input_a_count = 8,
            input_b_item = "minecraft:sugar__item.sugar__0",
            input_b_count = 8
        },
        {
            name = "Rocket Fuel",
            interval = 60000,
            source = "minecraft:chest_24",
            input_a_item = "minecraft:gunpowder__item.sulphur__0",
            input_a_count = 8,
            input_b_item = "minecraft:redstone__item.redstone__0",
            input_b_count = 8
        },
    },
    function(args)
        return Rule:New({
            name = args.name,
            enabled = true,
            interval = args.interval,
            actions = {
                TransferItemAction:New({
                    destination = args.source,
                    item = args.input_a_item,
                    count = args.input_a_count
                }),
                TransferItemAction:New({
                    destination = args.source,
                    item = args.input_b_item,
                    count = args.input_b_count
                })
            }
        })
    end
)