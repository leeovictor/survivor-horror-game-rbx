local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local FixedCameraSystem = {}

local function changeCamera(box: Part)
	local cameraPart = box:FindFirstChild("Camera")
	if not cameraPart or not cameraPart:IsA("BasePart") then
		error("FixedCameraSystem: No valid camera part found for box:" .. box.Name)
		return
	end

	local camera = workspace.CurrentCamera

	if camera.CameraType ~= Enum.CameraType.Scriptable then
		camera.CameraType = Enum.CameraType.Scriptable
	end

	camera.CFrame = cameraPart.CFrame
end

local touchedConnections = {}

local function setupBoundingBox(box: Part)
	local function onTouch(part: BasePart)
		if part.Name == "HumanoidRootPart" then
			local char = part.Parent
			if char ~= nil and char:IsA("Model") then
				local player = Players:GetPlayerFromCharacter(char)

				if player == nil or player ~= Players.LocalPlayer then
					return
				end
			end
			changeCamera(box)
		end
	end

	box.Transparency = 1
	local camera = box:WaitForChild("Camera") :: Part
	camera.Transparency = 1

	touchedConnections[box] = box.Touched:Connect(onTouch)
end

function FixedCameraSystem.setup()
	for _, box: Part in ipairs(CollectionService:GetTagged("CameraBoudingBoxes")) do
		setupBoundingBox(box)
	end

	CollectionService:GetInstanceAddedSignal("CameraBoudingBoxes"):Connect(function(part: Part)
		print("FixedCamerasystem:instance-added", part.Name)
		setupBoundingBox(part)
	end)
	CollectionService:GetInstanceRemovedSignal("CameraBoudingBoxes"):Connect(function(part: Part)
		local con = touchedConnections[part]
		if con ~= nil then
			con:Disconnect()
			touchedConnections[part] = nil
		end
	end)
end

return FixedCameraSystem
