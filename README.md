raspberrypi-cc2520
==================

Code, hardware, and instructions to use the TI CC2520 with the Raspberry Pi.


Software
--------

### Kernel

You need the kernel module from https://github.com/ab500/linux-cc2520-driver.

### TinyOS

You need a copy of the main TinyOS repository and the tinyos folder from this repo.

#### Installation

The TinyOS code requires a library for the low level BCM2835 GPIO from
http://www.open.com.au/mikem/bcm2835/. Download and compile it on the RPI as shown.
In order to cross compile the tinyos code on your machine you need also need the
library and headers on your local machine.

    -insert code for that here-
    mv libbcm2835.a /usr/arm-linux-gnueabi/lib
    mv bcm2835.h /usr/arm-linux-gnueabi/include

In order for the TinyOS build system to figure out all the correct paths you
need to help it along a bit. Add the following to your `.bashrc` file:

    export TOSROOTRPI=<path to git repo>/raspberrypi-cc2520/tinyos
    export TOSMAKE_PATH="$TOSROOTRPI/support/make $TOSMAKE_PATH"

#### Usage

Assuming you have the correct compilers, you should be able to run the following in
`tinyos-main/apps/Blink` and have it compile successfully:

    make raspberrypi

Then copy `build/raspberrypi/main.exe` to the RPI and you should be able to run
it:

    ./main.exe



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


