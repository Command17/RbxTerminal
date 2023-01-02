local Package = script.Parent.Parent.Parent

local Packages = Package.Packages

local TestEZ = require(Packages.TestEZ)

return {
    Name = "BuildInCommands",
    Version = "1.0.0",

    ["clear"] = function(args, flags, terminal)
        terminal:Clear()
    end,

    ["help"] = function(args, flags, terminal)
        terminal:CreateMessage("CMD: echo ARGS: \"text\" FLAGS: --r RED --b BLUE --y YELLOW --g GREEN --p PURPLE --o ORANGE", "Green")
        terminal:CreateMessage("CMD: cd ARGS: \"dir/dir\", dir, .., _ FLAGS: ----", "Green")
        terminal:CreateMessage("CMD: packages:", "Green")
        terminal:CreateMessage("    SUB-CMD: version ARGS: Package FLAGS: ----", "Green")
        terminal:CreateMessage("    SUB-CMD: install ARGS: Package FLAGS: ----", "Green")
        terminal:CreateMessage("    SUB-CMD: uninstall ARGS: Package FLAGS: ----", "Green")
        terminal:CreateMessage("    SUB-CMD: show ARGS: ---- FLAGS: --version | -v", "Green")
        terminal:CreateMessage("CMD: testez:", "Green")
        terminal:CreateMessage("    SUB-CMD: test ARGS: dir FLAGS: --child | -c, --parent | -p", "Green")
        terminal:CreateMessage("CMD: settings:", "Green")
        terminal:CreateMessage("    SUB-CMD: set ARGS: setting, bool FLAGS: ----", "Green")
        terminal:CreateMessage("    SUB-CMD: get ARGS: setting FLAGS: ----", "Green")
        terminal:CreateMessage("CMD: run ARGS: dir", "Green")
    end,

    ["packages"] = {
        ["version"] = function(args, flags, terminal)
            local package = args[1]

            if package then
                local registeredPackage = terminal.Packages[package]

                if registeredPackage then
                    terminal:CreateMessage("Package is on version: " .. registeredPackage.Version, "Orange")
                else
                    terminal:CreateMessage("Package does not exist!", "Red")
                end
            else
                terminal:CreateMessage("Invalid Option.", "Red")
            end
        end,

        ["install"] = function(args, flags, terminal)
            if #args < 1 then
                local spec = terminal.Dir
    
                if spec and spec:IsA("ModuleScript") then
                    terminal:AddPackage(spec)
                    
                    terminal:CreateMessage("Asked to add Package.", "Orange")
                else
                    terminal:CreateMessage("Current file does not exist or is not a ModuleScript!", "Red")
                end
            elseif #args > 0 then
                local s = ""
    
                for i, v in pairs(args) do
                    if i ~= #args then
                        s ..= v .. " "
                    else
                        s ..= v
                    end
                end
    
                if terminal:IsString(s) then
                    s = string.sub(s, 2, string.len(s) - 1)
    
                    local spec = terminal:GetDirInDirFromString(s)
    
                    if spec and spec:IsA("ModuleScript") then
                        terminal:AddPackage(spec)
                    
                        terminal:CreateMessage("Asked to add Package.", "Orange")
                    else
                        terminal:CreateMessage("Current file does not exist or is not a ModuleScript!", "Red")
                    end
                else
                    local spec = terminal.Dir:FindFirstChild(args[1])
    
                    if spec and spec:IsA("ModuleScript") then
                        terminal:AddPackage(spec)
                    
                        terminal:CreateMessage("Asked to add Package.", "Orange")
                    else
                        terminal:CreateMessage("Current file does not exist or is not a ModuleScript!", "Red")
                    end
                end
            else
                terminal:CreateMessage("Invalid Option. How did you do this??", "Red")
            end
        end,

        ["uninstall"] = function(args, flags, terminal)
            local package = args[1]

            if package then
                terminal:RemovePackage(package)

                terminal:CreateMessage("Asked to remove Package.", "Orange")
            else
                terminal:CreateMessage("Invalid argument.", "Red")
            end
        end,

        ["show"] = function(args, flags, terminal)
            if terminal:IsFlag(flags[1], "--version", "-v") then
                for i, v in pairs(terminal.Packages) do
                    terminal:CreateMessage("Package: " .. i .. "- version: " .. v.Version, "Orange")
                end
            else
                for i, v in pairs(terminal.Packages) do
                    terminal:CreateMessage(i, "Orange")
                end
            end
        end
    },

    ["testez"] = {
        ["test"] = function(args, flags, terminal)
            if #args < 1 then
                local spec = terminal.Dir

                if spec and spec:IsA("ModuleScript") and terminal:IsFlag(flags[1], "--child", "-c") then
                    spec = spec:FindFirstChild(spec.Name .. ".spec") or spec:FindFirstChild("init.spec")
                elseif spec and spec:IsA("ModuleScript") and terminal:IsFlag(flags[1], "--parent", "-p") then
                    spec = spec.Parent:FindFirstChild(spec.Name .. ".spec")
                end

                if spec and spec:IsA("ModuleScript") then
                    if string.match(spec.Name, ".....$") == ".spec" then
                        terminal:CreateMessage("Running Tests...", "Green")

                        TestEZ.TestBootstrap:run({spec})

                        terminal:CreateMessage("Did Tests! The result should already be printed.", "Green")
                    else
                        terminal:CreateMessage("Current file is not a .spec file!", "Red")
                    end
                else
                    terminal:CreateMessage("Current file does not exist or is not a ModuleScript!", "Red")
                end
            elseif #args > 0 then
                local s = ""

                for i, v in pairs(args) do
                    if i ~= #args then
                        s ..= v .. " "
                    else
                        s ..= v
                    end
                end

                if terminal:IsString(s) then
                    s = string.sub(s, 2, string.len(s) - 1)

                    local spec = terminal:GetDirInDirFromString(s)

                    if spec and spec:IsA("ModuleScript") and terminal:IsFlag(flags[1], "--child", "-c") then
                        spec = spec:FindFirstChild(spec.Name .. ".spec") or spec:FindFirstChild("init.spec")
                    elseif spec and spec:IsA("ModuleScript") and terminal:IsFlag(flags[1], "--parent", "-p") then
                        spec = spec.Parent:FindFirstChild(spec.Name .. ".spec")
                    end

                    if spec and spec:IsA("ModuleScript") then
                        if string.match(spec.Name, ".....$") == ".spec" then
                            terminal:CreateMessage("Running Tests...", "Green")
    
                            TestEZ.TestBootstrap:run({spec})
    
                            terminal:CreateMessage("Did Tests! The result should already be printed.", "Green")
                        else
                            terminal:CreateMessage("Current file is not a .spec file!", "Red")
                        end
                    else
                        terminal:CreateMessage("Current file does not exist or is not a ModuleScript!", "Red")
                    end
                else
                    local spec = terminal.Dir:FindFirstChild(args[1])

                    if spec and spec:IsA("ModuleScript") and terminal:IsFlag(flags[1], "--child", "-c") then
                        spec = spec:FindFirstChild(spec.Name .. ".spec") or spec:FindFirstChild("init.spec")
                    elseif spec and spec:IsA("ModuleScript") and terminal:IsFlag(flags[1], "--parent", "-p") then
                        spec = spec.Parent:FindFirstChild(spec.Name .. ".spec")
                    end

                    if spec and spec:IsA("ModuleScript") then
                        if string.match(spec.Name, ".....$") == ".spec" then
                            terminal:CreateMessage("Running Tests...", "Green")
    
                            TestEZ.TestBootstrap:run({spec})
    
                            terminal:CreateMessage("Did Tests! The result should already be printed.", "Green")
                        else
                            terminal:CreateMessage("Current file is not a .spec file!", "Red")
                        end
                    else
                        terminal:CreateMessage("Current file does not exist or is not a ModuleScript!", "Red")
                    end
                end
            else
                terminal:CreateMessage("Invalid Option. How did you do this??", "Red")
            end
        end
    },

    ["settings"] = {
        ["set"] = function(args, flags, terminal)
            if args[1] and args[2] then
                local v = if args[2] == "true" then true else false

                terminal:SetSetting(args[1], v)
            else
                terminal:CreateMessage("One or two arguments are missing!.", "Red")
            end
        end,

        ["get"] = function(args, flags, terminal)
            if args[1] then
                terminal:CreateMessage("Current value for setting is: " .. tostring(terminal:GetSetting(args[1])), "Orange")
            end
        end
    },

    ["run"] = function(args, flags, terminal)
        if #args < 1 then
            local spec = terminal.Dir

            if spec and spec:IsA("ModuleScript") then
                if string.match(spec.Name, "....$") == ".bat" then
                    local batFile = require(spec)

                    if typeof(batFile) ~= "function" then
                        terminal:CreateMessage("Current bat file does not return a function!", "Red")
                    else
                        batFile(terminal)
                    end
                else
                    terminal:CreateMessage("Current file is not a .bat file!", "Red")
                end
            else
                terminal:CreateMessage("Current file does not exist or is not a ModuleScript!", "Red")
            end
        elseif #args > 0 then
            local s = ""

            for i, v in pairs(args) do
                if i ~= #args then
                    s ..= v .. " "
                else
                    s ..= v
                end
            end

            if terminal:IsString(s) then
                s = string.sub(s, 2, string.len(s) - 1)

                local spec = terminal:GetDirInDirFromString(s)

                if spec and spec:IsA("ModuleScript") then
                    if string.match(spec.Name, "....$") == ".bat" then
                        local batFile = require(spec)
    
                        if typeof(batFile) ~= "function" then
                            terminal:CreateMessage("Current bat file does not return a function!", "Red")
                        else
                            batFile(terminal)
                        end
                    else
                        terminal:CreateMessage("Current file is not a .bat file!", "Red")
                    end
                else
                    terminal:CreateMessage("Current file does not exist or is not a ModuleScript!", "Red")
                end
            else
                local spec = terminal.Dir:FindFirstChild(args[1])

                if spec and spec:IsA("ModuleScript") then
                    if string.match(spec.Name, "....$") == ".bat" then
                        local batFile = require(spec)
    
                        if typeof(batFile) ~= "function" then
                            terminal:CreateMessage("Current bat file does not return a function!", "Red")
                        else
                            batFile(terminal)
                        end
                    else
                        terminal:CreateMessage("Current file is not a .bat file!", "Red")
                    end
                else
                    terminal:CreateMessage("Current file does not exist or is not a ModuleScript!", "Red")
                end
            end
        else
            terminal:CreateMessage("Invalid Option. How did you do this??", "Red")
        end
    end
}