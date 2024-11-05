local Rule = require("/Factory/Rule")

local Condition = require("/Factory/Conditions/Condition")
local CompareFactoryItemTotalCondition = require("/Factory/Conditions/CompareFactoryItemTotalCondition")
local TransferItemAction = require("/Factory/Actions/TransferItemAction")
local FactoryQueueItemAction = require("/Factory/Actions/FactoryQueueItemAction")

return Rule.Concat(
    {
        Rule:New({
            name = "Signalum Nuggets",
            enabled = true,
            interval = 10000,
            conditions = {
                CompareFactoryItemTotalCondition:New({
                    item = "thermalfoundation:material__item.thermalfoundation.material.nuggetSignalum__229",
                    value = 64,
                    comparator = Condition.LessThan
                })
            },
            actions = {
                TransferItemAction:New({
                    item = "thermalfoundation:material__item.thermalfoundation.material.ingotSignalum__165",
                    count = 2,
                    interval = 1,
                    destination = "buildcraftfactory:autoworkbench_item_2"
                })
            },
            success = {
                FactoryQueueItemAction:New({
                    item = "thermalfoundation:material__item.thermalfoundation.material.nuggetSignalum__229",
                    value = 9
                })
            }
        }),
        Rule:New({
            name = "Basic Capacitor",
            enabled = true,
            interval = 10000,
            conditions = {
                CompareFactoryItemTotalCondition:New({
                    item = "enderio:item_basic_capacitor__item.item_basic_capacitor.basic__0",
                    value = 32,
                    comparator = Condition.LessThan
                })
            },
            actions = {
                TransferItemAction:New({
                    item = "thermalfoundation:material__item.thermalfoundation.material.nuggetSignalum__229",
                    count = 8,
                    interval = 4,
                    destination = "buildcraftfactory:autoworkbench_item_3"
                }),
                TransferItemAction:New({
                    item = "buildcraftsilicon:redstone_chipset__item.redstone_red_chipset__0",
                    count = 4,
                    interval = 2,
                    destination = "buildcraftfactory:autoworkbench_item_3"
                }),
                TransferItemAction:New({
                    item = "forestry:thermionic_tubes__item.for.thermionic_tubes.lapis__11",
                    count = 2,
                    interval = 1,
                    destination = "buildcraftfactory:autoworkbench_item_3"
                })
            },
            success = {
                FactoryQueueItemAction:New({
                    item = "enderio:item_basic_capacitor__item.item_basic_capacitor.basic__0",
                    value = 1
                })
            }
        }),
        Rule:New({
            name = "Electronic Circuit",
            enabled = true,
            interval = 10000,
            conditions = {
                CompareFactoryItemTotalCondition:New({
                    item = "ic2:crafting__ic2.crafting.circuit__1",
                    value = 8,
                    comparator = Condition.LessThan
                })
            },
            actions = {
                TransferItemAction:New({
                    item = "ic2:cable__ic2.cable.copper_cable_1__0__292242a9dd836ce8a320a5caa9c7bfba",
                    count = 12,
                    interval = 6,
                    destination = "buildcraftfactory:autoworkbench_item_4"
                }),
                TransferItemAction:New({
                    item = "thermalfoundation:material__item.thermalfoundation.material.plateIron__32",
                    count = 2,
                    interval = 1,
                    destination = "buildcraftfactory:autoworkbench_item_4"
                }),
                TransferItemAction:New({
                    item = "minecraft:redstone__item.redstone__0",
                    count = 4,
                    interval = 2,
                    destination = "buildcraftfactory:autoworkbench_item_4"
                })
            },
            success = {
                FactoryQueueItemAction:New({
                    item = "ic2:crafting__ic2.crafting.circuit__1",
                    value = 1
                })
            }
        }),
        Rule:New({
            name = "Insulated Copper Cable",
            enabled = true,
            interval = 10000,
            conditions = {
                CompareFactoryItemTotalCondition:New({
                    item = "ic2:cable__ic2.cable.copper_cable_1__0__292242a9dd836ce8a320a5caa9c7bfba",
                    value = 32,
                    comparator = Condition.LessThan
                })
            },
            actions = {
                TransferItemAction:New({
                    item = "ic2:cable__ic2.cable.copper_cable_0__0__6bb68012b7e2124aff32a619bef741de",
                    count = 2,
                    interval = 1,
                    destination = "buildcraftfactory:autoworkbench_item_5"
                }),
                TransferItemAction:New({
                    item = "ic2:crafting__ic2.crafting.rubber__0",
                    count = 2,
                    interval = 1,
                    destination = "buildcraftfactory:autoworkbench_item_5"
                })
            },
            success = {
                FactoryQueueItemAction:New({
                    item = "ic2:cable__ic2.cable.copper_cable_1__0__292242a9dd836ce8a320a5caa9c7bfba",
                    value = 1
                })
            }
        })
    },
    Rule.CreateMany(
        { 
            "buildcraftfactory:autoworkbench_item_2", 
            "buildcraftfactory:autoworkbench_item_3" ,
            "buildcraftfactory:autoworkbench_item_4",
            "buildcraftfactory:autoworkbench_item_5"
        }, 
        function(name)
            return Rule:New({
                name = name .. " to Storage",
                enabled = true,
                interval = 30000,
                actions = {
                    TransferItemAction:New({
                        source = name,
                        sourceSlot = 10
                    } )
                }
            })
        end
    )
)