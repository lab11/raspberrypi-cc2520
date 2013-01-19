#!/usr/bin/env python
#
# Send/receive UDP multicast packets.
# Requires that your OS kernel supports IP multicast.
#
# Usage:
#   mcast -s (sender, IPv4)
#   mcast -s -6 (sender, IPv6)
#   mcast    (receivers, IPv4)
#   mcast  -6  (receivers, IPv6)

MYPORT = 2007
MYGROUP_4 = '225.0.0.250'
MYGROUP_6 = 'fe80::fffe:12'
MYGROUP_6 = '2001:638:709:1234::fffe:11'
#me='fe80::2e41:38ff:fe89:9a2'
me='::1'
MYTTL = 10 # Increase to reach other networks

import time
import struct
import socket
import sys

def main():
    group = MYGROUP_6

    sender(group)



def sender(group):
    addrinfo = socket.getaddrinfo(group, None)[0]
    print addrinfo

    s = socket.socket(addrinfo[0], socket.SOCK_DGRAM)

    # Set Time-to-live (optional)
    ttl_bin = struct.pack('@i', MYTTL)
    if addrinfo[0] == socket.AF_INET: # IPv4
        s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, ttl_bin)
    else:
        s.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_MULTICAST_HOPS, ttl_bin)

   # mebind = socket.getaddrinfo(me, 2004)[0]
   # print mebind
   # s.bind(mebind[-1])

    while True:
        data = repr(time.time())
        s.sendto(data + '\0', (addrinfo[4][0], MYPORT))
        time.sleep(1)


if __name__ == '__main__':
    main()
