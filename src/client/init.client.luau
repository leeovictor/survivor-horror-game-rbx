local CollectionService = game:GetService("CollectionService")

local function changeCamera(box: Part)
	print("Current Box: ", box.Name)

	local cameraName = box:GetAttribute("camera")
	if cameraName == nil then
		return
	end

	local cameraPart: Part = workspace:FindFirstChild(cameraName)
	if cameraPart == nil then
		return
	end

	local camera = workspace.CurrentCamera

	if camera.CameraType ~= Enum.CameraType.Scriptable then
		camera.CameraType = Enum.CameraType.Scriptable
	end

	camera.CFrame = cameraPart.CFrame
end

local function setupBoundingBox(box: Part)
	box.Transparency = 1
	box.Touched:Connect(function(part: BasePart)
		if part.Name == "HumanoidRootPart" then
			changeCamera(box)
		end
	end)
end

CollectionService:GetInstanceAddedSignal("CameraBoudingBoxes"):Connect(function(part: Part)
	setupBoundingBox(part)
end)

for _, box: Part in ipairs(CollectionService:GetTagged("CameraBoudingBoxes")) do
	setupBoundingBox(box)
end

CollectionService:GetInstanceAddedSignal("CameraSpots"):Connect(function(part: Part)
	part.Transparency = 1
end)

for _, part: Part in ipairs(CollectionService:GetTagged("CameraSpots")) do
	part.Transparency = 1
end

local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")

local humanoid: Humanoid = nil
local dir = Vector3.zero

local angle = 0

local function setupCharacter(character: Model)
	humanoid = character:WaitForChild("Humanoid") :: Humanoid
	if humanoid == nil then
		error("humanoid not found")
	end
	humanoid.AutoRotate = false

	local function handleMovementAction(_actionName, inputState: Enum.UserInputState, inputObj: InputObject)
		if inputState == Enum.UserInputState.Begin then
			if inputObj.KeyCode == Enum.KeyCode.W then
				dir += Vector3.new(0, 0, -1)
			end
			if inputObj.KeyCode == Enum.KeyCode.S then
				dir += Vector3.new(0, 0, 1)
			end
		elseif inputState == Enum.UserInputState.End then
			if inputObj.KeyCode == Enum.KeyCode.W then
				dir -= Vector3.new(0, 0, -1)
			end
			if inputObj.KeyCode == Enum.KeyCode.S then
				dir -= Vector3.new(0, 0, 1)
			end
		end
	end

	ContextActionService:BindAction(
		"custom-char-movement",
		handleMovementAction,
		false,
		Enum.KeyCode.W,
		Enum.KeyCode.A,
		Enum.KeyCode.S,
		Enum.KeyCode.D
	)
end

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local rotSpeed = 1

RunService.Heartbeat:Connect(function()
	if humanoid ~= nil then
		local character = Players.LocalPlayer.Character
		local rotationDir = 0
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			rotationDir += 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			rotationDir -= 1
		end

		angle += rotationDir * rotSpeed
		if angle > 360 then
			angle = 0
		elseif angle < 0 then
			angle = 360
		end

		character:PivotTo(CFrame.new(character:GetPivot().Position) * CFrame.Angles(0, math.rad(angle), 0))

		humanoid.WalkSpeed = dir == Vector3.zAxis and 6 or 16

		humanoid:Move(character:GetPivot():VectorToWorldSpace(dir), false)
	end
end)

if Players.LocalPlayer.Character ~= nil then
	setupCharacter(Players.LocalPlayer.Character)
end

Players.LocalPlayer.CharacterAdded:Connect(function(character: Model)
	setupCharacter(character)
end)

local screenGui = Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")

task.wait(5)

local textSpeed = 0.5

local function showTypedText(text: string, textLabel: TextLabel)
	textLabel.Text = ""
	local letters = string.split(text, "")

	local t = textSpeed / #letters
	for _, letter in ipairs(letters) do
		textLabel.Text = textLabel.Text .. letter
		task.wait(t)
	end
end

task.defer(function()
	showTypedText(
		"Esse é um texto bem grande para testar essa funcionalidade super interessante. E aqui vai mais um pouco de texto pra ficar maior ainda.",
		screenGui.TextLabel
	)
end)
