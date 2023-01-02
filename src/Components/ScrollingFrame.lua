local Package = script.Parent.Parent

local Packages = Package.Packages

local Roact = require(Packages.Roact)
local Hooks = require(Packages.Hooks)
local StudioTheme = require(Packages.StudioTheme)

local e = Roact.createElement

type ScrollingFrameProps = {
    Size: UDim2,
    Position: UDim2,
    ScrollingDirection: EnumItem,
    AutoCanvasSize: EnumItem,

    FillDirection: EnumItem,
    HorizontalAlignment: EnumItem,
    Padding: UDim
}

local function scrollingframe(props: ScrollingFrameProps, hooks)
    local theme = StudioTheme.useTheme(hooks)

    local fillDir = props.FillDirection
    local horizontalAlignment = props.HorizontalAlignment
    local padding = props.Padding

    return e("ScrollingFrame", {
        Size = props.Size,
        Position = props.Position,
        BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
        ScrollBarImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ScrollBar),
        BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
        ScrollingDirection = props.ScrollingDirection,
        AutomaticCanvasSize = props.AutoCanvasSize,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 1,
    }, {
        layout = e("UIListLayout", {
            FillDirection = fillDir,
            HorizontalAlignment = horizontalAlignment,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = padding
        }),

        Roact.createFragment(props[Roact.Children])
    })
end

return Hooks.new(Roact)(scrollingframe)