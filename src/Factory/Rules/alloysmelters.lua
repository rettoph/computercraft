local Rule = require("/Factory/Rule")

local Condition = require("/Factory/Conditions/Condition")
local CompareItemTotalCondition = require("/Factory/Conditions/CompareItemTotalCondition")
local TransferItemAction = require("/Factory/Actions/TransferItemAction")
local FactoryQueueItemAction = require("/Factory/Actions/FactoryQueueItemAction")

return Rule.Concat(
    Rule.CreateMany(
        {
            {
                name = "Signalum Ingots",
                interval = 60000,
                source = "minecraft:chest_21",
                output_item = "thermalfoundation:material__item.thermalfoundation.material.ingotSignalum__165",
                output_count = 4,
                output_target = 32,
                input_a_item = "thermalfoundation:material__item.thermalfoundation.material.ingotCopper__128",
                input_a_count = 3,
                input_b_item = "thermalfoundation:material__item.thermalfoundation.material.ingotSilver__130",
                input_b_count = 1,
                input_c_item = "minecraft:redstone__item.redstone__0",
                input_c_count = 10
            },
            {
                name = "Lumium Ingots",
                interval = 60000,
                source = "minecraft:chest_22",
                output_item = "thermalfoundation:material__item.thermalfoundation.material.ingotLumium__166",
                output_count = 4,
                output_target = 32,
                input_a_item = "thermalfoundation:material__item.thermalfoundation.material.ingotTin__129",
                input_a_count = 3,
                input_b_item = "thermalfoundation:material__item.thermalfoundation.material.ingotSilver__130",
                input_b_count = 1,
                input_c_item = "minecraft:glowstone_dust__item.yellowDust__0",
                input_c_count = 4
            }
        },
        function(args)
            return Rule:New({
                name = args.name,
                enabled = true,
                interval = args.interval,
                conditions = {
                    CompareItemTotalCondition:New({
                        item = args.output_item,
                        value = args.output_target,
                        comparator = Condition.LessThan
                    })
                },
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
                    }),
                    TransferItemAction:New({
                        destination = args.source,
                        item = args.input_c_item,
                        count = args.input_c_count
                    })
                },
                success = {
                    FactoryQueueItemAction:New({
                        item = args.output_item,
                        value = args.output_count
                    })
                }
            })
        end
    ),
    {
        Rule:New({
            name = "Alloy Smelters to Barrels",
            enabled = true,
            interval = 60000,
            actions = {
                TransferItemAction:New({
                    source = "minecraft:chest_20"
                })
            }
        }),
    }
)