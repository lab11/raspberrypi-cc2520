raspberrypi-cc2520
==================

Code, hardware, and instructions to use the TI CC2520 with the Raspberry Pi.

The CC2520 is a 802.15.4 (Zigbee) radio commonly used in low power wireless
sensor networks. Typically 802.15.4 radios are used with WSN motes and embedded
microcontrollers. A side-effect of being used in WSNs, however, is the
microcontrollers are very memory constrained. This is often a problem when
certain nodes need to keep data about a large network of nodes, for instance
routing information for all of the nodes. To remedy this we propose using a
Raspberry Pi as a mote in a WSN. This provides both amble storage (memory) and
convenient control as all the utilities in Linux are available.


Software
--------

### Kernel

You need the kernel module from https://github.com/ab500/linux-cc2520-driver.

You need to enable IPV6 on the RPI:

    sudo vim /etc/modules
    add ipv6 on a newline

If you want to run the border router application you need to enable interface forwarding:

    sudo vim /etc/sysctl.conf
    uncomment the line: net.ipv6.conf.all.forwarding=1

### BCM2835 GPIO Library

The TinyOS code requires a library for the low level BCM2835 GPIO from
http://www.open.com.au/mikem/bcm2835/. Download and compile it on the RPI as
instructed on the website. In order to cross compile tinyos code on your machine
you also need the library and headers on your local machine. To build this on
your local machine:

    ./configure --host arm-linux-gnueabi
    make
    sudo mv src/libbcm2835.a /usr/arm-linux-gnueabi/lib
    sudo mv src/bcm2835.h /usr/arm-linux-gnueabi/include


### TinyOS

On your non-RPI computer you need a copy of the main TinyOS repository and the
tinyos folder from this repo. You also need to install the dependencies for
TinyOS. There are instructions here:
[http://docs.tinyos.net/tinywiki/index.php/Installing_TinyOS_2.1.1]. If you want
the simple Linux install I use, look here:
[http://energy.eecs.umich.edu/wiki/doku.php?id=tinyos_install]. The TinyOS
applications are designed to be cross compiled for the RPI.

In order for the TinyOS build system to figure out all the correct paths you
need to help it along a bit. Add the following to your `.bashrc` file:

    export TOSROOTRPI=<path to git repo>/tinyos
    export TOSMAKE_PATH="$TOSROOTRPI/support/make $TOSMAKE_PATH"

Until TinyOS pulls my changes you need to merge in my blip_interface branch
to the tinyos-main repository.



Usage
-----

Now to test the TinyOS code and the kernel module.

### Blink

Assuming you have the correct compilers, you should be able to run the following
on your desktop and have it compile successfully:

    cd tinyos-main/apps/Blink
    make rpi

Then copy `build/rpi/main.exe` to the RPI and you should be able to run
it:

    scp build/rpi/main.exe <raspberrypi>:~/blink
    on the rpi:
    ./blink

Pins 7, 12, and 13 should be toggling.


### RadioCountToLeds

To test the radio with TinyOS, run the RadioCountToLeds app on the RPi and
another mote. The basic process is the same as with the blink app above.


Setting Up an Actual Border Router
----------------------------------

These are the instructions for how I'm testing the RPI as a border router.
Because IPv6 support is anything but universal, this requires more manual setup
than desired.

My setup consists of using Hurricane Electric to tunnel IPv6 to the RPi and all
computers I wish to send packets to.

### Setting up the Tunnel

Go to http://www.tunnelbroker.net/ to setup a tunnel to the IP address of the
RPI. The Hurricane Electric instructions will setup an IPv6 in IPv4 tunnel
device on the RPi.

Hurricane Electric conveniently provides every tunnel it creates a /64 prefix
that they route to the end of the tunnel. This is perfect for the BorderRouter
application as the WSN nodes can use IP addresses in this range.

### Setting Up the RPI

The RPi will be running the BorderRouter app and a DHCPv6 server.

#### Configure the BorderRouter App Address

The RPI acts as a router for a range of IP addresses for the connected wireless
motes. You will need to change `TunP` with the prefix information you were
assigned from Hurricane Electric. The link local address of the `tun` device
can be set to anything.

#### DHCP

Blip supports both static and dynamic IP addresses. If you wish to reduce your
burden when flashing nodes and use dynamic addresses, you need to be
running a DHCP server. Ideally you could use any router's DHCP server, but in
the likely case that isn't available, you can run a DHCP server on the RPI.

I'm using [Dibbler](http://klub.com.pl/dhcpv6/). I couldn't figure out how to
cross compile it so I downloaded it to the RPi and built it on there (yeah it
took a little while).

    tar xf dibbler-x.x.x.tar.gz
    ./configure
    make
    sudo make install

Running Dibbler is pretty straightforward. The last key is the configuration file
located at `/etc/dibbler/server.conf`. Here is mine:

    log-colors true

    iface relay1 {
     relay tun0

     class {
      pool <ipv6/64 from Hurricane Electric>/64
     }
    }

    iface "tun0" {
     class {
      pool <ipv6/64 from Hurricane Electric>/64
     }

     client link-local fe80::212:6d52:5000:1 {
      address <ipv6/64 from Hurricane Electric>:1
      prefix <ipv6/64 from Hurricane Electric>/64
     }
    }



### Setting Up the Computer

The computer can act as a source of packets or a receiver of packets. I do this
by setting up another tunnel with Hurricane Electric. This way the computer has
an IPv6 address.



Hardware
--------

Currently we have an interface board that allows you to use the CC2520EM
evaluation module with the raspberry pi. We intend to wrap those into a single
board.



To Do
-----

The driver needs some work to get it to work in the general TinyOS environment, as well as to work with BLIP.

- [x] Add BareReceive and BareSend interfaces to CC2520Rpi driver
  - This allows the BLIP stack to use extended 802.15.4 addressing internally.
- [x] Check on how I'm setting the seq numbers
- [x] Clean up setting RSSI, channel, etc.
- [x] Create BorderRouter application.
  - Create an interface for the wireless network.
    - Send all incoming packets to the border router to that interface.
    - Let linux decide what to do with the packet (send to dhcp server, internet, or back to the border router app)
    - When packets come back in use rpl to route as normal back in to the wsn


