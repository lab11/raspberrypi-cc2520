
module CC2520RpiSplitControlP {
  provides {
    interface SplitControl;
  }
}

implementation {

  int cc2520_file;

  command error_t SplitControl.start () {
    struct cc2520_set_channel_data chan_data;
    struct cc2520_set_txpower_data txpower_data;
    struct cc2520_set_address_data addr_data;
    struct cc2520_set_lpl_data lpl_data;

    printf("Testing cc2520 driver...\n");
    cc2520_file = open("/dev/radio", O_RDWR);

    printf("Setting channel\n");

    chan_data.channel = 26;
    ioctl(cc2520_file, CC2520_IO_RADIO_SET_CHANNEL, &chan_data);

    printf("Setting address\n");
    addr_data.short_addr = 0x0001;
    addr_data.extended_addr = 0x0000000000000001;
    addr_data.pan_id = 0x22;
    ioctl(cc2520_file, CC2520_IO_RADIO_SET_ADDRESS, &addr_data);

    printf("Setting tx power\n");
    txpower_data.txpower = CC2520_TXPOWER_0DBM;
    ioctl(cc2520_file, CC2520_IO_RADIO_SET_TXPOWER, &txpower_data);

    printf("Disable LPL\n");
    lpl_data.enabled = FALSE;
    ioctl(cc2520_file, CC2520_IO_RADIO_SET_LPL, &lpl_data);

    printf("Turning on the radio...\n");
    ioctl(cc2520_file, CC2520_IO_RADIO_INIT, NULL);
    ioctl(cc2520_file, CC2520_IO_RADIO_ON, NULL);

    signal SplitControl.startDone(SUCCESS);
    return SUCCESS;
  }

  command error_t SplitControl.stop () {
    printf("Turning off the radio...\n");
    ioctl(cc2520_file, CC2520_IO_RADIO_OFF, NULL);

    signal SplitControl.stopDone(SUCCESS);
    return SUCCESS;
  }

}
