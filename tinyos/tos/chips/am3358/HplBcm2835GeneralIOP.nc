#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>

module HplBcm2835GeneralIOP {
  provides {
    interface Init;
    interface HplBcm2835GeneralIO as Gpio[uint8_t bcm_pin];
  }
}
implementation {

// #define BCM2708_PERI_BASE 0x20000000
// #define GPIO_BASE         (BCM2708_PERI_BASE + 0x200000) // GPIO controller

// // Values to use with SET_GPIO_ALT for the various alternate functions of GPIOs
// #define FSEL_ALTERNATE_0 4
// #define FSEL_ALTERNATE_1 5
// #define FSEL_ALTERNATE_2 6
// #define FSEL_ALTERNATE_3 7
// #define FSEL_ALTERNATE_4 3
// #define FSEL_ALTERNATE_5 2

// #define PAGE_SIZE (4*1024)
// #define BLOCK_SIZE (4*1024)

// // GPIO setup macros. Always use INP_GPIO(x) before using OUT_GPIO(x) or SET_GPIO_ALT(x,y)
// #define INP_GPIO(g)        *(gpio+((g)/10)) &= ~(7<<(((g)%10)*3))
// #define OUT_GPIO(g)        *(gpio+((g)/10)) |=  (1<<(((g)%10)*3))
// #define SET_GPIO_ALT(g,a)  *(gpio+((g)/10)) |=  (a<<(((g)%10)*3))

// #define GPIO_SET(g)        *(gpio+7) = (1<<(g))  // sets bits which are 1 ignores bits which are 0
// #define GPIO_CLR(g)        *(gpio+10) = (1<<(g)) // clears bits which are 1 ignores bits which are 0
// #define GPIO_READ(g)       (((*(gpio+13) & (1<<(g))) >> (g)) & 0x1)

// #define PIN_NOTE_CLR(a, g) a &= (~(1<<g))
// #define PIN_NOTE_SET(a, g) a |= (1<<g)
// #define PIN_NOTE_GET(a, g) ((a >> g) & 0x1)

//   volatile unsigned *gpio;

//   // Variable to keep track of the pin state. This is an easy way to make
//   // toggle() easy to implement.
//   unsigned int pin_level = 0;
//   unsigned int pin_output = 0;
//   unsigned int pin_alt = 0;


  command error_t Init.init() {
    // int mem_fd;
    // void *gpio_map;

    // // open /dev/mem
    // mem_fd = open("/dev/mem", O_RDWR|O_SYNC);
    // if (mem_fd == -1) {
    //   ERROR("Could not open /dev/mem\n");
    //   ERROR("%s\n", strerror(errno));
    //   exit(1);
    // }

    // // mmap GPIO
    // gpio_map = mmap(
    //   NULL,                 // Any adddress in our space will do
    //   BLOCK_SIZE,           // Map length
    //   PROT_READ|PROT_WRITE, // Enable reading & writting to mapped memory
    //   MAP_SHARED,           // Shared with other processes
    //   mem_fd,               // File to map
    //   GPIO_BASE             // Offset to GPIO peripheral
    // );
    // if (gpio_map == MAP_FAILED) {
    //   ERROR("mmap of gpio failed.\n");
    //   ERROR("%s\n", strerror(errno));
    //   exit(1);
    // }

    // close(mem_fd); // No need to keep mem_fd open after mmap

    // // Always use volatile pointer!
    // gpio = (volatile unsigned*) gpio_map;

    return SUCCESS;

  }

  async command void Gpio.set[uint8_t bcm_pin]() {
    // GPIO_SET(bcm_pin);
    // atomic PIN_NOTE_SET(pin_level, bcm_pin);
  }

  async command void Gpio.clr[uint8_t bcm_pin]() {
    // GPIO_CLR(bcm_pin);
    // atomic PIN_NOTE_CLR(pin_level, bcm_pin);
  }

  async command void Gpio.toggle[uint8_t bcm_pin]() {
    // atomic {
    //   if (PIN_NOTE_GET(pin_level, bcm_pin)) {
    //     GPIO_CLR(bcm_pin);
    //     atomic PIN_NOTE_CLR(pin_level, bcm_pin);
    //   } else {
    //     GPIO_SET(bcm_pin);
    //     atomic PIN_NOTE_SET(pin_level, bcm_pin);
    //   }
    // }
  }

  async command uint8_t Gpio.getRaw[uint8_t bcm_pin]() {
    // return GPIO_READ(bcm_pin);
  }

  async command bool Gpio.get[uint8_t bcm_pin]() {
    // return GPIO_READ(bcm_pin) == 1;
  }

  async command void Gpio.makeInput[uint8_t bcm_pin]() {
    // INP_GPIO(bcm_pin);
    // atomic PIN_NOTE_CLR(pin_output, bcm_pin);
  }

  async command bool Gpio.isInput[uint8_t bcm_pin]() {
    // atomic {
    //   if (PIN_NOTE_GET(pin_output, bcm_pin) == 0 &&
    //       PIN_NOTE_GET(pin_alt, bcm_pin) == 0) {
    //     return TRUE;
    //   }
    //   return FALSE;
    // }
  }

  async command void Gpio.makeOutput[uint8_t bcm_pin]() {
    // INP_GPIO(bcm_pin);
    // OUT_GPIO(bcm_pin);
    // atomic PIN_NOTE_SET(pin_output, bcm_pin);
  }

  async command bool Gpio.isOutput[uint8_t bcm_pin]() {
    // atomic return PIN_NOTE_GET(pin_output, bcm_pin) == 1;
  }

  async command void Gpio.selectModuleFunc[uint8_t bcm_pin]() {
    // INP_GPIO(bcm_pin);
    // SET_GPIO_ALT(bcm_pin, FSEL_ALTERNATE_0);
    // atomic PIN_NOTE_CLR(pin_output, bcm_pin);
    // atomic PIN_NOTE_SET(pin_alt, bcm_pin);
  }

  async command bool Gpio.isModuleFunc[uint8_t bcm_pin]() {
    // atomic return PIN_NOTE_GET(pin_alt, bcm_pin) == 1;
  }
}
