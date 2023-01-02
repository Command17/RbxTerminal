local Package = script.Parent.Parent

local Packages = Package.Packages
local Components = Package.Components

local Roact = require(Packages.Roact)
local Hooks = require(Packages.Hooks)
local StudioTheme = require(Packages.StudioTheme)

local e = Roact.createElement

local function background(props, hooks)
    local theme = StudioTheme.useTheme(hooks)

    return e("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
    }, {
        Roact.createFragment(props[Roact.Children])
    })
end

return Hooks.new(Roact)(background)