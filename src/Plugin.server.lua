local Package = script.Parent

local Packages = Package.Packages
local Lib = Package.Lib

local Reducer = require(Package.Reducer)
local Actions = require(Package.Actions)

local Rodux = require(Packages.Rodux)

local Terminal = require(Lib.Terminal)

local store = Rodux.Store.new(Reducer, nil, {Rodux.thunkMiddleware})

do
    store:dispatch(Actions.GetPluginMeta())
end

local terminal = Terminal.new(plugin, store)

plugin.Unloading:Connect(function()
    terminal:Destroy()
end)