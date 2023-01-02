local Package = script.Parent.Parent

local Packages = Package.Packages
local Lib = Package.Lib

local Roact = require(Packages.Roact)
local Hooks = require(Packages.Hooks)
local StudioTheme = require(Packages.StudioTheme)

local Highlighter = require(Lib.Highlighter)

local e = Roact.createElement

type InputProps = {
    Dir: string,
    useOldText: boolean,
    onEnter: (rbx: TextBox) -> ()
}

local oldText = ""

local function input(props, hooks)
    local theme = StudioTheme.useTheme(hooks)

    local text = props.useOldText and oldText or ""

    local inputPos, setInputPos = hooks.useState(UDim2.new())
    local displayText, setDisplayText = hooks.useState(text)

    local ref = hooks.useValue(Roact.createRef())
    
    hooks.useEffect(function()
        Highlighter.new(ref.value:getValue().input.display)

        ref.value:getValue().input:CaptureFocus()
    end, {})

    return e("Frame", {
        Size = UDim2.new(0, 50, 0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,

        [Roact.Ref] = ref.value
    }, {
        dirDisplay = e("TextLabel", {
            Size = UDim2.new(0, 10, 1, 0),
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            Text = props.Dir .. ">",
            TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
            BackgroundTransparency = 1,

            [Roact.Change.TextBounds] = function(rbx)
                local Bounds = rbx.TextBounds

                setInputPos(UDim2.new(0, Bounds.X + 10, 0, 0))
            end
        }),

        input = e("TextBox", {
            Position = inputPos,
            Size = UDim2.new(0, 10, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 16,
            Text = text,
            Font = Enum.Font.Gotham,
            TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
            ClearTextOnFocus = false,
            BackgroundTransparency = 1,

            [Roact.Event.FocusLost] = function(rbx, enterpressed)
                if enterpressed and props.onEnter then
                    props.onEnter(rbx)
                end
            end,

            [Roact.Change.Text] = function(rbx)
                setDisplayText(rbx.Text)

                if props.useOldText then
                    oldText = rbx.Text
                else
                    oldText = ""
                end
            end
        }, {
            display = e("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                TextSize = 16,
                AutomaticSize = Enum.AutomaticSize.X,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                Text = displayText,
                RichText = true,
                TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
                BackgroundTransparency = 1,
            })
        })
    })
end

return Hooks.new(Roact)(input, {
    defaultProps = {
        Dir = "game",
        useOldText = false
    }
})