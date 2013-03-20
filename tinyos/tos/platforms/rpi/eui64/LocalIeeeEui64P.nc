
module LocalIeeeEui64P {
  provides {
    interface LocalIeeeEui64;
  }
  uses {
    interface ReadId48;
  }
}

implementation {
  // Default ID for the rpi. The upper 3 bytes are the Berkeley MAC address
  // header.
  ieee_eui64_t id = {{0x00, 0x12, 0x6d, 0x52, 0x50, 0x00, 0x00, 0x01}};

  bool have_id = FALSE;

  command ieee_eui64_t LocalIeeeEui64.getId () {
    uint8_t buf[6];
    error_t e;

    if (!have_id) {
      e = call ReadId48.read(buf);
      if (e == SUCCESS) {
        // Copy the lower 5 bytes of the unique id into the eui64 id. This
        // preserves the MAC address prefix that identifies this as a Berkeley
        // device (yes a little weird) and minimizes the chance two nodes have
        // the same address.
        memcpy(id.data+3, buf+1, 5);
        have_id = TRUE;
      }
    }
    return id;
  }
}
