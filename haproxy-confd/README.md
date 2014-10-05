# Haproxy-confd

Confd setup to look for etcd entries in /services, and
update a haproxy instance accordingly.

Entries have the form:
/services/entryname
/services/entryname/scheme <- Possible values http,tcp
/services/entryname/host_port <- Optional, listen on this port for
incoming requests to this entry
/services/entryname/hosts/[1,2,3,4] <- Value is endpoints of IP:Port

Entries are then available by requesting the service with either
url path matching entryname or host header matching entryname, that is
(assuming host is localhost):

localhost/entryname
entryname.localhost (assuming correct host headers)

If the host_port entry is given a port value then

localhost:port

will also forward to the correct backend
