
module LocalIeeeEui64C {
  provides {
    interface LocalIeeeEui64;
  }
}

implementation {
  command ieee_eui64_t LocalIeeeEui64.getId () {
    int mac_addr_file;
    char buffer[17];
    ieee_eui64_t eui;

    mac_addr_file = open("/sys/class/net/eth0/address", O_RDONLY);
    read(mac_addr_file, buffer, 17);

    sscanf(buffer, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
      &eui.data[0], &eui.data[1], &eui.data[2], &eui.data[5], &eui.data[6], &eui.data[7]);
    eui.data[3] = 0xFF;
    eui.data[4] = 0xFE;
    eui.data[0] ^= 0x2;

    return eui;
  }
}