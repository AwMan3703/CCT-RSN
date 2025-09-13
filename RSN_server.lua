-- CONFIG
local PROTOCOL = 'RSN'
local METHODS = {
    GET = 'GET',
    PUT = 'PUT'
}
-- RUNTIME
local IS_SERVER_RUNNING = false
local MODEM_SIDE


-- FUNCTIONS

local function findModemWithPreferred(preferred_modem)
    -- if a preferred modem is present and valid, return it
    if preferred_modem and preferred_modem ~= "auto" then
        local wrapped = peripheral.wrap(preferred_modem)
        if wrapped then return wrapped end
    end

    -- otherwise, look for an open modem
    local peripheral_names = peripheral.getNames()
    local all_modems = {}
    for _, peripheral_name in ipairs(peripheral_names) do
        -- check that we're working with a modem
        if peripheral.getType(peripheral_name) ~= "modem" then goto continue end

        -- if the modem is open, return it right away
        if rednet.isOpen(peripheral_name) then return peripheral_name
        -- otherwise, add it to all_modems for later fallback
        else table.insert(all_modems, peripheral_name) end

        ::continue::
    end

    -- if no open modem is found, return any modem
    if #all_modems > 0 then return all_modems[1]
    else error("No modem attached!") end
end

local function setup(hostname, request_processor, modem, cooldown)

    MODEM_SIDE = findModemWithPreferred(modem)
    print('Will host from modem: '..MODEM_SIDE)

    -- Generate a start and stop function
    return

    -- START
    function ()
        rednet.open(MODEM_SIDE)

        rednet.host(string.upper(PROTOCOL), hostname)

        print('Now hosting '..string.lower(PROTOCOL)..'://'..hostname..'')
        IS_SERVER_RUNNING = true

        repeat
            local request_method, request_body, response_status, response_body, response

            local senderId, message, protocol = rednet.receive(string.upper(PROTOCOL), 5)
            if not senderId then goto continue end

            -- message="GET myresource"  ->  method="GET" body="myresource"
            request_method, request_body = message:match("^(%S+)%s+(.*)$")
            if not request_method then -- if no whitespace is present
                response_status, response_body = 201, "Request needs to start with a method, followed by a whitespace and the request body."
            else -- process the request
                response_status, response_body = request_processor(senderId, string.upper(request_method), request_body, protocol)
            end

            response = { status = response_status, body = response_body }
            rednet.send(senderId, response, protocol)

            ::continue::
            sleep(math.max(0.01, cooldown or 0.1))
        until not IS_SERVER_RUNNING
    end,

    -- STOP
    function ()
        rednet.unhost(string.upper(PROTOCOL), hostname)

        rednet.close(MODEM_SIDE)

        IS_SERVER_RUNNING = false
    end
end


-- PREDEFINED REQUEST PROCESSORS

local requestProcessors = {} -- table to hold them

function requestProcessors.static(directory)
    return function (senderId, method, body, protocol)
        if method == METHODS.GET then
            local path = fs.combine(directory, body)
            if not fs.exists(path) then return 404, '"./'..path..'" not found.' end
            local fh = fs.open(path, 'r')
            local content = fh.readAll()
            fh.close()
            return 100, content
        elseif method == METHODS.PUT then
            local target, content = body:match("^(%S+)%s+(.*)$")
            local path = fs.combine(directory, target)
            local fh = fs.open(path, 'w')
            fh.write(content)
            fh.close()
        else
            return 201, '"'..method..'" is not a valid method.'
        end
    end
end

function requestProcessors.echo()
    return function (senderId, method, body, protocol)
        return 100, body
    end
end


-- RETURN THE LIBRARY

return {
    setup = setup,
    methods = METHODS,
    requestProcessors = requestProcessors
}