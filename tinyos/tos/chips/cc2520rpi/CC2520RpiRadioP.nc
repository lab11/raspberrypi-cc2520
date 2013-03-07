#include <stdio.h>
#include <sys/ioctl.h>
#include <stdlib.h>
#include <fcntl.h>

#include <CC2520RpiRadio.h>
#include "CC2520RpiDriver.h"
#include <RadioConfig.h>

module CC2520RpiRadioP {
  provides {
    interface SplitControl;
    interface Send;
    interface Receive;
    interface Packet;
    interface LowPowerListening;
    interface PacketMetadata;
    interface RadioAddress;
  }
  uses {
    interface BareSend as SubSend;
    interface BareReceive as SubReceive;

    interface LocalIeeeEui64;
  }
}

implementation {

//----------- SplitControl ---
  int cc2520_file = -1;
  struct cc2520_set_channel_data chan_data = {CC2520_DEF_CHANNEL};
  struct cc2520_set_address_data addr_data = {0, 0, DEFINED_TOS_AM_GROUP};
  struct cc2520_set_ack_data ack_data = {SOFTWAREACK_TIMEOUT};
  struct cc2520_set_txpower_data txpower_data = {CC2520_DEF_RFPOWER};
  struct cc2520_set_lpl_data lpl_data = {0, 0, FALSE};
#ifdef CC2520RPI_KERNEL_DRIVER_DEBUG
  struct cc2520_set_print_messages_data print_data = {TRUE};
#else
  struct cc2520_set_print_messages_data print_data = {FALSE};
#endif

  ieee_eui64_t ext_addr;

  uint8_t sequence_number;

  command error_t SplitControl.start () {
    uint8_t* ext_addr_ptr;
    int i;

    RADIO_PRINTF("Starting cc2520 driver.\n");
    cc2520_file = open("/dev/radio", O_RDWR);
    if (cc2520_file < 0) {
      ERROR("Failed to open /dev/radio.\n");
      ERROR("Make sure the kernel module is loaded.\n");
      exit(1);
    }

    // init the seq no
    sequence_number = TOS_NODE_ID << 4;

    // set up the addresses for this node
    addr_data.short_addr = TOS_NODE_ID;
    ext_addr = call LocalIeeeEui64.getId();
    ext_addr_ptr = (uint8_t*) &addr_data.extended_addr;
    for (i=0; i<8; i++) {
      ext_addr_ptr[i] = ext_addr.data[7-i];
    }
    //memcpy(&addr_data.extended_addr, &ext_addr.data, 8);

    // set properties
    ioctl(cc2520_file, CC2520_IO_RADIO_SET_CHANNEL, &chan_data);
    ioctl(cc2520_file, CC2520_IO_RADIO_SET_ADDRESS, &addr_data);
    ioctl(cc2520_file, CC2520_IO_RADIO_SET_ACK, &ack_data);
    ioctl(cc2520_file, CC2520_IO_RADIO_SET_TXPOWER, &txpower_data);
    ioctl(cc2520_file, CC2520_IO_RADIO_SET_LPL, &lpl_data);
    ioctl(cc2520_file, CC2520_IO_RADIO_SET_PRINT, &print_data);

    // turn on
    ioctl(cc2520_file, CC2520_IO_RADIO_INIT, NULL);
    ioctl(cc2520_file, CC2520_IO_RADIO_ON, NULL);

    signal SplitControl.startDone(SUCCESS);
    return SUCCESS;
  }

  command error_t SplitControl.stop () {
    RADIO_PRINTF("Turning off the radio.\n");
    ioctl(cc2520_file, CC2520_IO_RADIO_OFF, NULL);

    signal SplitControl.stopDone(SUCCESS);
    return SUCCESS;
  }

//----------- Send ---
  ieee154_simple_header_t* getHeaderIeee (message_t* msg) {
    return &(((cc2520packet_header_t*) msg->header)->ieee154);
  }

  // msg: pointer to a message_t
  // len: length of the packet including the length field at the beginning
  command error_t Send.send (message_t* msg, uint8_t len) {
    ieee154_simple_header_t* ieeehdr;

    // Need to add 1 to the length. This is because the length that
    // CC2520RpiSend requires is the packet plus the meta bytes minus the length
    // field.
    ((cc2520packet_header_t*) msg->header)->cc2520.length = len+1;

    // Set the sequence number here. No real need to create a whole new layer
    //  for it. We set the sequence number at this point so that it remains
    //  constant for any retries in the LinkP layer. See:
    //  http://docs.tinyos.net/tinywiki/index.php/CC2420_Data_Sequence_Numbers
    ieeehdr = getHeaderIeee(msg);
    ieeehdr->dsn = sequence_number++;

    return call SubSend.send(msg);
  }

  command error_t Send.cancel (message_t* msg) {
    return call SubSend.cancel(msg);
  }

  event void SubSend.sendDone (message_t* msg, error_t error) {
    signal Send.sendDone(msg, error);
  }

  // This interface is very bare and provides access to the entire packet.
  command uint8_t Send.maxPayloadLength () {
    return 128;
  }

  command void* Send.getPayload (message_t* msg, uint8_t len) {
    return msg;
  }

//----------- Receive ---
  event message_t* SubReceive.receive (message_t* msg) {
    // CC2520RpiReceive returns a packet with the length set as the packet plus
    // the checksum bytes minus the length field and this raw interface provides
    // the length of the packet without the meta but including the length field
    uint8_t len = ((cc2520packet_header_t*) msg->header)->cc2520.length-1;
    return signal Receive.receive(msg, msg, len);
  }

//----------- Packet ---
  command void Packet.clear (message_t* msg) {
    memset(msg, 0, sizeof(message_t));
  }

  command uint8_t Packet.payloadLength (message_t* msg) {
    uint8_t len = ((cc2520packet_header_t*) msg->header)->cc2520.length;
    return len;
  }

  command void Packet.setPayloadLength (message_t* msg, uint8_t len) {
    ((cc2520packet_header_t*) msg->header)->cc2520.length = len;
  }

  command uint8_t Packet.maxPayloadLength () {
    return 128;
  }

  command void* Packet.getPayload (message_t* msg, uint8_t len) {
    return msg;
  }

// ----------------- Low Power Listening ---
  uint16_t lpl_interval = 0;

  command void LowPowerListening.setLocalWakeupInterval (uint16_t interval) {
    if (interval == 0) {
      // turn off lpl
      lpl_data.enabled = FALSE;
      ioctl(cc2520_file, CC2520_IO_RADIO_OFF, NULL);
      ioctl(cc2520_file, CC2520_IO_RADIO_SET_LPL, &lpl_data);
      ioctl(cc2520_file, CC2520_IO_RADIO_ON, NULL);

    } else if (interval != lpl_interval) {
      // set the window and interval
      lpl_data.window   = LPL_WINDOW;
      lpl_data.interval = interval;
      lpl_data.enabled  = TRUE;
      ioctl(cc2520_file, CC2520_IO_RADIO_OFF, NULL);
      ioctl(cc2520_file, CC2520_IO_RADIO_SET_LPL, &lpl_data);
      ioctl(cc2520_file, CC2520_IO_RADIO_ON, NULL);
    }
    lpl_interval = interval;
  }

  command uint16_t LowPowerListening.getLocalWakeupInterval () {
    return lpl_interval;
  }

  command void LowPowerListening.setRemoteWakeupInterval (message_t *msg,
                                                          uint16_t interval) {
  }

  command uint16_t LowPowerListening.getRemoteWakeupInterval (message_t *msg) {
    return lpl_interval;
  }

// ----------------- RadioAddress-----------------------
  command ieee_eui64_t RadioAddress.getExtAddr () {
    memcpy(&ext_addr.data, &addr_data.extended_addr, 8);
    return ext_addr;
  }

  async command uint16_t RadioAddress.getShortAddr () {
    return addr_data.short_addr;
  }

  command void RadioAddress.setShortAddr (uint16_t address) {
 // temporary comment to avoid bug in spi driver on rpi
 //   addr_data.short_addr = address;
 //   ioctl(cc2520_file, CC2520_IO_RADIO_OFF, NULL);
 //   ioctl(cc2520_file, CC2520_IO_RADIO_SET_ADDRESS, &addr_data);
 //   ioctl(cc2520_file, CC2520_IO_RADIO_ON, NULL);
  }

  async command uint16_t RadioAddress.getPanAddr () {
    return addr_data.pan_id;
  }

  command void RadioAddress.setPanAddr (uint16_t address) {
 //   addr_data.pan_id = address;
 //   ioctl(cc2520_file, CC2520_IO_RADIO_OFF, NULL);
 //   ioctl(cc2520_file, CC2520_IO_RADIO_SET_ADDRESS, &addr_data);
 //   ioctl(cc2520_file, CC2520_IO_RADIO_ON, NULL);
  }

//----------- PacketMetadata ---

  link_metadata_t* getMetaLink (message_t* msg) {
    return &(((cc2520packet_metadata_t*) msg->metadata)->link);
  }

  cc2520_metadata_t* getMetaCC2520 (message_t* msg) {
    return &(((cc2520packet_metadata_t*) msg->metadata)->cc2520);
  }

  ack_metadata_t* getMetaAck (message_t* msg) {
    return &(((cc2520packet_metadata_t*) msg->metadata)->ack);
  }

  timestamp_metadata_t* getMetaTimestamp (message_t* msg) {
    return &(((cc2520packet_metadata_t*) msg->metadata)->timestamp);
  }

  command uint8_t PacketMetadata.getLqi (message_t* msg) {
    return getMetaCC2520(msg)->lqi;
  }

  command uint8_t PacketMetadata.getRssi (message_t* msg) {
    return getMetaCC2520(msg)->rssi;
  }

  command uint64_t PacketMetadata.getTimestamp (message_t* msg) {
    return getMetaTimestamp(msg)->timestamp_micro;
  }

  command void PacketMetadata.setLqi (message_t *msg, uint8_t lqi) {
    getMetaCC2520(msg)->lqi = lqi;
  }

  command void PacketMetadata.setRssi (message_t *msg, uint8_t rssi) {
    getMetaCC2520(msg)->rssi = rssi;
  }

  command void PacketMetadata.setTimestamp (message_t* msg, uint64_t t) {
    getMetaTimestamp(msg)->timestamp_micro = t;
  }

  command void PacketMetadata.setRetries (message_t *msg, uint16_t maxRetries) {
    getMetaLink(msg)->maxRetries = maxRetries;
  }

  command void PacketMetadata.setRetryDelay (message_t *msg,
                                             uint16_t retryDelay) {
    getMetaLink(msg)->retryDelay = retryDelay;
  }

  command uint16_t PacketMetadata.getRetries (message_t *msg) {
    return getMetaLink(msg)->maxRetries;
  }

  command uint16_t PacketMetadata.getRetryDelay (message_t *msg) {
    return getMetaLink(msg)->retryDelay;
  }

  async command error_t PacketMetadata.requestAck (message_t* msg) {
    getHeaderIeee(msg)->fcf &= ~(uint16_t)(1 << IEEE154_FCF_ACK_REQ);
    return SUCCESS;
  }

  async command error_t PacketMetadata.noAck (message_t* msg) {
    getHeaderIeee(msg)->fcf &= ~(uint16_t)(1 << IEEE154_FCF_ACK_REQ);
    return SUCCESS;
  }

  async command bool PacketMetadata.wasAcked (message_t* msg) {
    return getMetaAck(msg)->ack;
  }

  command void PacketMetadata.setWasAcked (message_t* msg, bool ack) {
    getMetaAck(msg)->ack = ack;
  }

}
