local Package = script.Parent.Parent

local Lib = Package.Lib

local HttpPromise = require(Lib.HttpPromise)

return function()
    local payload = {
        type = "GET_PLUGIN_META",
        payload = {
            build = "normal",
            version = "1.0.0",
            id = 1,
            latest = {
                version = "1.0.0",
                id = 1,
            }
        }
    }

    HttpPromise.Request("https://raw.githubusercontent.com/Command17/RbxTerminal/main/plugin_version.json"):andThen(function(data)
        if data and data.succes then
            local data = HttpPromise.DecodeJSON(data.data)

            payload.payload.latest.version = data.version
            payload.payload.latest.id = data.id

            if payload.payload.latest.id < payload.payload.id then
                payload.payload.build = "dev"
            end
        end
    end)

    return payload
end