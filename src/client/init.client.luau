local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local FixedCameraSystem = require(script.FixedCameraSystem)
local MovementSystem = require(script.MovementSystem)
local Promise = require(ReplicatedStorage.Packages.promise)
-- local Gizmos = require(ReplicatedStorage.Shared.Gizmos)

MovementSystem.setup()
FixedCameraSystem.setup()

local screenGui = Players.LocalPlayer.PlayerGui:WaitForChild("BottomMessageScreen")
local BlackScreen = Players.LocalPlayer.PlayerGui:WaitForChild("BlackScreen")

local textSpeed = 0.008

export type TaggedText = {
	tag: string,
	attributes: { [string]: string },
	content: string,
}
export type TextInput = string | { string | TaggedText }

local function showTypedText(text: TextInput, textLabel: TextLabel)
	return Promise.new(function(resolve)
		MovementSystem.setEnabled(false)

		local function typeRawText(t: string)
			local letters = string.split(t, "")

			for _, letter in ipairs(letters) do
				textLabel.Text = textLabel.Text .. letter
				task.wait(textSpeed)
			end
		end

		local thread = task.spawn(function()
			textLabel.Text = ""

			if typeof(text) == "string" then
				typeRawText(text)
				return
			end

			for _, t: string | TaggedText in ipairs(text) do
				if typeof(t) == "string" then
					typeRawText(t)
				else
					-- TaggedText
					local attributes = ""
					for attrName, attrValue in pairs(t.attributes) do
						attributes ..= " " .. attrName .. '="' .. attrValue .. '"'
					end
					local tagOpen = "<" .. t.tag .. attributes .. ">"
					local tagClose = "</" .. t.tag .. ">"

					local letters = string.split(t.content, "")

					local contentAcc = ""
					local textLabelBeforeTag = textLabel.Text

					for _, letter in ipairs(letters) do
						contentAcc ..= letter
						textLabel.Text = textLabelBeforeTag .. tagOpen .. contentAcc .. tagClose
						task.wait(textSpeed)
					end

					textLabel.Text = textLabelBeforeTag .. tagOpen .. t.content .. tagClose
				end
			end
		end)

		local function buildTag(t: TaggedText)
			local attributes = ""
			for attrName, attrValue in pairs(t.attributes) do
				attributes ..= " " .. attrName .. '="' .. attrValue .. '"'
			end
			local tagOpen = "<" .. t.tag .. attributes .. ">"
			local tagClose = "</" .. t.tag .. ">"

			return tagOpen .. t.content .. tagClose
		end

		local function buildRawText(input: TextInput): string
			if typeof(input) == "string" then
				return input
			end

			local acc = ""
			for _, t: string | TaggedText in ipairs(input) do
				if typeof(t) == "string" then
					acc ..= t
				else
					acc ..= buildTag(t)
				end
			end
			return acc
		end

		ContextActionService:BindAction("interaction:wait", function(_, inputState: Enum.UserInputState)
			if inputState == Enum.UserInputState.Begin then
				local status = coroutine.status(thread)
				if status ~= "dead" then
					coroutine.close(thread)
					textLabel.Text = buildRawText(text)
				else
					textLabel.Text = ""
					MovementSystem.setEnabled(true)
					ContextActionService:UnbindAction("interaction:wait")
					resolve()
				end
			end
		end, false, Enum.UserInputType.MouseButton1)
	end)
end

local function getInteractableBox(character: Model)
	if character == nil then
		return nil
	end

	local cf = character:GetPivot()
	local hmr = character.PrimaryPart
	return cf * CFrame.new(0, 0, -2), hmr.Size + Vector3.new(0, 8, 3)
end

local DoorsData = {
	["door1"] = {
		locked = false,
	},
	["door2"] = {
		locked = true,
		keyItem = "sword-key",
		messages = {
			locked = {
				"It's locked. There's a ",
				{ tag = "font", attributes = { color = "rgb(0,255,0)" }, content = "sword figure" } :: TaggedText,
				" engraved on the lock.",
			} :: TextInput,
			unlocked = "Door unlocked.",
		},
	},
}

local inventory = {}

local function doorTravelSequence(doorPart: Part)
	ContextActionService:BindAction("interaction:wait", function() end, false, Enum.UserInputType.MouseButton1)
	local duration = 0.2 * 2 + 0.5 -- ful time of the door sequence

	local sound = doorPart:FindFirstChild("DoorOpen") :: Sound
	sound.PlaybackSpeed = sound.TimeLength / duration
	sound.Volume = 2
	sound:Play()

	-- door teleport sequence
	local fadeSpeed = 0.2
	MovementSystem.setEnabled(false)
	local frame: Frame = BlackScreen.Frame
	frame.Visible = true
	frame.BackgroundTransparency = 1
	local fadeOut = TweenService:Create(frame, TweenInfo.new(fadeSpeed), { BackgroundTransparency = 0 })
	fadeOut:Play()
	fadeOut.Completed:Wait()

	task.wait(0.5)

	-- teleport player
	local character = Players.LocalPlayer.Character
	local hmr: Part = character and character:FindFirstChild("HumanoidRootPart")

	if hmr and doorPart then
		-- Get door's forward direction
		local doorCFrame = doorPart.CFrame
		local doorForward = doorCFrame.LookVector

		-- Get vector from door to player
		local doorToPlayer = (hmr.Position - doorPart.Position).Unit

		-- Determine if player is in front or back using dot product
		local dotProduct = doorForward:Dot(doorToPlayer)

		-- Get teleport destination
		local teleportOffset = 2 -- distance from door
		local targetCFrame

		if dotProduct > 0 then
			-- Player is in front, teleport to back (facing away from door)
			targetCFrame = doorCFrame * CFrame.new(0, 0, teleportOffset) * CFrame.Angles(0, math.pi, 0)
		else
			-- Player is in back, teleport to front (facing away from door)
			targetCFrame = doorCFrame * CFrame.new(0, 0, -teleportOffset) * CFrame.Angles(0, 0, 0)
		end

		-- Adjust Y position to place player on floor using HipHeight
		local humanoid: Humanoid = character:FindFirstChild("Humanoid")

		local hipHeight = humanoid.HipHeight
		local floorY = doorPart.Position.Y - (doorPart.Size.Y / 2)
		targetCFrame = CFrame.new(targetCFrame.Position.X, floorY + hipHeight, targetCFrame.Position.Z)
			* CFrame.Angles(0, select(2, targetCFrame:ToEulerAnglesYXZ()), 0)

		-- Update angle variable to match new rotation

		local angle = math.deg(select(2, targetCFrame:ToEulerAnglesYXZ()))
		MovementSystem.setAngle(angle)

		-- Teleport character
		character:PivotTo(targetCFrame)
	end

	-- fade in
	local fadeIn = TweenService:Create(frame, TweenInfo.new(fadeSpeed), { BackgroundTransparency = 1 })
	fadeIn:Play()
	fadeIn.Completed:Wait()

	MovementSystem.setEnabled(true)

	ContextActionService:UnbindAction("interaction:wait")
end

local function doorInteraction(doorPart: Part)
	local doorId = doorPart:GetAttribute("DoorId")
	local doorData = DoorsData[doorId]
	if doorData == nil then
		error("No door data found for doorId: " .. tostring(doorId))
	end

	if doorData.locked then
		-- find item in the inventory
		local hasKey = false
		for _, itemName in ipairs(inventory) do
			if itemName == doorData.keyItem then
				hasKey = true
				break
			end
		end

		if hasKey then
			local unlockedSound = doorPart:FindFirstChild("DoorUnlocked") :: Sound
			unlockedSound:Play()

			doorData.locked = false
			showTypedText(doorData.messages.unlocked, screenGui.TextLabel)
		else
			local lockedSound = doorPart:FindFirstChild("DoorLocked") :: Sound
			lockedSound:Play()

			showTypedText(doorData.messages.locked, screenGui.TextLabel)
		end
	else
		doorTravelSequence(doorPart)
	end
end

local function itemPickupInteraction(itemPart: Part)
	local function pickup()
		local itemName = itemPart:GetAttribute("Item")
		if itemName == nil then
			error("Item has no ItemName attribute")
		end

		table.insert(inventory, itemName)
		itemPart:Destroy()
	end

	showTypedText({
		"You picked up a ",
		{ tag = "font", attributes = { color = "rgb(0, 255, 0)" }, content = tostring(itemPart:GetAttribute("Item")) } :: TaggedText,
	}, screenGui.TextLabel):andThen(pickup)
end

local function handleInteration(_action: string, inputState: Enum.UserInputState, _inputObj: InputObject)
	if inputState == Enum.UserInputState.Begin then
		local character = Players.LocalPlayer.Character
		if character == nil then
			return
		end

		local cf, size = getInteractableBox(Players.LocalPlayer.Character)
		local overlapParams = OverlapParams.new()
		overlapParams.CollisionGroup = "InteractableCheck"
		local parts = workspace:GetPartBoundsInBox(cf, size, overlapParams)

		if #parts == 0 then
			return
		end

		local intType = parts[1]:GetAttribute("InteractableType")

		if intType == "door" then
			doorInteraction(parts[1])
		elseif intType == "item-pickup" then
			itemPickupInteraction(parts[1])
		else
			error("Unknown InteractableType: " .. tostring(intType))
		end
	end
end

ContextActionService:BindAction("interaction", handleInteration, false, Enum.UserInputType.MouseButton1)
