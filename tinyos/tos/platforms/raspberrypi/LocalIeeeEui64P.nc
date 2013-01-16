
module LocalIeeeEui64P {
  provides {
    interface LocalIeeeEui64;
  }
}

implementation {
  ieee_eui64_t id = {{0x00, 0x0F, 0x0A, 0x0C, 0x0E, 0x00, 0x00, 0x00}};

  command ieee_eui64_t LocalIeeeEui64.getId() {
    return id;
  }
}
