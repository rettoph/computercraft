---@class Program
---@field private _running boolean
local Program = {
    _running = false
}

---Run a program
---@param method fun()
function Program.Run(method, logger)
    Program._running = true

    while Program._running do
        local success, result = xpcall(method, Program.ErrorHandler)
    
        if success == false then
            logger:Error(result --[[@as string]])
        end
    end
end

---comment
---@private
---@param err any
---@return any
function Program.ErrorHandler(err)
    if err == "Terminated" then
        Program._running = false
        return err
    end

    return debug.traceback(err)
end

return Program