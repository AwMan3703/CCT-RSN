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
            local request_method, response_status, response

            local senderId, request, protocol = rednet.receive(string.upper(PROTOCOL), 5)
            if not senderId then goto continue end

            -- extract the method and pass the rest
            request_method = request.method
            request.method = nil
            if not request_method then -- if no whitespace is present
                response_status, response = 201, "Request needs to have a <method> property"
            else -- process the request
                if not request.body then request.body = '' end
                response_status, response = request_processor(senderId, string.upper(request_method), request, protocol)
            end

            if type(response) ~= 'table' then response = { body = response } end
            response.status = response_status
            rednet.send(senderId, response, protocol)

            ::continue::
            sleep(math.max(0.01, cooldown or 0.1))
        until not IS_SERVER_RUNNING
    end,

    -- STOP
    function ()
        IS_SERVER_RUNNING = false

        rednet.unhost(string.upper(PROTOCOL), hostname)

        rednet.close(MODEM_SIDE)
    end
end


-- RETURN THE LIBRARY

return {
    setup = setup,
    methods = METHODS
}