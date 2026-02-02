local ReplicatedStorage = game:GetService("ReplicatedStorage")
local signal = require(ReplicatedStorage.Packages.signal)
local InventoryManager = {}

InventoryManager.ItemsType = {
	Consumable = "Consumable" :: ItemType,
	Equippable = "Equippable" :: ItemType,
	Usable = "Usable" :: ItemType,
}

export type ItemType = "Consumable" | "Equippable" | "Usable"

export type ItemBase = {
	name: string,
	key: string,
	type: ItemType,
	description: string,
	stackable: boolean,
	stackSize: number?,
	canBeDiscarded: boolean,
	icon: string,
}

export type ConsumableItem = ItemBase & {
	type: "Consumable",
}

export type EquippableItem = ItemBase & {
	type: "Equippable",
	tool: Tool,
}

export type UsableItem = ItemBase & {
	type: "Usable",
}

export type Item = ConsumableItem | EquippableItem | UsableItem

local maxSize = 8
local inventory: { Item } = {}
local equippedTool: Tool? = nil

local inventoryChangedSignal = signal.new()

function InventoryManager.addItem(item: Item): boolean
	assert(#inventory <= maxSize, "InventoryManager: Inventory size exceeded max size")

	if #inventory == maxSize then
		return false
	end

	table.insert(inventory, item)
	inventoryChangedSignal:Fire(inventory)
	return true
end

function InventoryManager.getEquippedTool(): Tool?
	return equippedTool
end

function InventoryManager.getItems(): { Item }
	return inventory
end

function InventoryManager.hasSpace(): boolean
	return #inventory < maxSize
end

function InventoryManager.hasItem(item: Item | string): boolean
	for _, v in ipairs(inventory) do
		if typeof(item) == "string" then
			if v.key == item then
				return true
			end
		elseif typeof(item) == "table" then
			if v.key == item.key then
				return true
			end
		end
	end
	return false
end

function InventoryManager.removeItem(item: Item | string): boolean
	for i, v in ipairs(inventory) do
		if typeof(item) == "string" then
			if v.key == item then
				table.remove(inventory, i)
				inventoryChangedSignal:Fire(inventory)
				return true
			end
		elseif typeof(item) == "table" then
			if v.key == item.key then
				table.remove(inventory, i)
				inventoryChangedSignal:Fire(inventory)
				return true
			end
		end
	end
	return false
end

function InventoryManager.getSize(): number
	return #inventory
end

function InventoryManager.getMaxSize(): number
	return maxSize
end

function InventoryManager.clear()
	inventory = {}
	inventoryChangedSignal:Fire(inventory)
end

function InventoryManager.onInventoryChanged(callback: (items: { Item }) -> ())
	return inventoryChangedSignal:Connect(callback)
end

return InventoryManager
