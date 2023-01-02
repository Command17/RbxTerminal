local Package = script.Parent.Parent

local LogService = game:GetService("LogService")

local Packages = Package.Packages
local Components = Package.Components
local Lib = Package.Lib
local CommandPackages = Package.CommandPackages

local Actions = require(Package.Actions)

local Roact = require(Packages.Roact)
local RoduxHooks = require(Packages.RoduxHooks)

local App = require(Components.App)
local Message = require(Components.Message)
local ScrollingFrame = require(Components.ScrollingFrame)
local Input = require(Components.Input)

local HttpPromise = require(Lib.HttpPromise)

local e = Roact.createElement

local MessageTypeColors = {
    [Enum.MessageType.MessageOutput] = "Default",
    [Enum.MessageType.MessageInfo] = "Blue",
    [Enum.MessageType.MessageError] = "Red",
    [Enum.MessageType.MessageWarning] = "Orange"
}

local terminal = {}
terminal.__index = terminal

function terminal.new(plugin: Plugin, store)
    local self = setmetatable({
        plugin = plugin,
        store = store,
        handle = nil,
        lines = 0,
        history = {},
        messageOut = nil,
        Dir = game,
        Packages = {},
        Saveable = {
            Packages = {},
            Settings = {
                logMessagesEnabled = true
            }
        }
    }, terminal)

    self:Create()

    self.messageOut = LogService.MessageOut:Connect(function(message, messageType)
        if self:GetSetting("logMessagesEnabled") == true then
            local Color = MessageTypeColors[messageType]

            self:CreateMessage("--- " .. message, Color)
        end
    end)

    self:RegisterBuildInPackages()

    self:Load()

    return self
end

function terminal:CreateMessage(Text: string, Color: string?, RichText: boolean?)
    Color = Color or "Default"
    RichText = RichText or false

    self:ClearInput()

    local Msg = e(Message, {Text = Text, Color = Color, RichText = RichText})

    self.history[tostring(self.lines + 1)] = Msg

    self.lines += 1

    self.store:dispatch(Actions.Update())

    self:CreateInput()
end

function terminal:Create()
    if not self.handle then
        local app = e(RoduxHooks.Provider, {
            store = self.store
        }, {
            app = e(App, {
                plugin = self.plugin
            }, {
                layout = e(ScrollingFrame, {
                    Size = UDim2.fromScale(1, 1),
                    ScrollingDirection = Enum.ScrollingDirection.XY,
                    AutoCanvasSize = Enum.AutomaticSize.XY,
                    FillDirection = Enum.FillDirection.Vertical,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    Padding = UDim.new(0, 0)
                }, self.history)
            })
        })

        self:CreateMessage("Running RbxTerminal v" .. self.store:getState().plugin_meta.version .. ". Type 'help' to see all commands. Type 'clear' to clear")

        local state = self.store:getState()

        if state.plugin_meta.latest.id > state.plugin_meta.id then
            self:CreateMessage("A new version is out! [v" .. state.latest.version .. "]")
        end

        self.handle = Roact.mount(app, nil, "RbxTerminal")
    end
end

function terminal:CreateInput(useOldText: boolean?)
    task.wait(.05)

    if self.history["input"] == nil then
        self.history["input"] = e(Input, {
            Dir = self:DirToString(),
            useOldText = useOldText,
    
            onEnter = function(rbx)
                if rbx then
                    if string.len(rbx.Text) > 0 then
                        local dirDisplay = rbx.Parent:FindFirstChild("dirDisplay")
                        local display = rbx:FindFirstChild("display")
    
                        if dirDisplay and display then
                            self:CreateMessage(dirDisplay.Text .. " " .. display.Text, nil, true)
    
                            self:ClearInput()
    
                            self:RunCmd(rbx.Text)

                            self:CreateInput()
                        end
                    end
                end
            end
        })
        
        self.store:dispatch(Actions.Update())
    end
end

function terminal:RegisterBuildInPackages()
    for i, v in pairs(CommandPackages.BuildIn:GetChildren()) do
        self:RegisterPackage(v)
    end
end

function terminal:RegisterPackage(cmdPackage: ModuleScript)
    local package = require(cmdPackage)

    if not self.Packages[package.Name] then
        if typeof(package.Name) == "string" and typeof(package.Version) == "string" then
            self.Packages[package.Name] = package
    
            return true
        end
    
        self:CreateMessage("Package info is missing!", "Red")
    else
        self:CreateMessage("Package already registered!", "Red")
    end

    return false
end

function terminal:AddPackage(package: ModuleScript)
    local cmdPackage = package:Clone()

    cmdPackage.Parent = CommandPackages.Custom

    local succes = self:RegisterPackage(cmdPackage)

    if succes then
        local packageInfo = require(cmdPackage)

        self.Saveable.Packages[packageInfo.Name] = package.Source

        self:Save()
    else
        cmdPackage:Destroy()
    end
end

function terminal:RemovePackage(package: string)
    self.Packages[package] = nil
    self.Saveable.Packages[package] = nil

    local cmdPackage = CommandPackages.Custom:FindFirstChild(package)

    if cmdPackage then
        cmdPackage:Destroy()
    end

    self:Save()
end

function terminal:Save()
    self.plugin:SetSetting("SAVEABLE_DATA", HttpPromise.EncodeJSON(self.Saveable))
end

function terminal:Load()
    local data = self.plugin:GetSetting("SAVEABLE_DATA")

    if data ~= nil then
        data = HttpPromise.DecodeJSON(data)

        self.Saveable = data

        for name, package in pairs(self.Saveable.Packages) do
            if typeof(package) == "string" then
                local cmdPackage = Instance.new("ModuleScript")

                cmdPackage.Source = package
                cmdPackage.Name = name
    
                self:RegisterPackage(cmdPackage)
            end
        end
    end
end

function terminal:GetSetting(Name: string)
    return self.Saveable.Settings[Name]
end

function terminal:SetSetting(Name: string, v: boolean)
    self.Saveable.Settings[Name] = v
end

function terminal:RunCmd(s: string)
    local cmd, args, flags = self:Parse(s)

    local cmdInPackage = nil

    for i, v in pairs(self.Packages) do
        if v[cmd] then
            cmdInPackage = v[cmd]
        end
    end

    if cmdInPackage ~= nil then
        if typeof(cmdInPackage) == "function" then
            cmdInPackage(args, flags, self)
        elseif typeof(cmdInPackage) == "table" then
            local subCommand = cmdInPackage[args[1]]

            if typeof(subCommand) == "function" then
                table.remove(args, 1)

                subCommand(args, flags, self)
            else
                self:CreateMessage("Subcommand does not exist!", "Red")
            end
        else
            self:CreateMessage("Command does not exist!", "Red")
        end
    else
        self:CreateMessage("Command does not exist!", "Red")
    end
end

function terminal:Clear()
    self:ClearInput()

    table.clear(self.history)

    self:CreateMessage("Cleared history.")

    self:CreateInput()
end

function terminal:ClearInput()
    if self.history["input"] ~= nil then
        self.history["input"] = nil

        self.store:dispatch(Actions.Update())
    end
end

function terminal:IsFlag(s: string, flag: string, flag_short: string)
    return if s == flag or s == flag_short then true else false
end

function terminal:IsString(s: string)
    return if string.match(s, "\"$") and string.match(s, "^\"") then true else false
end

function terminal:GetDirInDirFromString(s: string)
    local split = string.split(s, "/")

    local dir = self.Dir

    if split[1] == "game" then
        table.remove(split, 1)
    end

    for _, v in pairs(split) do
        local instance = dir:FindFirstChild(v)

        if instance then
            dir = instance
        else
            break
        end
    end

    return dir
end

function terminal:SetDirWithString(s: string)
    local split = string.split(s, "/")

    if split[1] == "game" then
        table.remove(split, 1)
    end

    local dir = ""

    for i, v in pairs(split) do
        if i ~= #split then
            dir ..= v .. "/"
        else
            dir ..= v
        end
    end

    self.Dir = game

    self.Dir = self:GetDirInDirFromString(s)

    return self.Dir
end

function terminal:DirToString()
    local parents = {}

    local dir = self.Dir

    for i = 1, 100, 1 do
        if i ~= 1 then
            local parent = dir.Parent

            if parent then
                parents[i] = parent

                dir = parent
            else
                break
            end
        else
            parents[i] = dir
        end
    end

    local s = ""

    for i = #parents, 1, -1 do
        local index = parents[i]

        if index == game then
            s ..= "game"
        else
            s ..= "/" .. index.Name
        end
    end

    return s
end

function terminal:Parse(s: string)
    local flags = {}
    local args = {}
    local cmd = ""

    local split = string.split(s, " ")

    for i, v in pairs(split) do
        if i == 1 then
            cmd = v
        else
            if string.match(v, "^..") == "--" then
                table.insert(flags, v)
            elseif string.match(v, "^.") == "-" then
                table.insert(flags, v)
            else
                table.insert(args, v)
            end
        end
    end

    return cmd, args, flags
end

function terminal:Destroy()
    if self.handle then
        Roact.unmount(self.handle)
    end
end

return terminal