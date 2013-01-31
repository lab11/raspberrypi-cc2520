#include <bcm2835.h>

generic module HplRpiGeneralIOP(uint8_t pin) @safe() {
  provides interface HplRpiGeneralIO as IO;
}
implementation {

  // Variables to keep track of the pin state. These are necessary because the
  // bcm2835 library does not have functions that correspond to all of the
  // functions in this module.
  bool pin_high  = FALSE;
  bool pin_input = TRUE;

  async command void IO.set() {
    bcm2835_gpio_set(pin);
    atomic pin_high = TRUE;
  }

  async command void IO.clr() {
    bcm2835_gpio_clr(pin);
    atomic pin_high = FALSE;
  }

  async command void IO.toggle() {
    atomic {
      if (pin_high) {
        bcm2835_gpio_clr(pin);
        pin_high = FALSE;
      } else {
        bcm2835_gpio_set(pin);
        pin_high = TRUE;
      }
    }
  }

  async command uint8_t IO.getRaw() {
    return bcm2835_gpio_lev(pin);
  }

  async command bool IO.get() {
    return bcm2835_gpio_lev(pin) == 1;
  }

  async command void IO.makeInput() {
    bcm2835_gpio_fsel(pin, BCM2835_GPIO_FSEL_INPT);
    atomic pin_input = TRUE;
  }

  async command bool IO.isInput() {
    atomic return pin_input;
  }

  async command void IO.makeOutput() {
    bcm2835_gpio_fsel(pin, BCM2835_GPIO_FSEL_OUTP);
    atomic pin_input = FALSE;
  }

  async command bool IO.isOutput() {
    atomic return pin_input == FALSE;
  }
}
