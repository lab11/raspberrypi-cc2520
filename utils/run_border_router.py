#!/usr/bin/env python2

import sh
from sh import cat
from sh import ifconfig
from sh import grep
from sh import pkill
from sh import ps
from sh import screen
from sh import sudo

import IPy
import time
import subprocess


IPV6TUNNEL_INTERFACE = 'ipv6-umich'
BORDERROUTER_INTERFACE = 'tun-br'

def is_ipv6_tunnel ():
	try:
		ifconfig(IPV6TUNNEL_INTERFACE)
		return True
	except Exception:
		return False


# Returns a string of the IPv6 prefix the ipv6tunnel interface was assigned
# or None if the tunnel setup failed.
def get_ipv6_tunnel_prefix ():
	try:
		out = ifconfig(IPV6TUNNEL_INTERFACE)
		lines = out.split('\n')

		# Look for a line with a global address in it
		for line in lines:
			if 'Scope:Global' in line:
				segments = line.split()

				# Find the portion of the line that has '::1/128'
				for segment in segments:
					try:
						# Split the prefix (assuming it has one) from the
						# rest of the address so that IPy works.
						addr_pieces = segment.split('/')
						ipaddr = IPy.IP(addr_pieces[0])

						# Get the just the upper 64 bits
						prefix = ipaddr.int() & 0xFFFFFFFFFFFFFFFF0000000000000000
						return str(IPy.IP(prefix)) + '/64'
					except Exception:
						pass
		return None
	except sh.ErrorReturnCode_1:
		# This is what happens when the interface doesn't exist
		print('Could not find IPv6 Tunnel interface.')
		return None
	except Exception:
		# Catch all
		return None



## Step 1
## Check if the IPv6 tunnel is already set up
if not is_ipv6_tunnel():
	## Step 2
	## If the tunnel is not there, run the tunnel application
	print('IPv6 Tunnel not found.')
	print('Starting ipv6tunnel-client.')	
	subprocess.call(["screen", "-d", "-m", "-S", "ipv6-tunnel", "sudo", "./ipv6tunnel-client"])


## Step 3
## Get the prefix, or wait until we get one
print('Attempting to determine IPv6 prefix.')
prefix = ''
while True:
	prefix = get_ipv6_tunnel_prefix()
	print('Got prefix: {}'.format(prefix))
	if prefix:
		break
	else:
		time.sleep(1)

## Step 4
## Configure radvd to use that prefix
print('Creating radvd.conf')
with open('radvd.conf.in') as fin:
	conf = fin.read()
	confout = conf.replace('%PREFIX%', prefix)
	confout = confout.replace('%INTERFACE%', BORDERROUTER_INTERFACE)
	with open('radvd.conf', 'w') as fout:
		fout.write(confout)

## Step 5
## Run radvd
try:
	out = grep(ps('-A'), 'radvd')
	print('radvd is already running.')
	print('killing radvd...')
	sudo.pkill('-9', 'radvd')
	time.sleep(2)
except Exception:
	# Nothing was found
	pass
print('Starting radvd.')
#subprocess.call(["sudo", "./radvd", "-C", "./radvd.conf"])
print(subprocess.check_output(["screen", "-d", "-m", "-S", "radvd", "sudo", "./radvd", "-C", "./radvd.conf", "--nodaemon"]))
#print(subprocess.check_output("sudo ./radvd -C ./radvd.conf", shell=True))
#sudo('./radvd', '-C', './radvd.conf')

## Step 6
## Run the BorderRouter
try:
	out = grep(ps('-A'), 'BorderRouterC')
	print('BorderRouter already running.')
	print('Killing BorderRouter...')
	sudo.pkill('-9', 'BorderRouterC')
except Exception:
	pass
print('Starting Border Router.')
subprocess.call(["screen", "-d", "-m", "-S", "border-router", "sudo", "./BorderRouterC", '-i', BORDERROUTER_INTERFACE])

