local ArrayHelper = {}

---Get the index of the element
---@generic T: any
---@param self T[]
---@param item T
---@return number|nil
function ArrayHelper:IndexOf(item)
    for index,value in pairs(self) do
        if value == item then
            return index
        end
    end

    return nil
end

---Add item to list
---@generic T: any
---@param self T[]
---@param item T
function  ArrayHelper:Add(item)
    table.insert(self, item)
    return true
end

---Remove item from list
---@generic T: any
---@param self T[]
---@param item T
---@return boolean
function ArrayHelper:Remove(item)
    local index = ArrayHelper:IndexOf(item)
    if index == nil then
        return false
    end

    table.remove(table, index)
    return true
end

---Clear all elements from list
---@generic T: any
---@param self T[]
function ArrayHelper:Clear()
    repeat
        table.remove(self, 1)
    until self[1] == nil
end

return ArrayHelper