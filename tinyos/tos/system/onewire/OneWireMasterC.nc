/**
 * Dallas/Maxim 1wire bus master
 *
 */

configuration OneWireMasterC {
  provides {
    interface OneWireReadWrite as OneWire;
  }
  uses {
    interface GeneralIO as Pin;
    interface BusyWait<TMicro, uint16_t>;
  }
}
implementation {
  components OneWireMasterP;
  components BusyWaitMicroC;

  OneWireMasterP.BusyWait -> BusyWaitMicroC;
  OneWireMasterP.Pin = Pin;

  OneWire = OneWireMasterP.OneWire;
}
