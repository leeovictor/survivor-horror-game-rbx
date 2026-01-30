local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local MovementSystem = {}

local dir = Vector3.zero
local angle = 0
local rotSpeed = 1
local movementEnabled = true
local movementActionName = "custom-char-movement"
local updateCon

local function setupCharacter(character: Model)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
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
		movementActionName,
		handleMovementAction,
		false,
		Enum.KeyCode.W,
		Enum.KeyCode.A,
		Enum.KeyCode.S,
		Enum.KeyCode.D
	)
end

function MovementSystem.setup()
	if Players.LocalPlayer.Character ~= nil then
		setupCharacter(Players.LocalPlayer.Character)
	end

	Players.LocalPlayer.CharacterAdded:Connect(function(character: Model)
		setupCharacter(character)
	end)

	Players.LocalPlayer.CharacterRemoving:Connect(function()
		ContextActionService:UnbindAction(movementActionName)
		if updateCon then
			updateCon:Disconnect()
			updateCon = nil
		end
	end)

	updateCon = RunService.Heartbeat:Connect(function()
		local character = Players.LocalPlayer.Character
		if not character then
			return
		end
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid
		if not humanoid then
			return
		end

		local rotationDir = 0
		local running = false

		if not movementEnabled then
			humanoid.WalkSpeed = 0
			return
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			rotationDir += 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			rotationDir -= 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			running = true
		end

		angle += rotationDir * rotSpeed
		angle %= 360

		-- andar para trás mais devagar
		humanoid.WalkSpeed = dir == Vector3.zAxis and 6 or 8
		if humanoid.WalkSpeed == 8 and running then
			humanoid.WalkSpeed = 16
		end

		local charCf = character:GetPivot()
		local newCharCf = CFrame.new(charCf.Position) * CFrame.Angles(0, math.rad(angle), 0)

		character:PivotTo(newCharCf)
		humanoid:Move(newCharCf:VectorToWorldSpace(dir), false)
	end)
end

function MovementSystem.setEnabled(enabled: boolean)
	movementEnabled = enabled
end

function MovementSystem.setAngle(newAngle: number)
	angle = newAngle
end

return MovementSystem
