local Package = script.Parent.Parent

local HttpService = game:GetService("HttpService")

local Packages = Package.Packages

local Promise = require(Packages.Promise)

local function Request(url: string, nocache: boolean?, headers: any?)
    return Promise.new(function(resolve, reject)
        local succes, data = pcall(function()
            return HttpService:GetAsync(url, nocache, headers)
        end)

        if succes then
            resolve({
                succes = true,
                data = data
            })
        else
            resolve({
                succes = false,
                data = data
            })
        end
    end)
end

local function Send(url: string, data: string, content_type: Enum.HttpContentType?, compress: boolean?, headers: any?)
    return Promise.new(function(resolve, reject)
        local succes, data = pcall(function()
            return HttpService:PostAsync(url, data, content_type, compress, headers)
        end)

        if succes then
            resolve({
                succes = true,
                data = data
            })
        else
            resolve({
                succes = false,
                data = data
            })
        end
    end)
end

local function DecodeJSON(s: string)
    return HttpService:JSONDecode(s)
end

local function EncodeJSON(t: {any})
    return HttpService:JSONEncode(t)
end

return {
    Send = Send,
    Request = Request,
    DecodeJSON = DecodeJSON,
    EncodeJSON = EncodeJSON
}