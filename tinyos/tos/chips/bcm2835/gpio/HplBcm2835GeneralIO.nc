
/**
 * HPL for the TI MSP430 family of microprocessors. This provides an
 * abstraction for general-purpose I/O.
 *
 * @author Cory Sharp <cssharp@eecs.berkeley.edu>
 * @author Peter Bigot <pab@peoplepowerco.com>
 */

#include "TinyError.h"

interface HplBcm2835GeneralIO
{
  /**
   * Set pin to high.
   */
  async command void set();

  /**
   * Set pin to low.
   */
  async command void clr();

  /**
   * Toggle pin status.
   */
  async command void toggle();

  /**
   * Get the port status that contains the pin.
   *
   * @return Status of the port that contains the given pin. The x'th
   * pin on the port will be represented in the x'th bit.
   */
  async command uint8_t getRaw();

  /**
   * Read pin value.
   *
   * @return TRUE if pin is high, FALSE otherwise.
   */
  async command bool get();

  /**
   * Set pin direction to input.
   */
  async command void makeInput();

  async command bool isInput();

  /**
   * Set pin direction to output.
   */
  async command void makeOutput();

  async command bool isOutput();

  /**
   * Set pin for module specific functionality.
   */
  async command void selectModuleFunc();

  async command bool isModuleFunc();

  /**
   * Set pin for I/O functionality.
   */
//  async command void selectIOFunc();

//  async command bool isIOFunc();

  /**
   * Set pin pullup / pull down resistor mode.
   * @param mode One of the MSP430_PORT_RESISTOR_* values
   * @return EINVAL if invalid mode or pin does not support resistor configuration;
   * FAIL if pin is not an input;
   * SUCCESS if pin supports resistor configuration, is an input, and mode is valid
   */
//  async command error_t setResistor(uint8_t mode);

  /**
   * Get the pin pullup / pulldown resistor mode.
   *
   * @return one of the MSP430_PORT_RESISTOR_* values
   */
//  async command uint8_t getResistor();

}

