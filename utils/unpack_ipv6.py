import socket
import binascii
import struct
import json

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind(('0.0.0.0', 4124))


def chunks(l, n):
	return [l[i:i+n] for i in range(0, len(l), n)]



s2 = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_RAW)
#s2 = socket.socket(socket.AF_INET6, socket.SOCK_RAW, socket.IPPROTO_RAW)
#s2 = socket.socket(socket.AF_PACKET, socket.SOCK_DGRAM)
#s2.bind(('lo', 0))
print s2
#a = '6000000000203afffe80000000000000edf8b55c03e76e6dff0200000000000000000001ff4729c9'
#a = '60000000001011402607f018800abcdef0123456789100022607f018800abcdef012345678910001808d101c0010c171'

#a = '60000000001011ff2607f018800abcdef0123456789100022607f018800abcdef0123456789100030faa101c00107e0b70617373776f7264'
#a = '60000000001011ff260700000000000000000000000a00012607f018800abcdef0123456789100030faa101c0010fc4670617373776f7264'
a = '4510004c1234400040296baa8dd46ea58dd46ece60000000001011ff260700000000000000000000000a00012607f018800abcdef0123456789100030faa101c0010fc4670617373776f7264'
c = chunks(a, 2)
f = [int(x, 16) for x in c]
d = len(c)
e = struct.pack('!{0}B'.format(d), *f)
print e

#s2.setsockopt(socket.IPPROTO_IPV6, socket.IP_HDRINCL, 1);
s2.setsockopt(socket.IPPROTO_IP, socket.IP_HDRINCL, 1);
#for i in range(0, 150):
#	try:
#		s2.setsockopt(i, socket.IP_HDRINCL, 1);
#		print i
#	except Exception:
#		pass

r='2607:f018:800a:bcde:f012:3456:7891:1'
t=socket.getaddrinfo(r, None)[0][-1]
print t
while True:
	d, a = s.recvfrom(1024)
	print binascii.hexlify(d)
	a = s2.sendto(e,('141.212.110.206', 4989))
	#a = s2.sendto(d,t)
	#a = s2.send(d)
	#a = s2.send(d)
	print a
"""



while True:
	d, a = s.recvfrom(1024)
	data = json.loads(d)
	print data
	s2 = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
	s2.connect((data['dst_ipv6'], data['dst_port']))
	s2.send(data['data'])
	s2.close()


260700000000000000000000000a0001
2607f018800abcdef012345678910003
00000010
00000000
0faa
101c
0010
0000
70617373776f7264

"""
