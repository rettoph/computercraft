---@class RuleContext
---@field public name string
---@field public enabled boolean
---@field public interval integer
---@field public conditions Condition[]|nil
---@field public actions Action[]
---@field public success Action[]|nil

---@class Rule
---@field private _name string
---@field private _enabled boolean
---@field private _conditions Condition[]|nil
---@field private _actions Action[]
---@field private _success Action[]
---@field private _interval integer
---@field private _timeSinceInvoked integer
---@field private _timeoutRemaining integer
---@field private _timtoutCounter integer
---@field private _logger Logger
local Rule = {}

Rule.__index = Rule

---Rule
---@param context RuleContext
---@return Rule
function Rule:New(context)
    local rule = {}
    setmetatable(rule, self)
    self.__index = self

    rule._name = context.name;
    rule._enabled = context.enabled;
    rule._interval = context.interval;
    rule._conditions = context.conditions or {};
    rule._actions = context.actions;
    rule._success = context.success or {};
    rule._timeSinceInvoked = 0;
    rule._timeoutRemaining = 0;
    rule._timtoutCounter = 0;

    -- Add action specific conditions to internal conditions
    for _,action in pairs(rule._actions) do
        for _,condition in pairs(action:CreateConditions()) do
            rule._conditions[#rule._conditions+1] = condition
        end
    end

	return rule
end

---Initialize rule
---@param logger Logger
function Rule:Initialize(logger)
    self._logger = logger
end

---Run the rule, first checking to ensure all conditions are met then invoking all actions
---@param elapsed number Time in milliseconds since the last time the rule was invoked
---@return integer count The number of times the rule was invoked
function Rule:Run(elapsed)
    if self._enabled == false then
        return 0
    end

    self._timeSinceInvoked = self._timeSinceInvoked + elapsed

    local result = 0
    while self._timeSinceInvoked > self._interval do
        if self:TryInvoke() == true then
            result = result + 1
        end

        self._timeSinceInvoked = self._timeSinceInvoked - self._interval
    end

    return result
end

---Attempt to invoke the the rule a single time if all conditions are met
---@private
---@return boolean success Indicates wether or not the rule was invoked
function Rule:TryInvoke()
    if self._timeoutRemaining > 0 then
        self._timeoutRemaining = self._timeoutRemaining - self._interval
        return false
    end

    if self._timtoutCounter >= 10 then
        self._timtoutCounter = 0
        self:Timeout()
        return false
    end

    if self:CheckConditions() == false then
        self._timtoutCounter = self._timtoutCounter + 1
        self._logger:Debug("Con Fail: '" .. self._name .. "' (" .. self._timtoutCounter .. ")")

        return false
    end

    local success = self:InvokeActions()
    if success == false then
        self._timtoutCounter = self._timtoutCounter + 1
        self._logger:Warning("Invoke Fail: '" .. self._name .. "' (" .. self._timtoutCounter .. ")")

        return false
    end

    self._timtoutCounter = 0
    self._logger:Success("Invoke: '" .. self._name .. "'")
    for _,successAction in pairs(self._success) do
        successAction:Invoke()
    end

    return true
end

---Check if all conditions are met
---@private
---@return boolean result Determins if all conditions are met
function Rule:CheckConditions()
    for _,condition in pairs(self._conditions) do
        if condition:Invoke() == false then
            return false
        end
    end

    return true
end

---Invoke all rule actions
---@private
---@return boolean success Indicates the combined success state of all actions
function Rule:InvokeActions()
    local success = true

    for _,action in pairs(self._actions) do
        success = success and action:Invoke()
    end

    return success
end

function Rule:Timeout()
    self._timeoutRemaining = self._interval * 10
    self._logger:Warning("Timeout '" .. self._name .. "'")
end

return Rule

