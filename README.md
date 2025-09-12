# RSN - Resource Sharing Network protocol
Similar to HTTP, allows clients to make requests and servers to fulfill them.


### Request methods
- GET — requests that a resource be provided as a response
- PUT — requests that a reource be created or modified on the server


## How to setup a RSN server

#### Setup and run the server
1. In your code, get the server API with `local rsnServer = require("RSN_server")`
2. Setup the server and generate a start function with `local startFunction, stopFunction = rsnServer.setup(<hostname>, <request processor>, <cooldown>, <modem>)`
    - `hostname` The server's hostname
    - `request processor` (see "About request processors")
    - `modem` (optional) The peripheral name of the modem to transmit through. If this is not provided, a random open modem will be used. If no modem is open but this is set to `"auto"`, a random one will be opened.
    - `cooldown` (optional) The amount of seconds to wait between server loops (min 0.01)
3. Start the server with `startFunction()` and stop it with `stopFunction()`

### About request processors
A request processor is a simple function to be executed on every incoming message to this server. It should take four parameters: `senderId` (the computer ID of the request sender), `method` (one of the methods above, describing what to do with the request), `body` (the content of the request) and `protocol` (this will always be "rsn"). It should then return a `status code` (a number that describes the result of the request — e.g. if and how it succeeded, if errors occurred, etc... — see _./response-codes.md_) and a `response` (content that will be sent back as a response).

Predefined request processors are available in the RSN API (CALL these when setting up the server, don't pass the function themselves to `rsnServer.setup`):
- `rsnServer.requestProcessors.static(<path>)` — serves static files from a local directory
- `rsnServer.requestProcessors.echo()` — echoes the request's body back to the sender

Example of a custom request processor:
```
-- Echoes the content of the request back to the sender

local my_request_processor(senderId, method, body, protocol)
    
    -- log the request
    print('Request from #'...senderId...' under protocol "'...protocol...'"')
    
    -- check that the correct method was used
    if method == rsnServer.methods.GET then
        -- 100 = success
        return 100, body.." received!"
    else
        -- 201 = bad request
        return 201, ""
    end

end
```


## How to use RSN from the client

1. In your code, get the client library with `local rsn = require("RSN_client")`
2. Send requests with `local response = rsn.get(<server hostname>, <resource name>)` and upload/modify them with `local response = rsn.put(<server hostname>, <resource name>, <content>)`
    - `server hostname` The server to send the request to
    - `resource name` The resource's name (id, path, title, or whatever else)
    - `content` In PUT requests, the content to upload
3. Extract resources and status codes with `response.status` and `response.body`