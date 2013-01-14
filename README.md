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


Hardware
--------

Currently we have an interface board that allows you to use the CC2520EM evaluation module with the raspberry pi.
We intend to wrap those into a single board.
