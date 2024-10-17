
---@class Logger
---@field private _sinks Logger.Sink[]
local Logger = {}

---@enum Logger.Level
Logger.Level = {
	ERROR = 0,
	WARNING = 1,
	SUCCESS = 2,
	INFO = 3,
    INFORMATION = 3,
	DEBUG = 4,
	VERBOSE = 5
}

---comment
---@param sinks Logger.Sink[]
---@return Logger
function Logger:New(sinks)
	local o = {
		_sinks = sinks or {}
	}

    setmetatable(o, self)
	self.__index = self

	return o;
end

---comment
---@param message string
---@param level Logger.Level
function Logger:Write(message, level)
    for _, sink in pairs(self._sinks) do
        sink:Write(message, level)
    end
end

---comment
---@param message string
function Logger:Error(message)
    self:Write(message, Logger.Level.ERROR)
end

---comment
---@param message string
function Logger:Warning(message)
    self:Write(message, Logger.Level.WARNING)
end

---comment
---@param message string
function Logger:Info(message)
    self:Write(message, Logger.Level.INFO)
end

---comment
---@param message string
function Logger:Information(message)
    self:Write(message, Logger.Level.INFORMATION)
end

---comment
---@param message string
function Logger:Success(message)
    self:Write(message, Logger.Level.SUCCESS)
end

---comment
---@param message string
function Logger:Debug(message)
    self:Write(message, Logger.Level.DEBUG)
end

---comment
---@param message string
function Logger:Verbose(message)
    self:Write(message, Logger.Level.VERBOSE)
end

---@class Logger.Sink
Logger.Sink = {}

---comment
---@param message string
---@param level Logger.Level
function Logger.Sink:Write(message, level)
    error("Abstract - Logger.Sink:Write")
end

---@class Logger.Console: Logger.Sink
Logger.Console = Logger.Sink

---comment
---@param level Logger.Level
---@return Logger.Console
function Logger.Console:New(level)
	local o = {
		level = level or Logger.Level.INFO
	}

    setmetatable(o, self)
	self.__index = self

	return o
end

---comment
---@param message string
---@param level Logger.Level
function Logger.Console:Write(message, level)
    if level <= self.level then
        term.setTextColor(Logger.Console.GetColor(level))
        print(Logger.Console.GetPrefix(level) .. message)
    end
end

---comment
---@param level Logger.Level
---@private
function Logger.Console.GetColor(level)
    if level == Logger.Level.ERROR then
        return colors.red
    elseif level == Logger.Level.WARNING then
        return colors.orange
    elseif level == Logger.Level.SUCCESS then
        return colors.green
    elseif level == Logger.Level.INFO then
        return colors.white
    elseif level == Logger.Level.DEBUG then
        return colors.cyan
    elseif level == Logger.Level.VERBOSE then
        return colors.purple
    end

    return nil
end

---comment
---@param level Logger.Level
---@return string
---@private
function Logger.Console.GetPrefix(level)
    if level == Logger.Level.ERROR then
        return "E "
    elseif level == Logger.Level.WARNING then
        return "W "
    elseif level == Logger.Level.SUCCESS then
        return "S "
    elseif level == Logger.Level.INFO then
        return "I "
    elseif level == Logger.Level.DEBUG then
        return "D "
    elseif level == Logger.Level.VERBOSE then
        return "V "
    end

    return "? "
end

---@class Logger.File: Logger.Sink
Logger.File = {}

---comment
---@param level Logger.Level
---@param name string|nil
---@return Logger.File
function Logger.File:New(level, name)
	local o = {
		level = level or Logger.Level.INFO,
		name = Logger.File.GetLogPath(name or ("log_" .. os.date("%Y-%m-%d") .. ".txt"))
	}

    setmetatable(o, self)
	self.__index = self

	if fs.exists(o.name) == true then
		o.handle = fs.open(o.name, "a")
	else
		o.handle = fs.open(o.name, "w")
	end

	return o
end

---comment
---@param message string
---@param level Logger.Level
function Logger.File:Write(message, level)
    if level <= self.level then
        message = "["..os.date("%H:%M:%S").."]" .. Logger.File.GetPrefix(level) .. message

        self.handle.writeLine(message)
        self.handle.flush()
    end
end

---comment
---@param name string
---@return string
---@private
function Logger.File.GetLogPath(name)

    local path = "/logs/"

    -- if fs.exists("disk") then
    -- 	path = "/disk" .. path
    -- end

    if not fs.exists(path) then
        fs.makeDir(path)
    end

    if name ~= nil then
        path = path .. name
    end

    return path
end

---comment
---@param level Logger.Level
---@return string
---@private
function Logger.File.GetPrefix(level)
    if level == Logger.Level.ERROR then
        return "[Error] "
    elseif level == Logger.Level.WARNING then
        return "[Warning] "
    elseif level == Logger.Level.SUCCESS then
        return "[Success] "
    elseif level == Logger.Level.INFO then
        return "[Info] "
    elseif level == Logger.Level.DEBUG then
        return "[Debug] "
    elseif level == Logger.Level.VERBOSE then
        return "[Verbose] "
    end

    return "[?????] "
end

return Logger