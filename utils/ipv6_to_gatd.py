#!/usr/bin/env python

"""
Creates a psuedo tunnel from a source machine to the gatd server.

Does this by creating a tun device that all packets bound for gatd are
routed to, extracting the IPv6 packet payload and relevant headers from such
packets, and then sending them on as udp packets via ipv4.
"""

import sys

try:
	import dpkt
except:
	print('Need dpkt.')
	print('sudo apt-get install python-dpkt')
	sys.exit(1)
import pytun
from sh import ifconfig
from sh import ip

import base64
import json
import socket
import struct

GATD_HOST = 'inductor.eecs.umich.edu'
GATD_PORT = 16284

#Create a tun device and setup the configuration to it
tun = pytun.TunTapDevice(name='ipv6gatd')
ifconfig(tun.name, 'up')
ifconfig(tun.name, 'mtu', '1280')
ip('-6', 'route', 'add', '2001:470:1f10:1320::2/128', 'dev', tun.name)

# Parameters for the ipv4 connection to gatd
gatdsock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
gatdaddr = (GATD_HOST, GATD_PORT)

# Loop waiting for packets to get routed to this tun interface, strip them,
# and send the import bits back to gatd
while True:
	buf = tun.read(1280)
	pkt = dpkt.ip6.IP6(buf[4:])

	if type(pkt.data) != dpkt.udp.UDP:
		continue

	gatdpkt = {}

	srcints = struct.unpack('>QQ', pkt.src)
	gatdpkt['src'] = int('0x{:0>16x}{:0>16x}'.format(*srcints), 16)
	gatdpkt['srcport'] = pkt.data.sport
	gatdpkt['dstport'] = pkt.data.dport
	gatdpkt['data'] = base64.b64encode(bytes(pkt.data.data))

	outpkt = json.dumps(gatdpkt)

	gatdsock.sendto(outpkt, gatdaddr)


tun.close()
