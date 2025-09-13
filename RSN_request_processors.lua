-- CONFIG
local PROTOCOL = 'RSN'
local METHODS = {
    GET = 'GET',
    PUT = 'PUT'
}


-- FUNCTIONS

local function readFile(path)
    if not fs.exists(path) then return nil end
    local fh = fs.open(path, 'r')
    local content = fh.readAll()
    fh.close()
    return content
end

local function writeFile(path, content)
    local fh = fs.open(path, 'w')
    fh.write(content)
    fh.close()
    return true
end


-- PREDEFINED REQUEST PROCESSORS

local requestProcessors = {} -- table to hold them

function requestProcessors.static(directory)
    return function (senderId, method, request, protocol)
        if method == METHODS.GET then
            local path = fs.combine(directory, request.path)
            if not fs.exists(path) then return 404, 'Not found' end
            local content = readFile(path)
            return 100, content
        elseif method == METHODS.PUT then
            local path = fs.combine(directory, request.path)
            local success = writeFile(path, request.body)
            return 100, nil
        else
            return 201, '"'..method..'" is not a valid method'
        end
    end
end

function requestProcessors.sandboxed(directory)
    local static = requestProcessors.static(directory)
    return function (senderId, method, request, protocol)
        request.path = fs.combine(tostring(senderId), request.path)
        return static(senderId, method, request, protocol)
    end
end

function requestProcessors.echo()
    return function (senderId, method, request, protocol)
        return 100, request.body
    end
end


-- RETURN THE LIBRARY

return requestProcessors