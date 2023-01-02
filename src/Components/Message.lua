local Package = script.Parent.Parent

local Packages = Package.Packages

local Roact = require(Packages.Roact)
local Hooks = require(Packages.Hooks)
local StudioTheme = require(Packages.StudioTheme)

local e = Roact.createElement

local TextColors = {
    ["Blue"] = Color3.fromRGB(57, 57, 252),
    ["Purple"] = Color3.fromRGB(155, 16, 132),
    ["Red"] = Color3.fromRGB(233, 42, 42),
    ["Orange"] = Color3.fromRGB(252, 151, 0),
    ["Yellow"] = Color3.fromRGB(248, 235, 51),
    ["Green"] = Color3.fromRGB(31, 167, 18)
}

type MessageProps = {
    Text: string,
    Color: string,
    RichText: boolean,
}

local function message(props, hooks)
    local theme = StudioTheme.useTheme(hooks)

    return e("TextLabel", {
        Size = UDim2.new(0, 50, 0, 20),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.XY,
        Font = Enum.Font.Gotham,
        Text = props.Text,
        RichText = props.RichText,
        TextColor3 = if TextColors[props.Color] then TextColors[props.Color] else theme:GetColor(Enum.StudioStyleGuideColor.MainText),
        BackgroundTransparency = 1
    })
end

return Hooks.new(Roact)(message, {
    defaultProps = {
        Text = "Empty Message",
        Color = "Default",
        RichText = false
    }
})