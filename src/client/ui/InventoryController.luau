local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local InventoryManager = require(script.Parent.Parent.InventoryManager)

local InventoryController = {}

local screen: any

-- TODO: mover isso para outro lugar?
local originalBlurSize: number = Lighting.Blur.Size

local slotsCon = {}

function InventoryController.init()
	screen = Players.LocalPlayer.PlayerGui:WaitForChild("InventoryScreen")

	-- init slot list
	local slotTemplate = screen.Items.ItemSlotTemplate :: Frame
	for i = 1, InventoryManager.getMaxSize() do
		local slot = slotTemplate:Clone()
		slot.Name = "ItemSlot" .. tostring(i)
		slot.Visible = true
		slot.LayoutOrder = i
		slot.Parent = screen.Items

		slot.Icon.Visible = false
		slot.ItemName.Visible = false
		slot.StackSize.Visible = false

		slotsCon[slot.Name] = nil
	end
end

local function updateHealthState()
	local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	local healthState = screen.HealthState :: Frame
	local textLabel = screen.HealthState.TextLabel :: TextLabel
	textLabel.BackgroundTransparency = 1

	local healthPercent = humanoid.Health / humanoid.MaxHealth

	if healthPercent > 0.7 then
		healthState.BackgroundColor3 = Color3.fromRGB(52, 145, 52)
		textLabel.TextColor3 = Color3.fromRGB(3, 43, 3)
		textLabel.Text = "Healthy"
	elseif healthPercent > 0.3 then
		healthState.BackgroundColor3 = Color3.fromRGB(190, 190, 63)
		textLabel.TextColor3 = Color3.fromRGB(68, 68, 5)
		textLabel.Text = "Injured"
	else
		healthState.BackgroundColor3 = Color3.fromRGB(192, 63, 63)
		textLabel.TextColor3 = Color3.fromRGB(80, 7, 7)
		textLabel.Text = "Danger"
	end
end

local function renderItems()
	local items = InventoryManager.getItems()
	local itemsFrame = screen.Items :: Frame

	for index = 1, InventoryManager.getMaxSize() do
		local item = items[index]

		local itemSlot = itemsFrame:FindFirstChild("ItemSlot" .. tostring(index)) :: Frame
		assert(itemSlot, "Slot not found. Check the slot initializtion")

		local icon = itemSlot.Icon :: ImageButton
		local itemName = itemSlot.ItemName :: TextLabel
		local stackSize = itemSlot.StackSize :: TextLabel

		if item == nil then
			icon.Visible = false
			itemName.Visible = false
			stackSize.Visible = false
			continue
		else
			icon.Visible = true
			itemName.Visible = true
			stackSize.Visible = true
		end

		icon.Image = item.icon
		itemName.Text = item.name

		if item.stackable then
			stackSize.Text = tostring(item.stackSize)
			stackSize.Visible = true
		else
			stackSize.Visible = false
		end

		local function toogleItemActions()
			local actionsFrame = screen.ItemActions :: Frame
			if actionsFrame.Visible then
				actionsFrame.Visible = false
				return
			end

			actionsFrame.Visible = true

			if item.type == InventoryManager.ItemsType.Usable or item.type == InventoryManager.ItemsType.Consumable then
				local actions = { "Use", "Examine" }
				local itemActionTemplate = actionsFrame.ActionItem :: TextButton

				for _, child in ipairs(actionsFrame:GetChildren()) do
					if child:IsA("TextButton") and child.Name ~= "ActionItem" then
						child:Destroy()
					end
				end

				for i, action in ipairs(actions) do
					local actionItem = itemActionTemplate:Clone()
					actionItem.Name = action
					actionItem.Text = action
					actionItem.Visible = true
					actionItem.Parent = actionsFrame
					actionItem.LayoutOrder = i
				end

				itemActionTemplate.Visible = false
			elseif item.type == InventoryManager.ItemsType.Equippable then
				local actions = { "Equip", "Examine" }
				local itemActionTemplate = actionsFrame.ActionItem :: TextButton

				for _, child in ipairs(actionsFrame:GetChildren()) do
					if child:IsA("TextButton") and child.Name ~= "ActionItem" then
						child:Destroy()
					end
				end

				for i, action in ipairs(actions) do
					local actionItem = itemActionTemplate:Clone()
					actionItem.Name = action
					actionItem.Text = action
					actionItem.Visible = true
					actionItem.Parent = actionsFrame
					actionItem.LayoutOrder = i
				end

				itemActionTemplate.Visible = false
			end
		end

		if slotsCon[itemSlot.Name] then
			slotsCon[itemSlot.Name]:Disconnect()
		end
		slotsCon[itemSlot.Name] = icon.MouseButton1Click:Connect(toogleItemActions)

		itemSlot.Parent = itemsFrame
	end
end

function InventoryController.open()
	screen.Enabled = true
	local blur = Lighting.Blur :: BlurEffect
	originalBlurSize = blur.Size
	blur.Size = 15

	updateHealthState()
	renderItems()
end

function InventoryController.close()
	local blur = Lighting.Blur :: BlurEffect
	blur.Size = originalBlurSize
	screen.Enabled = false
	local actionsFrame = screen.ItemActions :: Frame
	actionsFrame.Visible = false
end

function InventoryController.isOpen(): boolean
	return screen.Enabled
end

return InventoryController
