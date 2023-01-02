local Package = script.Parent.Parent

local Packages = Package.Packages

local TokenColors = {
    ["cmd"] = Color3.fromRGB(255, 208, 0),
    ["str"] = Color3.fromRGB(0, 60, 224),
    ["flag"] = Color3.fromRGB(88, 88, 88),
    ["num"] = Color3.fromRGB(255, 145, 0),
    ["link"] = Color3.fromRGB(0, 60, 255)
}

local colorRichText = {"<font color=\"rgb(%s,%s,%s)\">", "</font>"}

local highlighter = {}
highlighter.__index = highlighter

type LexedString = {
    context: string,
    str: string
}

local function lexer(s: string)
    local split = string.split(s, " ")

    local result = {}

    if split then
        for i, v in pairs(split) do
            if i == 1 then
                result[i] = {
                    context = "cmd",
                    str = v
                }
            else
                if string.match(v, "^..") == "--" or string.match(v, "^.") == "-" then
                    result[i] = {
                        context = "flag",
                        str = v
                    }
                elseif string.match(v, "\"$") and string.match(v, "^\"") then
                    result[i] = {
                        context = "str",
                        str = v
                    }
                elseif tonumber(v) then
                    result[i] = {
                        context = "num",
                        str = v
                    }
                elseif string.match(v, "^https://") then
                    result[i] = {
                        context = "link",
                        str = v
                    }
                else
                    result[i] = {
                        context = "none",
                        str = v
                    }
                end
            end
        end
    end

    return result
end

local function colorize(lexedStr: LexedString)
    local color = TokenColors[lexedStr.context]

    if color then
        local colorResult = string.format(colorRichText[1], tostring(math.floor(color.R * 255)), tostring(math.floor(color.G * 255)), tostring(math.floor(color.B * 255)))
    
        return colorResult .. lexedStr.str .. colorRichText[2]
    else
        return lexedStr.str
    end
end

function highlighter.new(Obj: GuiObject)
    local self = setmetatable({
        Obj = Obj,
        OriginalText = Obj.Text,
        textChanged = nil,
        autoDestroy = nil,
        lexing = false
    }, highlighter)

    Obj.RichText = true

    self.textChanged = Obj:GetPropertyChangedSignal("Text"):Connect(function()
        if not self.lexing and string.len(Obj.Text) > 0 then
            self.lexing = true

            self:Highlight()

            self.lexing = false
        end
    end)

    self.autoDestroy = Obj.AncestryChanged:Connect(function()
        if not Obj.Parent then
            self:Destroy()
        end
    end)

    return self
end

function highlighter:Highlight()
    self.OriginalText = self.Obj.Text

    local lexedText = lexer(self.Obj.Text)

    local textToShow = ""

    for i, v in pairs(lexedText) do
        local colorizedText = colorize(v)

        if i ~= #lexedText then
            textToShow ..= colorizedText .. " "
        else
            textToShow ..= colorizedText
        end
    end

    self.Obj.Text = textToShow
end

function highlighter:Destroy()
    self.textChanged:Disconnect()
    self.autoDestroy:Disconnect()

    if self.Obj then
        self.Obj = self.OriginalText
    end
end

return highlighter