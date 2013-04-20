
/* Wire to this module to use the ID Rfid Reader.
 * http://www.sparkfun.com/products/8419
 */

configuration IDrfidC {
  provides {
    interface Notify<uint8_t*>;
  }
}

implementation {
  components IDrfidP;

  components UartC;
  IDrfidP.UartBuffer -> UartC.UartBuffer;
  IDrfidP.UartConfig -> UartC.UartConfig;

  Notify = IDrfidP.Notify;
}
