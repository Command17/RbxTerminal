local GetPluginMeta = require(script.GetPluginMeta)
local Update = require(script.Update)

return function(state, action)
    state = state or {}

    return {
        plugin_meta = GetPluginMeta(state.plugin_meta, action),
        update = Update(state.update, action)
    }
end