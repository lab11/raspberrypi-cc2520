BorderRouter
============

This app may very well grow into the TinyOS app that turns the rpi into a border router.


Testing 1/20/2012
-----------------

Right now this is setup to test the TunC/P interface to linux land. A mote running Node
sends packets destined for an address outside of the border router and BLIP dumps them
to tun0.

1. Add an IPv6 address for the rpi. The Node app is setup to use 2001:638:709:1235::1

    sudo ifconfig eth0 inet6 add 2001:638:709:1235::1/128

2. Run BorderRouter on the rpi.
3. Run Node on another mote.
4. On the rpi:
    
	sudo tcpdump -i tun0

5. Optional: run utils/mcast.py on the pi and watch the top level border router app print the size
of the packets.

