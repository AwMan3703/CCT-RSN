
## RSN Response codes
#### Request processed successfully
- 100 - SUCCESS
	- resource in response body (if applicable).
- 101 - SUCCESS + NOTES
	- resource in response body (if applicable).
	- additional human-readable notes in response body.
#### Client fault
- *200 - CLIENT FAULT does not exist, as the server cannot determine wether the client has a defect, it can only analyze the requests.*
- 201 - BAD REQUEST
	- human readable details about the errors in the request in response body.
	- (optional) machine-readable details on how to adapt and send good requests.
#### Server fault
- 300 - SERVER FAULT
	- error message in response body.
- 301 - SERVER UNAVAILABLE
	- error message in response body.
- 302 - UNABLE TO RETRIEVE
		*resource exists, but cannot be retrieved (server cannot reach it). In case of inexistent resource, see 404.*
	- error message in response body.
#### Cannot return resource
- 400 - CANNOT RETURN
	- error message in response body.
- 401 - INSUFFICIENT PERMISSIONS
		*client does not have sufficient permission for access, client is blacklisted, client is not whitelisted, resource is locked behind paywall. For other reasons, see 402.*
	- error message in response body
- 402 - ACCESS FORBIDDEN
		*resource cannot be distributed.*
	- error message in response body.
- 404 - NOT FOUND
		*resource was not found. In case of existing but unretrievable resource, see 302. In case of existing but unavailable resource see 403*
	- error message in response body.
#### Cache updates / validation
*response codes for checking whether cache is still valid. Last cache date should be passed in the request.*
- 500 - NOT MODIFIED
	- cached resource still works.
- 501 - MODIFIED
	- cached resource no longer works.
	- response body contains new resource, client should update local cache with it.
#### Other
- 901 - REFUSED TO PROCESS
		*server refused to process the request.*
	- information message in response body.
- 999 - OTHER RESPONSE TYPE
		*request was not handled in any of the defined ways.*
	- information message in response body.
#### Custom
- 100X - CUSTOM
		*custom / domain-specific response codes can range from 1001 to infinity*
## Response code details
*a DETAIL is a letter that can be integrated with the response code to better describe what happened. Append with a dash:* `[response code]-[detail]`
#### Redirected
- R - REDIRECTED
	*the request was redirected to a new location before being processed*
	- redirection details in response body, specifying the path followed to find the resource (e.g. in json), may also contain human-readable notes about the redirection.
	- updates in response body, specifying other access methods to try for new location - may also contain human-readable notes about the update.
### Examples:
**101-R**: Request was redirected and then successfully returned with notes