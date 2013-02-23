
/**
 * Implementation of the general-purpose I/O abstraction
 * for the Raspberry Pi
 *
 * @author Brad Campbell
 */

generic module RpiGpioC() @safe() {
  provides interface GeneralIO;
  uses interface HplRpiGeneralIO as HplGeneralIO;
}

implementation {
  async command void GeneralIO.set() { call HplGeneralIO.set(); }
  async command void GeneralIO.clr() { call HplGeneralIO.clr(); }
  async command void GeneralIO.toggle() { call HplGeneralIO.toggle(); }
  async command bool GeneralIO.get() { return call HplGeneralIO.get(); }
  async command void GeneralIO.makeInput() { call HplGeneralIO.makeInput(); }
  async command bool GeneralIO.isInput() { return call HplGeneralIO.isInput(); }
  async command void GeneralIO.makeOutput() { call HplGeneralIO.makeOutput(); }
  async command bool GeneralIO.isOutput() { return call HplGeneralIO.isOutput(); }
}
