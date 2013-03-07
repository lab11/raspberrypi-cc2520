
interface UnixTime {
  async command uint32_t getSeconds ();
  async command uint64_t getMilliseconds ();
  async command uint64_t getMicroseconds ();
}

