-- CONFIG
local PROTOCOL = 'RSN'
local IS_SERVER_RUNNING = false
local METHODS = {
    GET = 'GET',
    PUT = 'PUT'
}


-- FUNCTIONS

local function setup(hostname, request_processor, modem, cooldown)

    -- Generate a start and stop function
    return

    -- START
    function ()
        local MODEM
        -- find/open a modem according to README

        rednet.host(PROTOCOL, hostname)

        repeat
            local senderId, message, protocol = rednet.receive(PROTOCOL, 5)
            if not senderId then goto continue end

            local status, response_content = request_processor(senderId)
            local response = { status = status, body = response_content }

            rednet.send(senderId, response, protocol)

            ::continue::
            sleep(math.max(0.01, cooldown or 0.1))
        until not IS_SERVER_RUNNING
    end,

    -- STOP
    function ()
        rednet.unhost(PROTOCOL, hostname)

        IS_SERVER_RUNNING = false
    end
end


-- PREDEFINED REQUEST PROCESSORS

local requestProcessors -- table to hold them

function requestProcessors.static(path)
    return function (senderId, method, body, protocol)
        -- 
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