---@class Persistence
local Persistence = {}

---Get persistent data
---@param key string # Persistent data key
---@return any|nil
Persistence.Get = function(key)
	local path = Persistence.GetFilePath(key)

	if fs.exists(path) == false then
		return nil
	end

	local f = fs.open(path, 'r')
	local content = f.readAll()
	f.close()

	local value = textutils.unserialise(content)
	return value
end

---Set persistent data
---@param key string
---@param value any
Persistence.Set = function(key, value)
    local f = fs.open(Persistence.GetFilePath(key), 'w')
    f.write(textutils.serialise(value))
    f.close()
end

---Get the file path for the given persistence key 
---@param key string
---@return string # A file path to store persistent data
---@private
function Persistence.GetFilePath(key)
	local path = "/.persistence/"

	if fs.exists("disk") then
		path = "/disk" .. path
	end

    if fs.exists(path) == false then
        fs.makeDir(path)
    end

	if key ~= nil then
		path = path .. key
	end

	return path
end

return Persistence