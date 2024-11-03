local Logger = require("/Core/Logger")

rednet.open("back")

local logger = Logger:New({ 
    Logger.Console:New(Logger.Level.DEBUG), 
    Logger.File:New(Logger.Level.INFO)
})

function InputCommand()
    local input = read()
end

function RednetRecieve()
    local id, message = rednet.receive("log")
    logger:Write(message.message, message.level)
end

while true do
    parallel.waitForAny(RednetRecieve)
end