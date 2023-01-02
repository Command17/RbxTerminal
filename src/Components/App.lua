local Package = script.Parent.Parent

local Packages = Package.Packages
local Components = Package.Components

local Roact = require(Packages.Roact)
local Hooks = require(Packages.Hooks)
local RoduxHooks = require(Packages.RoduxHooks)
local StudioPlugin = require(Packages.StudioPlugin)
local StudioTheme = require(Packages.StudioTheme)

local Icons = require(Package.Icons)

local Background = require(Components.Background)

local e = Roact.createElement

type AppProps = {
    plugin: Plugin,
}

local function app(props: AppProps, hooks)
    local widgetVisible, setWidgetVisible = hooks.useState(false)

    local pluginMeta = RoduxHooks.useSelector(hooks, function(state)
        return state.plugin_meta
    end)

    local _update = RoduxHooks.useSelector(hooks, function(state)
        return state.update
    end)

    local _update_v = hooks.useMemo(function()
        return _update.update
    end, {_update})

    local version = hooks.useMemo(function()
        return pluginMeta.version
    end, {pluginMeta})

    local build = hooks.useMemo(function()
        return pluginMeta.build
    end, {pluginMeta})

    return e(StudioPlugin.Plugin, {
        plugin = props.plugin
    }, {
        toolbar = e(StudioPlugin.Toolbar, {
            name = "RbxTerminal"
        }, {
            openWidget = e(StudioPlugin.ToolbarButton, {
                id = "openWidget",
                label = "Open Terminal",
                icon = Icons["build-" .. build],
                active = widgetVisible,

                onActivated = function()
                    setWidgetVisible(not widgetVisible)
                end
            })
        }),

        widget = e(StudioPlugin.Widget, {
            id = "rbxTerminalWidget",
            title = "Terminal [" .. version .. "]",
            enabled = widgetVisible,
            initState = Enum.InitialDockState.Float,

            onToggle = setWidgetVisible,
            onInit = setWidgetVisible
        }, {
            themeProvider = e(StudioTheme.Provider, {}, {
                background = e(Background, {}, props[Roact.Children])
            })
        })
    })
end

return Hooks.new(Roact)(app)