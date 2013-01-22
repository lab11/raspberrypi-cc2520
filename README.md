raspberrypi-cc2520
==================

Code, hardware, and instructions to use the TI CC2520 with the Raspberry Pi.


Installing the Software
-----------------------

### Kernel

You need the kernel module from https://github.com/ab500/linux-cc2520-driver.

You need to enable IPV6 on the RPI:

    sudo vim /etc/modules
    add ipv6 on a newline

If you want to run the border router application you need to enable interface forwarding:

    sudo vim /etc/sysctl.conf
    uncomment the line: net.ipv6.conf.all.forwarding=1

### TinyOS

You need a copy of the main TinyOS repository and the tinyos folder from this
repo. You also need to install the dependencies for TinyOS. There are
instructions here:
[http://docs.tinyos.net/tinywiki/index.php/Installing_TinyOS_2.1.1]. If you want
the simple Linux install I use, look here:
[http://energy.eecs.umich.edu/wiki/doku.php?id=tinyos_install].

#### Installation

The TinyOS code requires a library for the low level BCM2835 GPIO from
http://www.open.com.au/mikem/bcm2835/. Download and compile it on the RPI as
instructed on the website. In order to cross compile tinyos code on your machine
you also need the library and headers on your local machine. To build this on
your local machine:

    -insert code for that here-
    mv libbcm2835.a /usr/arm-linux-gnueabi/lib
    mv bcm2835.h /usr/arm-linux-gnueabi/include

In order for the TinyOS build system to figure out all the correct paths you
need to help it along a bit. Add the following to your `.bashrc` file:

    export TOSROOTRPI=<path to git repo>/tinyos
    export TOSMAKE_PATH="$TOSROOTRPI/support/make $TOSMAKE_PATH"

#### Usage

Assuming you have the correct compilers, you should be able to run the following
and have it compile successfully:

    cd tinyos-main/apps/Blink
    make raspberrypi

Then copy `build/raspberrypi/main.exe` to the RPI and you should be able to run
it:

    scp build/raspberrypi/main.exe <raspberrypi>:~/blink
    on the rpi:
    ./blink




Setting Up an Actual Border Router
----------------------------------

These are the instructions for how I'm testing the RPI as a border router.
Because IPv6 support is anything but universal, this requires more manual setup
than desired.

My setup consists of the RPI and a computer on a wired network using the same
Ethernet switch. Ethernet switches do not need to look into IPv6 packets so they
can handle switching IPv6 packets. However, some (most?) routers do not yet
understand IPv6, so it's best if the RPI and computer are not attached directly
through a router.

### Setting Up the RPI

The RPI acts as a router for a range of IP addresses for the connected wireless
motes. I have assigned these a prefix:
`2607:f018:800a:bcde:f012:3456:7890::/112`. This is currently setup in TunP.

We also need to setup an IPv6 address for the RPI. This will be the address for
the RPI for packets coming in from the wsn side or from the Internet.

    sudo ip -6 addr add 2607:f018:800a:bcde:f012:3456:7891:1/112 dev eth0

### Setting Up the Computer

The computer can act as a source of packets or a receiver of packets. It also
needs an IP address and a prefix for the range of IP address that are on the
same subnet. Then in order for the computer to know how to route packets to the
wsn we need to explicitly tell it.

    sudo ip -6 addr add 2607:f018:800a:bcde:f012:3456:7891:2/112 dev eth0
    sudo ip -6 route add 2607:f018:800a:bcde:f012:3456:7890::/112 dev eth0

### Making a Network

With that running infrastructure running we need wireless nodes. These are
configured with the prefix `2607:f018:800a:bcde:f012:3456:7890::/112`.

### Testing


### Notes

    subnet for wsn              : 2607:f018:800a:bcde:f012:3456:7890::/112
    subnet for rest of computers: 2607:f018:800a:bcde:f012:3456:7891::/112

    border router:              : 2607:f018:800a:bcde:f012:3456:7891:1/112%eth0
    memristor                   : 2607:f018:800a:bcde:f012:3456:7891:2/112
    nuclear                     : 2607:f018:800a:bcde:f012:3456:7891:3/112


    rpi:
    sudo ip -6 addr add 2607:f018:800a:bcde:f012:3456:7891:1/112 dev eth0
    sudo sysctl -w net.ipv6.conf.all.forwarding=1

    sudo tcpdump -i eth0 udp and dst port 2001
    sudo tcpdump -i tun0

    memristor:
    sudo ip -6 addr add 2607:f018:800a:bcde:f012:3456:7891:2/112 dev eth0
    sudo ip -6 route add 2607:f018:800a:bcde:f012:3456:7890::/112 dev eth0

Hardware
--------

Currently we have an interface board that allows you to use the CC2520EM evaluation module with the raspberry pi.
We intend to wrap those into a single board.



To Do
-----

The driver needs some work to get it to work in the general TinyOS environment, as well as to work with BLIP.

- [x] Add BareReceive and BareSend interfaces to CC2520Rpi driver
  - This allows the BLIP stack to use extended 802.15.4 addressing internally.
- [ ] Check on how I'm setting the seq numbers
  - For the blip driver at least, I think I'm doing good things.
- [ ] Clean up setting RSSI, channel, etc.
- [ ] Create BorderRouter application.
  - Create an interface for the wireless network.
    - Send all incoming packets to the border router to that interface.
    - Let linux decide what to do with the packet (send to dhcp server, internet, or back to the border router app)
    - When packets come back in use rpl to route as normal back in to the wsn


