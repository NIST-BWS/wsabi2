#wsabi connectivity design
* When selecting a person's record, all items in that record should try to
	* Register using their sensor config
	* Store the resulting session ID
	* Get service info and store it somewhere
	* Grab the lock and initialize
* If the lock isn't available...
	* Exponential backoff?
unlock
get service info
initialize
get configuration 
set configuration
capture
download get download info 
thrifty download
cancel operation
