
interface UartBuffer {
  event void receive (uint8_t* buf, uint8_t len, uint64_t timestamp);
}
