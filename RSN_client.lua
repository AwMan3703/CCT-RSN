-- CONFIG
local PROTOCOL = 'RSN'
local METHODS = {
    GET = 'GET',
    PUT = 'PUT'
}


-- FUNCTION

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

local function setup(modem)
    local modem_side = findModemWithPreferred(modem)
    rednet.open(modem)
end

local function enrichResponse(response)
    if not response then return response end

    if response.status then
        response.ok = response.status > 99 and response.status < 200 end

    return response
end

local function sendRequestAndAwaitResponse(hostname, method, body)
    local serverId = rednet.lookup(PROTOCOL, hostname)
    if not serverId then return enrichResponse({ status = 301, body = nil }), nil end

    rednet.send(serverId, string.upper(method).." "..body, PROTOCOL)

    local responderId, response, responseProtocol
    repeat
        responderId, response, responseProtocol = rednet.receive(PROTOCOL, 3)
    until (responderId == serverId) or (not response)

    if not response then return enrichResponse({ status = 901, body = nil }), nil end

    return enrichResponse(response), responderId
end

local function get(hostname, resource_name)
    return sendRequestAndAwaitResponse(hostname, METHODS.GET, resource_name)
end

local function put(hostname, resource_name, body)
    return sendRequestAndAwaitResponse(hostname, METHODS.PUT, resource_name.." "..body)
end


-- RETURN THE LIBRARY
return {
    setup = setup,
    methods = METHODS,
    lookup = rednet.lookup,
    request = sendRequestAndAwaitResponse,
    get = get,
    put = put
}