
module LocalIeeeEui64P {
  provides {
    interface LocalIeeeEui64;
  }
}

implementation {
  ieee_eui64_t id = {{0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01}};

  command ieee_eui64_t LocalIeeeEui64.getId() {
    return id;
  }
}
