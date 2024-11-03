local Loader = {}

---comment
---@param logger Logger
function Loader.Initialize(logger)
    Loader._logger = logger
end

---comment
---@param filename string
---@return any
function Loader.Require(filename)
    local success, result = xpcall(function() return Loader.EvalFile(filename) end, Loader.ErrorHandler)

    --print(string.format("success=%s filename=%s\n", success, filename))
    if not success then
        Loader._logger:Error(result --[[@as string]])
        return nil
    end

    return result
end

---comment
---@private
---@param filename string
---@return any
function Loader.EvalFile(filename)
    local env = setmetatable({
        require = require
    }, {__index = _G})
    
    local f = assert(loadfile(filename, "t", env))
    return f()
end

---comment
---@private
---@param err any
---@return string
function Loader.ErrorHandler(err)
    return debug.traceback(err)
end

---comment
---@param text string
---@return any
function Loader.Eval(text)
    local f = assert(Loader(text))
    return f()
end

return Loader