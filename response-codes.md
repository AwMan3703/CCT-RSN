# RSN Response codes
#### Request processed successfully
- 100 - SUCCESS
	- resource in response body (if applicable).
- 101 - SUCCESS + NOTES
	- resource in response body (if applicable).
	- additional human-readable notes in response body.
#### Client fault
- *200 - CLIENT FAULT does not exist, as the server cannot determine wether the client really is at fault, it can only analyze the requests.*
- 201 - BAD REQUEST
	- human readable details about the request's faults in response body.
- 202 - REQUEST NOT SENT
		*the client API has refused to send the request to the server*
	- human readable details about the error in the response body.
#### Server fault
- 300 - SERVER FAULT
	- error message in response body.
- 301 - SERVER UNAVAILABLE
	- error message in response body.
- 302 - NO RESPONSE
		*server did not respond.*
- 303 - SERVICE DENIED
		*server has refused to process the request.*
- 304 - UNABLE TO RETRIEVE
		*resource exists, but cannot be retrieved (server cannot reach it). In case of inexistent resource, see 404.*
	- error message in response body.
#### Cannot provide resource
- 400 - CANNOT PROVIDE
	- error message in response body.
- 401 - ACCESS FORBIDDEN
		*resource cannot be provided to client.*
	- error message in response body.
- 404 - NOT FOUND
		*resource was not found. In case of existing but unretrievable resource, see 304*
	- error message in response body.
#### Cache updates / validation
*response codes for checking whether cache is still valid. A dedicated method should be used for this type of request and the last cache date should be passed in the request.*
- 500 - NOT MODIFIED
	- cached resource still works.
- 501 - MODIFIED
	- cached resource no longer works.
	- response body contains new resource, client should update local cache with it.
#### Other
- 999 - OTHER RESPONSE TYPE
		*request was not handled in any of the defined ways.*
	- information message in response body.
#### Custom
- 100X - CUSTOM
		*custom / domain-specific response codes can range from 1000 to infinity*


## Response code details
*a DETAIL is a letter that can be integrated with the response code to better describe what happened. Append with a dash: `[response code]-[detail]`*

- R - REDIRECTED
	*the request was redirected to a new location before being processed*
	- redirection details in response body, specifying the path followed to find the resource (e.g. in json), may also contain human-readable notes about the redirection.
	- (optional) human-readable updates in response body, specifying a new method/location to access the resource.
### Examples:
**101-R**: Request was redirected and then successfully returned with notes