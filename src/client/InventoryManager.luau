local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local signal = require(ReplicatedStorage.Packages.signal)
local ItemsData = require(ReplicatedStorage.Shared.ItemsData)
local InventoryManager = {}

local maxSize = 8
local inventory: { ItemsData.Item } = {
	{
		name = "Handgun",
		key = "handgun_001",
		type = ItemsData.ItemsType.Equippable,
		description = "A standard issue handgun.",
		stackable = false,
		canBeDiscarded = true,
		icon = "rbxassetid://1234567890",
		tool = ReplicatedStorage.Tools.Handgun :: Tool,
	},
}
local equippedTool: Tool? = nil

local inventoryChangedSignal = signal.new()

function InventoryManager.addItem(item: ItemsData.Item): boolean
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

function InventoryManager.equipItem(item: ItemsData.EquippableItem)
	equippedTool = item.tool

	local humanoid: Humanoid = Players.LocalPlayer.Character
		and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	item.tool.Parent = Players.LocalPlayer.Backpack

	humanoid:UnequipTools()
	humanoid:EquipTool(item.tool)
end

function InventoryManager.getItems(): { ItemsData.Item }
	return inventory
end

function InventoryManager.hasSpace(): boolean
	return #inventory < maxSize
end

function InventoryManager.hasItem(item: ItemsData.Item | string): boolean
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

function InventoryManager.removeItem(item: ItemsData.Item | string): boolean
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

function InventoryManager.onInventoryChanged(callback: (items: { ItemsData.Item }) -> ())
	return inventoryChangedSignal:Connect(callback)
end

return InventoryManager
