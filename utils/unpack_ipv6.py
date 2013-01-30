import socket
import binascii
import struct
from IPy import IP

ipv4_recv_port = 4123


# Listen for incoming UDP packets on IPv4
# These packets should have IPv6 packets in the UDP payload
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind(('0.0.0.0', ipv4_recv_port))

# Open a socket to dump the IPv6 packets
s2 = socket.socket(socket.AF_INET6, socket.SOCK_RAW, socket.IPPROTO_RAW)
s2.setsockopt(socket.IPPROTO_IPV6, socket.IP_HDRINCL, 1);

while True:
	d, a = s.recvfrom(2048)

	# Check IP version number
	version = struct.unpack('B', d[0])[0] >> 4
	if version != 6:
		# not an ipv6 packet in the payload
		continue

	# Get destination ip
	dstip = IP(binascii.hexlify(d[24:40]))
	dst = socket.getaddrinfo(str(dstip), None)[0][-1]

	s2.sendto(d, dst)
