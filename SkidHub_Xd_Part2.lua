getgenv().fpsBoost = false
getgenv().waitCollect = 0.4
getgenv().ServerHop = 16
getgenv().TaskWaitUntilHop = 5
getgenv().wantedPity = 0
getgenv().fallBackDelay = 100 -- 100/10 = 10 seconds,
getgenv().ItemsToFarm = {
    
	["Lucky Arrow"] = {
        Max = 10,
        Sell = false,
    },
	["Dio's Diary"] = {
        Max = 10,
        Sell = false,
    },

	["Rib Cage of The Saint's Corpse"] = {
        Max = 10,
        Sell = false,
    },
        ["Mysterious Arrow"] = {
        Max = 25,
        Sell = false,
    },
        ["Rokakaka"] = {
        Max = 25,
        Sell = false,
    },
};
repeat task.wait() until game.Players.LocalPlayer
repeat task.wait() until game.Players.LocalPlayer.Character
repeat task.wait() until game.Players.LocalPlayer.Character:FindFirstChild("RemoteEvent")

if getgenv().fpsBoost then
    game:GetService("RunService"):Set3dRenderingEnabled(false)
end

local LocalPlayer = game.Players.LocalPlayer

task.spawn(function()
    local IAMGOINGINSANEFROMYOU = true
    while IAMGOINGINSANEFROMYOU do task.wait(1)
        for _,v in pairs(game.LogService:GetLogHistory()) do
            if string.find(v["message"], "BEGAN") or string.find(v["message"], "bruh") then
                game:GetService("TeleportService"):Teleport(2809202155, game:GetService("Players").LocalPlayer)
                IAMGOINGINSANEFROMYOU = false
            end
        end
    end
end)

--crash bypass
pcall(function()
    local functionLibrary = require(game.ReplicatedStorage:WaitForChild('Modules').FunctionLibrary) --TODO: FIND THE REASON WHY THIS IS ERRORING SOMETIMES
    local old = functionLibrary.pcall

    functionLibrary.pcall = function(...)
        local f = ...

        if type(f) == 'function' and #getupvalues(f) == 11 then 
            return
        end
        
        return old(...)
    end

    --tp bypass
    local Hook;
    Hook = hookmetamethod(game, '__namecall', newcclosure(function(self, ...)
        local args = {...}
        local namecallmethod =  getnamecallmethod()

        if namecallmethod == "InvokeServer" then
            if args[1] == "idklolbrah2de" then
                return "  ___XP DE KEY"
            end
        end
        
        if (namecallmethod == "InvokeServer" or namecallmethod == "InvokeClient") and args[1] == "Reset" and args[3] ~= "DANK WAS HERE" then
            return
        end
        if namecallmethod == "FireServer" and args[1] == "Reset" and args[3] ~= "DANK WAS HERE" then
            return
        end
        return Hook(self, ...)
    end))


    --reset
    local NewEvent = Instance.new("BindableEvent")
    NewEvent.Event:Connect(function()
                    
    local args = {
        [1] = "Reset",
        [2] = {
            ["Anchored"] = false
        },
            [3] = "DANK WAS HERE"
        }

        game:GetService("Players").LocalPlayer.Character.RemoteEvent:FireServer(unpack(args))
    end)

    game:GetService("StarterGui"):SetCore("ResetButtonCallback", NewEvent)
end)

--[[MAIN FUNCTIONS]]
local function SendWebhook(msg)
    task.spawn(function()
        local url = getgenv().webhook

        local data;
        data = {
            ["embeds"] = {
                {
                    ["footer"] = {
                        ["text"] = "Current Time: " .. os.date("%Y-%m-%d %H:%M:%S"),
                        ["icon_url"] = "https://cdn.discordapp.com/attachments/1007872718106021978/1141831908288905246/FgX4UeAXEAAplLL.jpg"},

                    ["title"] = "Xenon V3 - Auto Pity Farm BETA",
                    ["description"] = msg,
                    ["type"] = "rich",
                    ["color"] = tonumber(string.format("0x%X", math.random(0x000000, 0xFFFFFF))),
                }
            }
        }

        repeat task.wait() until data
        local newdata = game:GetService("HttpService"):JSONEncode(data)


        local headers = {
            ["Content-Type"] = "application/json"
        }
        local request = http_request or request or HttpPost or syn.request or http.request
        local abcdef = {Url = url, Body = newdata, Method = "POST", Headers = headers}
        request(abcdef)
    end)
end


local serverToHop = "notYet"

local function serverHop()
    task.spawn(function()
        local file

        if isfile("NotSameServers.json") then
            file = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
        else
            writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode({game.JobId}))
            file = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
        end

        local Url = "https://games.roblox.com/v1/games/2809202155/servers/Public?sortOrder=Desc&limit=100"
        local Cursor = game:GetService("HttpService"):JSONDecode(game:HttpGet(Url)).nextPageCursor
        local Got = false

        repeat
            local Faster = game:GetService("HttpService"):JSONDecode(game:HttpGet(Url.."&cursor="..tostring(Cursor)))

            if not Faster then
                print("Rate Limited, give me a moment")
                task.wait(5)
                Got = true
                serverHop()
            end

            for _,server in next, Faster.data do
                if server.playing then
                    print(server.playing)
                        local clampedAmount = math.clamp(getgenv().ServerHop, (server.playing-1), (server.playing+1))
                        if clampedAmount <= getgenv().ServerHop and not table.find(file, server.id) then
                            table.insert(file, server.id)
                            writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(file))
                            Got = true
                            serverToHop = server.id
                            break
                        end
                    end
                end
            Cursor = Faster.nextPageCursor or Cursor
            task.wait(0.5)
        until Got == true
    end)

    game:GetService("TeleportService").TeleportInitFailed:Connect(function()
        serverToHop = "notyet"; serverHop()
        while serverToHop == "notyet" do
            task.wait(1)
        end
        game:GetService("TeleportService"):TeleportToPlaceInstance(2809202155, serverToHop, game.Players.LocalPlayer)
    end)
end

serverHop()

if not LocalPlayer.PlayerGui:FindFirstChild("HUD") then
    local HUD = game:GetService("ReplicatedStorage").Objects.HUD:Clone()
    HUD.Parent = LocalPlayer.PlayerGui
end

pcall(function()
    for _,v in pairs(getconnections(LocalPlayer.Idled)) do
        v:Disable()
    end

    print("Xenon On TOP! Made with love by dank, Xenon Invite Link:https://discord.gg/YrAa5ngDPv")
    LocalPlayer.Character.RemoteEvent:FireServer("PressedPlay")

    LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen1"):Destroy()
    task.wait(0.5)
    LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen"):Destroy()

    workspace.Map.IMPORTANT.OceanFloor.OceanFloor_Sand_6.Size = Vector3.new(2048, 89, 2048)
    workspace.Map.IMPORTANT.OceanFloor.OceanFloor_Sand_4.Size = Vector3.new(2048, 89, 2048)
end)

hookfunction(workspace.Raycast, function()
    return
end)

local function getitem(item)
    local gotItem = false
    local timeout = 5
    local itemPosition = item.PrimaryPart.CFrame

    LocalPlayer.Backpack.ChildAdded:Connect(function()
        gotItem = true
    end)

    task.spawn(function()
        while not gotItem do
            task.wait()
            workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, itemPosition.Position)
            LocalPlayer.Character.HumanoidRootPart.CFrame = itemPosition - Vector3.new(0,10,0)
        end
    end)

    task.wait(getgenv().waitCollect)

    fireproximityprompt(item.ProximityPrompt)
    
    task.spawn(function()
        for i=timeout, 1, -1 do
            task.wait(1)
        end

        if not gotItem then
            gotItem = true
            return
        end
    end)


    while not gotItem do
        task.wait()
    end
end

local function checkItem(item)
    local itemExists = item:FindFirstChild("ProximityPrompt")

    if not itemExists then
        return
    end

    local itemPP = item.ProximityPrompt

    if itemPP.MaxActivationDistance >= 8 then
        item.Name = item.ProximityPrompt.ObjectText
        itemPP.MaxActivationDistance = 30
        item.ProximityPrompt.RequiresLineOfSight = false
        item.ProximityPrompt.HoldDuration = 0
    else
        print("fake ".. item.ProximityPrompt.ObjectText.. ", bro is not high")
    end
end


--watcher
game.Workspace["Item_Spawns"].Items.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("ProximityPrompt") then
        local itemInstance = descendant:FindFirstAncestorWhichIsA("Model")
        checkItem(itemInstance)
    end
end)

--hook here so descendantadded can have some time
local itemHook;

itemHook = hookfunction(getrawmetatable(LocalPlayer.Character.HumanoidRootPart.Position).__index, function(p,i)
        if getcallingscript().Name == "ItemSpawn" and i:lower() == "magnitude" then
            return 0
        end
    return itemHook(p,i)
end)

--count items
local function checkIfFull(itemName, amount)
    local itemAmount = 0

    for _,item in pairs(LocalPlayer.Backpack:GetChildren()) do
        if item.Name == itemName then
            itemAmount += 1;
        end
    end

    if amount then
        if itemAmount >= (amount) then
            return true
        else
			return false
		end
    end

    return itemAmount
end

--farm, repeats it
local function farmItem(item, amount, autoSell)
    local iteminstance = workspace.Item_Spawns.Items:WaitForChild(item, 5)

    if workspace.Item_Spawns.Items:WaitForChild(item, 5) then
        if checkIfFull(item, amount) then
            return true
        end

        if iteminstance then
            getitem(iteminstance)
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(500, 2005, 500)
            if autoSell then
                LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(item))
                local dialogueToEnd = {
                    ["NPC"] = "Merchant",
                    ["Dialogue"] = "Dialogue5",
                    ["Option"] = "Option2"
                }
                LocalPlayer.Character.RemoteEvent:FireServer("EndDialogue", dialogueToEnd)
            end
            farmItem(item, amount, autoSell)
        end
    else
        return true
    end
end

local function CalculateSkinPity()
    local pityCount = LocalPlayer.PlayerStats.PityCount
    if pityCount.Value <= 0 then
        return 1
    end

    print(math.clamp(1 + pityCount.Value / 25, 0, 10))

    return math.clamp(1 + pityCount.Value / 25, 0, 10);
end

--failsafe
task.spawn(function()
    LocalPlayer.CharacterAdded:Connect(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(2809202155, serverToHop, game.Players.LocalPlayer)
    end)
end)


local function countItems(item)
	local itemAmount = 0
	for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
 	   if v.Name == item then
     		itemAmount = itemAmount + 1
  	   end
	end
	return tostring(itemAmount)
end

local function useRib()
    if CalculateSkinPity() > getgenv().wantedPity then
        return
    end

    local item = LocalPlayer.Backpack:FindFirstChild("Rib Cage of The Saint's Corpse")
    local countDown = getgenv().fallBackDelay
    if item then
        local oldPity = LocalPlayer.PlayerStats.PityCount.Value

        LocalPlayer.Character.Humanoid:EquipTool(item)
        LocalPlayer.Character.RemoteFunction:InvokeServer("LearnSkill",{["Skill"] = "Worthiness V",["SkillTreeType"] = "Character"})
    
        LocalPlayer.Character.RemoteEvent:FireServer("EndDialogue", {
            ["NPC"] = "Rib Cage of The Saint's Corpse",
            ["Option"] = "Option1",
            ["Dialogue"] = "Dialogue2"
        })
        repeat task.wait(0.1) countDown = countDown - 1 print(countDown) until LocalPlayer.PlayerStats.PityCount.Value ~= oldPity or LocalPlayer.PlayerStats.PityCount.Value == 1 or countDown <= 0
        useRib()
    end

    task.wait(2)

    game:GetService("TeleportService"):TeleportToPlaceInstance(2809202155, serverToHop, game.Players.LocalPlayer)
end

game:GetService("TeleportService").TeleportInitFailed:Connect(function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(2809202155, serverToHop, game.Players.LocalPlayer)
end)

--mainfunction
local part = Instance.new("Part")
part.Anchored = true
part.Size = Vector3.new(100,1,100)
part.Parent = workspace
part.Position = Vector3.new(500, 2000, 500)

hookfunction(workspace.Raycast, function() -- noclip bypass
    return
end)

local itemsMessage = ""

for itemName, itemData in pairs(getgenv().ItemsToFarm) do
    local maxAmount = itemData.Max
    local shouldSell = itemData.Sell

    if shouldSell then
        farmItem(itemName, maxAmount, true)
    else
        farmItem(itemName, maxAmount)
    end

    itemsMessage = itemsMessage .. countItems(itemName) .. " " .. itemName .. "\n"..  "Was it sold? " .. (shouldSell and "Yeah" or "Nope") .. "\n"
end

LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(500, 2005, 500)
itemsMessage = itemsMessage .. "Current pity: ".. CalculateSkinPity() .. "%\n"
SendWebhook(itemsMessage)
if getgenv().wantedPity == 0 then
local args = {
        [1] = "Reset",
        [2] = {
            ["Anchored"] = false
        },
            [3] = "DANK WAS HERE"
        }

        game:GetService("Players").LocalPlayer.Character.RemoteEvent:FireServer(unpack(args))
end
while serverToHop == "notyet" do task.wait(1) end

if CalculateSkinPity() < getgenv().wantedPity then
    useRib()
end
