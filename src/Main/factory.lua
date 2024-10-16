local Logger = require("/Core/Logger")
local Factory = require("/Factory/Factory")
local InventoryManager = require("/Factory/InventoryManager")

local logger = Logger:New({ Logger.Console:New(Logger.Level.VERBOSE), Logger.File:New(Logger.Level.ERROR) })

InventoryManager.Initialize(logger)


