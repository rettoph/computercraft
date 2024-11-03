local Loader = require("/Core/Loader")

---@class RuleManager
---@field private _rules Rule[]
---@field private _sources { [string]: any }
---@field private _logger Logger
local RuleManager = {
    _rules = {},
    _sources = {},
---@diagnostic disable-next-line: undefined-field
    _epoch = os.epoch("utc"),
}

RuleManager.__index = RuleManager

---comment
---@param logger Logger
function RuleManager.Initialize(logger)
    RuleManager._logger = logger
end

function RuleManager.Update()
    RuleManager.Refresh()

    ---@diagnostic disable-next-line: undefined-field
    local epoch = os.epoch("utc")
    local elapsed = epoch - RuleManager._epoch
    RuleManager._epoch = epoch

    for _,rule in pairs(RuleManager._rules) do
        rule:Run(elapsed)
    end
end

function RuleManager.Refresh()
    local dirty = false
    for _,source in pairs(fs.list("/Factory/Rules")) do
        local attributes = fs.attributes("/Factory/Rules/" .. source)

        if RuleManager._sources[source] ~= attributes.modification then
            RuleManager._sources[source] = attributes.modification
            dirty = true
        end
    end

    if dirty == false then
        return
    end

    local rules = {}
    for _,source in pairs(fs.list("/Factory/Rules")) do
        local path = ("/Factory/Rules/" .. source)

        local file = Loader.Require(path) or {}

        local count = 0

        ---@cast file Rule[]
        for _,rule in pairs(file) do
            rules[#rules+1] = rule
            rule:Initialize(RuleManager._logger)
        end

        if #file == 0 then
            RuleManager._logger:Warning("No rules found in: " .. source)
        end
    end

    RuleManager._rules = rules
end

return RuleManager

