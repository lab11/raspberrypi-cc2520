
/**
 * Implementation of the general-purpose I/O abstraction
 * for the Raspberry Pi
 *
 * @author Brad Campbell
 */

generic module Bcm2835GpioC() @safe() {
  provides interface GeneralIO;
  uses interface HplBcm2835GeneralIO as IO;
}

implementation {
  async command void GeneralIO.set()        { call IO.set(); }
  async command void GeneralIO.clr()        { call IO.clr(); }
  async command void GeneralIO.toggle()     { call IO.toggle(); }
  async command bool GeneralIO.get()        { return call IO.get(); }
  async command void GeneralIO.makeInput()  { call IO.makeInput(); }
  async command bool GeneralIO.isInput()    { return call IO.isInput(); }
  async command void GeneralIO.makeOutput() { call IO.makeOutput(); }
  async command bool GeneralIO.isOutput()   { return call IO.isOutput(); }
}
