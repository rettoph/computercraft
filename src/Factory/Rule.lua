---@class Rule
---@field private name string
---@field private enabled boolean
---@field private conditions Condition[]|nil
---@field private actions Action[]
---@field private interval number
local Rule = {}

Rule.__index = Rule

---Rule
---@param rule Rule
---@return Rule
function Rule:New(rule)
    setmetatable(rule, self)

    if rule.conditions == nil then
        rule.conditions = {}
    end

    -- Add action specific conditions to internal conditions
    for _,action in pairs(rule.actions) do
        for _,condition in pairs(action:CreateConditions()) do
            rule.conditions[#rule.conditions+1] = condition
        end
    end

	return rule
end

---Run the rule, first checking to ensure all conditions are met then invoking all actions
---@return boolean result
function Rule:Invoke()
    if self:CheckConditions() == false then
        return false
    end

    local success = self:InvokeActions()

    return true
end

---Check if all conditions are met
---@private
---@return boolean result Determins if all conditions are met
function Rule:CheckConditions()
    for _,condition in pairs(self.conditions) do
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

    for _,action in pairs(self.actions) do
        success = success and action:Invoke()
    end

    return success
end

return Rule

