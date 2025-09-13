-- CONFIG
local PROTOCOL = 'RSN'
local METHODS = {
    GET = 'GET',
    PUT = 'PUT'
}


-- PREDEFINED REQUEST PROCESSORS

local requestProcessors = {} -- table to hold them

function requestProcessors.static(directory)
    return function (senderId, method, request, protocol)
        if method == METHODS.GET then
            local path = fs.combine(directory, request.path)
            if not fs.exists(path) then return 404, '"./'..path..'" not found.' end
            local fh = fs.open(path, 'r')
            local content = fh.readAll()
            fh.close()
            return 100, content
        elseif method == METHODS.PUT then
            local path = fs.combine(directory, request.path)
            local fh = fs.open(path, 'w')
            fh.write(request.body)
            fh.close()
            return 100, nil
        else
            return 201, '"'..method..'" is not a valid method.'
        end
    end
end

function requestProcessors.echo()
    return function (senderId, method, request, protocol)
        return 100, request
    end
end


-- RETURN THE LIBRARY

return requestProcessors