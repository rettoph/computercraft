local Persistence = require("/Core/Persistence")

---@class ItemMetaCache
---@field private _initialized boolean
---@field private _logger Logger
---@field private _cache table
---@field private _dirty boolean
local ItemMetaCache = {
    _initialized = false
}

---@enum
ItemMetaCache.ItemType = {
	DAMAGE_VARIANT = 0,
	DAMAGE_INVARIANT = 1,
	DAMAGE_NBT_VARIANT = 2,
	FLUID = 3
}

---@class ItemMetaCache.ItemMetaData
---@field public id string
---@field public name string
ItemMetaCache.ItemMetaData = {}

---comment
---@param id string
---@param name string|nil
---@return table
function ItemMetaCache.ItemMetaData:New(id, name)
    local o = {
        id = id,
        name = name or "",
    }

    setmetatable(o, self)
	self.__index = self

    return o
end

---Initialize the ItemMetaCache
---@param logger Logger
function ItemMetaCache.Initialize(logger)
    if ItemMetaCache._initialized == true then
        ItemMetaCache._logger:Warning("ItemMetaCache - Already initialized")
        return
    end

    ItemMetaCache._cache = Persistence.Get("items.meta.cache") or {}
    ItemMetaCache._dirty = false
    ItemMetaCache._logger = logger
    ItemMetaCache._initialized = true

    ItemMetaCache._logger:Verbose("ItemMetaCache Initialized")
end

---comment
---@param item table
---@param slot number
---@param module table
---@return ItemMetaCache.ItemMetaData
function ItemMetaCache.GetByItem(item, slot, module)
	local data = ItemMetaCache._cache[item.name]

    ---@type ItemMetaCache.ItemMetaData
    local result = nil

    if data == nil then
		data = {
			type = ItemMetaCache.ItemType.DAMAGE_VARIANT -- Is this a good default type?
		}
		
		ItemMetaCache._cache[item.name] = data
		ItemMetaCache._logger:Info("ItemMetaCache - New Item: " .. item.name)
		ItemMetaCache._dirty = true
	end

    if data.type == ItemMetaCache.ItemType.DAMAGE_VARIANT then
		if data.variant == nil then
			data.variant = {}
			
			ItemMetaCache._dirty = true
		end
		
		result = data.variant[item.damage]
		if result == nil then
			local meta = module.getItemMeta(slot)
			result = ItemMetaCache.ItemMetaData:New(item.name .. "__" .. meta.rawName .. "__" .. item.damage, nil)
			
			if item.nbtHash == nil then
				result.name = meta.displayName
			end
			
			data.variant[item.damage] = result
			ItemMetaCache._logger:Info("ItemMetaCache - New Variant: " .. result.id)
			if item.damage >= 100 then
				ItemMetaCache._logger:Warning("ItemMetaCache - Possible damage invariant: " .. result.id)
			end
			
			ItemMetaCache._dirty = true
		end
	elseif data.type == ItemMetaCache.ItemType.DAMAGE_INVARIANT then
		result = data.data
		if result == nil then
			local meta = module.getItemMeta(slot)
			result = ItemMetaCache.ItemMetaData:New(item.name .. "__" .. meta.rawName, nil)
			
			if item.nbtHash == nil then
				result.name = meta.displayName
			end
			
			data.data = result
			ItemMetaCache._logger:Info("ItemMetaCache - New Data: " .. result.id)			
			ItemMetaCache._dirty = true
		end
	elseif data.type == ItemMetaCache.ItemType.DAMAGE_NBT_VARIANT then
		if data.variant == nil then
			data.variant = {}
			
			ItemMetaCache._dirty = true
		end
		
		local variantId = item.damage .. "__" .. item.nbtHash

		result = data.variant[variantId]
		if result == nil then
			local meta = module.getItemMeta(slot)
			result = ItemMetaCache.ItemMetaData:New(item.name .. "__" .. meta.rawName .. "__" .. item.damage .. "__" .. item.nbtHash,  meta.displayName)
			
			data.variant[variantId] = result
			ItemMetaCache._logger:Info("ItemMetaCache - New Variant: " .. result.id)			
			ItemMetaCache._dirty = true
		end
	end

    if item.nbtHash ~= nil and data.type ~= ItemMetaCache.ItemType.DAMAGE_NBT_VARIANT then
		local nbtResult = {
			id = result.id .. "##" .. item.nbtHash
		}
		
		setmetatable(nbtResult, result)
		
		return nbtResult
	end

    return result
end

---comment
---@param tank table
---@return ItemMetaCache.ItemMetaData
function ItemMetaCache.GetByTank(tank)
	local id = "fluid_" .. tank.rawName --[[@as string]]
	local data = ItemMetaCache._cache[id]

	if data == nil then
		data = {
			type = ItemMetaCache.ItemType.FLUID,
			id = id,
			name = tank.displayName
		}

		ItemMetaCache._cache[id] = data
		ItemMetaCache._dirty = true
		ItemMetaCache._logger:Info("ItemMetaCache - New Fluid: " .. id)
	end

	return data
end

---comment
---@return boolean # Wether or not the state has changed
function ItemMetaCache.Clean()
	if ItemMetaCache._dirty == false then
		return false
	end
	
	ItemMetaCache._logger:Verbose("ItemMetaCache Cleaned.")
	Persistence.Set("items.meta.cache", ItemMetaCache._cache)
	ItemMetaCache._dirty = false
	return true
end

return ItemMetaCache