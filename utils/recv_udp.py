
import socket

me = '2001:638:709:1235::1'

mebind = socket.getaddrinfo(me, 2001)[0]

s = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)

s.bind(mebind[-1])

while True:
	print s.recvfrom(100)


