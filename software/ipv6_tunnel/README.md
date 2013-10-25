Stateful IPv6 Over IPv4 Tunnel
==============================

This software provides a mechanism for operating an IPv6 over IPv4 tunnel. While
many protocols and software packages provide similar support, each has their own
drawbacks.

- Hurricane Electric Tunnel: Does not work through NATs. Requires each endpoint
to have a public IPv4 address. This is obviously not practical in home
situations.
- Teredo: Unreliable. Had trouble routing to Hurricane Electric prefixes.
- Other: require closed source applications and registering each tunnel.

Operation
---------

This tunnel server operates by listening for TCP connections on an IPv4 port.
When a client connects, the server keeps the connection open and routes any
IPv6 packets to and from the client over the TCP socket.

Upon initially connecting, the server assigns a /64 prefix to the client. All
packets destined (from the Internet) to that prefix will be routed to that
client via TCP. This allows the connecting client to act as a router for that
prefix.

Implementation
--------------

The server starts by listening for all TCP connections on a certain port.
When a client connects, it waits for the client to send a JSON blob containing
a unique ID (typically a MAC address). The blob looks like:

    {"Id": "00:11:22:aa:bb:cc"}

The server then checks if it has seen that ID before, and if so it responds
with the prefix that has already been assigned to that client. If not, it
generates a new prefix from the pool of available prefixes (usually a /56 or
larger). The prefix will always be a /64. The response looks like:

    {"Prefix": "2000:aaaa:bbbb:ccdd::/64"}

The server then generates a TUN interface and adds a route for all packets
matching that prefix to be sent to that TUN interface. The server then listens
on the TUN interface and on the TCP socket and routes all received packets
accordingly.

The client operation is very similar. It initiates the TCP request and creates
a TUN device. All IPv6 traffic is routed to this TUN device. It too listens
on both file descriptors and moves packets between them as needed.

If the client disconnects, the server's TUN device for that client is removed.
If the client reconnects, the same prefix is assigned and this proceed
normally. If the server goes down, the client will try to reconnect every two
seconds. All outgoing TCP traffic will buffer in the TUN device and all
incoming traffic will be dropped before it reaches the client. As soon as the
server comes back the client will reconnect and operate as before.

Usage
-----

### Compile

To build the server and client:

    tup variant configs/*
    tup

This will require Go. To cross compile for arm you will need to cross compile
Go first. Rough steps:

    hg clone https://code.google.com/p/go/
    cd go/src
    GOOS=linux GOARCH=arm ./make.bash

Then in `ipv6_tunnel/variants/rpi.config` you will need to change the
`CONFIG_GOROOT` variable to point to the correct directory.

### Setup Linux

In order to convince Linux to forward packets between the TUN interface and
other network devices you need to configure it:

    sudo echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

### Configuration

A config.ini file is used to control the operation of the server and client.

#### Server Config

    [server]
    localhost = local ip address to bind to
    listenport = local port to listen for TCP connections from clients
    prefixrange = prefix pool to assign from (ex: 2000:aa:bbb:0::/48)
    assignments = optional file to store prefix assignments in

#### Client Config

    [client]
    remotehost = hostname or IP address of the server
    remoteport = port the server is listening on

### Running

    server:
    touch <assignmentfile>
    sudo ./server

    client
    sudo ./client


