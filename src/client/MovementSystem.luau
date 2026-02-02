local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MovementSystem = {}

local dir = Vector3.zero
local runSpeed = 12
local walkSpeed = 6
local backwardSpeedMultiplier = 0.5
local angle = 0
local rotSpeed = 0.8
local movementEnabled = true
local movementActionName = "custom-char-movement"
local updateCon
local diedCon

local function setupCharacter(character: Model)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	humanoid.AutoRotate = false
	diedCon = humanoid.Died:Connect(function()
		ContextActionService:UnbindAction(movementActionName)
		dir = Vector3.zero
		if updateCon then
			updateCon:Disconnect()
			updateCon = nil
			diedCon:Disconnect()
		end
	end)

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
	local function update()
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
			if movementEnabled then
				humanoid.WalkSpeed = dir == Vector3.zAxis and walkSpeed * backwardSpeedMultiplier or walkSpeed
				if humanoid.WalkSpeed == walkSpeed and running then
					humanoid.WalkSpeed = runSpeed
				end
			else
				humanoid.WalkSpeed = 0
			end

			local charCf = character:GetPivot()
			local newCharCf = CFrame.new(charCf.Position) * CFrame.Angles(0, math.rad(angle), 0)

			character:PivotTo(newCharCf)
			humanoid:Move(newCharCf:VectorToWorldSpace(dir), false)
		end)
	end

	if Players.LocalPlayer.Character ~= nil then
		setupCharacter(Players.LocalPlayer.Character)
		update()
	end

	Players.LocalPlayer.CharacterAdded:Connect(function(character: Model)
		setupCharacter(character)
		update()
	end)

	Players.LocalPlayer.CharacterRemoving:Connect(function()
		ContextActionService:UnbindAction(movementActionName)
		if updateCon then
			updateCon:Disconnect()
			updateCon = nil
		end
	end)
end

function MovementSystem.setEnabled(enabled: boolean)
	movementEnabled = enabled
end

function MovementSystem.setAngle(newAngle: number)
	angle = newAngle
end

return MovementSystem
