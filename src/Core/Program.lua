---@class Program
---@field private _running boolean
local Program = {
    _running = false
}

---Run a program
---@param method fun()
---@param logger Logger
function Program.Run(method, logger)
    Program._running = true

    while Program._running do
        local success, result = xpcall(method, Program.ErrorHandler)
    
        if success == false then
            logger:Error(result --[[@as string]])

            for i=10,1,-1 do
                logger:Debug("Continue in " .. i .. "...")
 ---@diagnostic disable-next-line: undefined-field
 os.sleep(1)               
            end
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

    --return debug.traceback(err)
    return err
end

return Program