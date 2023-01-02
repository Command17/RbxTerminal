local Package = script.Parent.Parent

local Packages = Package.Packages

local Stift = require(Packages.Sift)

return function(state, action)
    state = state or {
        build = "",
        version = "",
        id = 0,
        latest = {
            version = "",
            id = 0,
        }
    }

    if action.type == "GET_PLUGIN_META" then
        return Stift.Dictionary.mergeDeep(state, action.payload)
    end

    return state
end