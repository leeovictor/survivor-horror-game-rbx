local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local InventoryManager = require(script.Parent.Parent.InventoryManager)

local InventoryController = {}

local screen: any
local originalBlurSize: number = Lighting.Blur.Size

function InventoryController.init()
	screen = Players.LocalPlayer.PlayerGui:WaitForChild("InventoryScreen")
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

local function clearSlots()
	local itemsFrame = screen.Items :: Frame
	for _, slot in ipairs(itemsFrame:GetChildren()) do
		if slot:IsA("Frame") and slot.Name ~= "ItemSlotTemplate" then
			slot:Destroy()
		end
	end
end

local function renderItems()
	clearSlots()

	local items = InventoryManager.getItems()
	local itemsFrame = screen.Items :: Frame
	local itemSlotTemplate = itemsFrame.ItemSlotTemplate :: Frame

	for index = 1, InventoryManager.getMaxSize() do
		local item = items[index]

		local itemSlot = itemSlotTemplate:Clone()
		itemSlot.Name = "ItemSlot" .. tostring(index)
		itemSlot.Visible = true

		local icon = itemSlot.Icon :: ImageLabel
		local itemName = itemSlot.ItemName :: TextLabel
		local stackSize = itemSlot.StackSize :: TextLabel

		if not item then
			icon.Visible = false
			itemName.Visible = false
			stackSize.Visible = false
			itemSlot.Parent = itemsFrame
			continue
		end

		icon.Image = ""
		itemName.Text = item.name

		if item.stackable and item.stackSize and item.stackSize > 1 then
			stackSize.Text = tostring(item.stackSize)
			stackSize.Visible = true
		else
			stackSize.Visible = false
		end

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
end

function InventoryController.isOpen(): boolean
	return screen.Enabled
end

return InventoryController
