local FlagToColor = {
    ["--g"] = "Green",
    ["--r"] = "Red",
    ["--p"] = "Purple",
    ["--y"] = "Yellow",
    ["--o"] = "Orange"
}

return {
    Name = "Batch",
    Version = "1.0.0",

    ["echo"] = function(args, flags, terminal)
        local s = ""

        for i, v in pairs(args) do
            if i ~= #args then
                s ..= v .. " "
            else
                s ..= v
            end
        end

        local color = FlagToColor[flags[1]]

        if terminal:IsString(s) then
            s = string.sub(s, 2, string.len(s) - 1)

            terminal:CreateMessage(s, color)
        end
    end,

    ["cd"] = function(args, flags, terminal)
        local s = ""

        for i, v in pairs(args) do
            if i ~= #args then
                s ..= v .. " "
            else
                s ..= v
            end
        end

        if args[1] == ".." then
            local dir = terminal:DirToString()

            local split = string.split(dir, "/")

            table.remove(split, #split)

            local dir = ""

            for i, v in pairs(split) do
                if i ~= 1 then
                    dir ..= "/" .. v
                else
                    dir ..= v
                end
            end

            terminal:SetDirWithString(dir)
        elseif terminal:IsString(s) then
            s = string.sub(s, 2, string.len(s) - 1)

            terminal.Dir = terminal:GetDirInDirFromString(s)
        elseif args[1] == "_" then
            terminal.Dir = game
        else
            if args[1] then
                local dir = terminal.Dir:FindFirstChild(args[1])

                if dir then
                    terminal.Dir = dir
                end
            end
        end
    end
}