local Rule = require("/Factory/Rule")

local Condition = require("/Factory/Conditions/Condition")
local CompareFluidTotalCondition = require("/Factory/Conditions/CompareFluidTotalCondition")
local CompareItemTotalCondition = require("/Factory/Conditions/CompareItemTotalCondition")
local TransferItemAction = require("/Factory/Actions/TransferItemAction")
local FactoryQueueItemAction = require("/Factory/Actions/FactoryQueueItemAction")

return {
    Rule:New({
        name = "Lapis Electron Tube (Sand)",
        enabled = true,
        interval = 10000,
        conditions = {
            CompareFluidTotalCondition:New({
                source = "forestry:fabricator_0",
                tank = 1,
                fluid = "fluid_fluid.glass",
                value = 2000,
                comparator = Condition.LessThan
            })
        },
        actions = {
            TransferItemAction:New({
                item = "minecraft:sand__tile.sand.default__0",
                count = 1,
                destination = "forestry:fabricator_0",
                destinationSlot = 1
            })
        }
    }),
    Rule:New({
        name = "Lapis Electron Tube",
        enabled = true,
        interval = 10000,
        conditions = {
            CompareItemTotalCondition:New({
                item = "forestry:thermionic_tubes__item.for.thermionic_tubes.lapis__11",
                value = 32,
                comparator = Condition.LessThan
            })
        },
        actions = {
            TransferItemAction:New({
                item = "minecraft:redstone__item.redstone__0",
                count = 4,
                interval = 2,
                destination = "forestry:fabricator_0",
            }),
            TransferItemAction:New({
                item = "minecraft:dye__item.dyePowder.blue__4",
                count = 10,
                interval = 5,
                destination = "forestry:fabricator_0",
            })
        },
        success = {
            FactoryQueueItemAction:New({
                item = "forestry:thermionic_tubes__item.for.thermionic_tubes.lapis__11",
                value = 4
            })
        }
    }),
    Rule:New({
        name = "Lapis Electron Tube to Barrels",
        enabled = true,
        interval = 10000,
        actions = {
            TransferItemAction:New({
                source = "forestry:fabricator_0",
                slot = 3
            })
        }
    }),
}