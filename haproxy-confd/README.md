# Haproxy-confd

Confd setup to look for etcd entries in /services, and
update a haproxy instance accordingly.

Entries have the form:

- /services/entryname
- /services/entryname/scheme
	- Possible values http,https,tcp
- /services/entryname/host_port
	- Optional, listen on this port for incoming requests to this entry
- /services/entryname/hosts/[1,2,3,4]
	- Value is endpoints of IP:Port

If the value of /config/services/ssl_support is "true" then ssl is
activated.
This works in the following way:

The ssl is terminated when hitting haproxy, and
continues forward as a plain http request. SSL .pem files must be
mounted in /keys folder. Haproxy will use this folder as crt. This
means that there must only be .pem files in the folder, and that there
MUST be at least one.

Entries are then available by requesting the service with either
url path matching entryname or host header matching entryname.

Example where host is localhost:

http://localhost/entryname
http://entryname.localhost

If the host_port entry is given a port value then

http://localhost:port

will also forward to the correct backend


See test.sh for usage example
