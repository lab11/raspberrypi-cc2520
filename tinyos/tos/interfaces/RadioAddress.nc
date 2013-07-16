
// Interface for getting and setting the hardware radio addresses

// Should be a part of the rfxlink library

interface RadioAddress {
  // Get the long address (64 bits) of the radio
  command ieee_eui64_t getExtAddr();

  // Change the short address of the radio.
  async command uint16_t getShortAddr();
  command void setShortAddr(uint16_t address);

  //Change the PAN address of the radio.
  async command uint16_t getPanAddr();
  command void setPanAddr(uint16_t address);
}
