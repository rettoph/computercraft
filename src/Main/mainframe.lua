local Program = require("/Core/Program")
local Logger = require("/Core/Logger")
local Loader = require("/Core/Loader")
local Factory = require("/Factory/Factory")
local InventoryManager = require("/Factory/InventoryManager")
local RuleManager = require("/Factory/RuleManager")

rednet.open("top")

local logger = Logger:New({ 
    Logger.Console:New(Logger.Level.VERBOSE), 
    Logger.Rednet:New(Logger.Level.VERBOSE) 
})

Loader.Initialize(logger)
InventoryManager.Initialize(logger)
Factory.Initialize(logger, InventoryManager.GetByName("yabba:item_barrel_connector_1"))
RuleManager.Initialize(logger)

Program.Run(function()
    while true do
        RuleManager.Update()
    
---@diagnostic disable-next-line: undefined-field
        os.sleep(1)
    end
end, logger)

