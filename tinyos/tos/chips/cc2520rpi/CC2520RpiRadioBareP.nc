#include <stdio.h>
#include <sys/ioctl.h>
#include <stdlib.h>
#include <fcntl.h>

#include <CC2520RpiRadio.h>
#include "CC2520RpiDriver.h"
#include "CC2520RpiDriverLayer.h"

module CC2520RpiRadioBareP {
  provides {
    interface Send;
    interface Receive;
    interface Packet;
    interface PacketMetadata;
    interface RadioAddress;
  }
  uses {
    interface BareSend as SubSend;
    interface BareReceive as SubReceive;
  }
}

implementation {

//----------- Send ---
  // msg: pointer to a message_t
  // len: length of the packet including the length field at the beginning
  command error_t Send.send (message_t* msg, uint8_t len) {
    // Need to add 1 to the length. This is because the length that
    // CC2520RpiSend requires is the packet plus the crc bytes minus the length
    // field.
    ((uint8_t*) msg)[0] = len+1;
    return call SubSend.send(msg);
  }

  command error_t Send.cancel (message_t* msg) {
    return call SubSend.cancel(msg);
  }

  event void SubSend.sendDone (message_t* msg, error_t error) {
    signal Send.sendDone(msg, error);
  }

  command uint8_t Send.maxPayloadLength () {
    return 126;
  }

  command void* Send.getPayload (message_t* msg, uint8_t len) {
    return msg;
  }

//----------- Receive ---
  event message_t* SubReceive.receive (message_t* msg) {
    // CC2520RpiReceive returns a packet with the length set as the packet plus
    // the checksum bytes minus the length field and this raw interface provides
    // the length of the packet without the crc but including the length field
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

  command uint8_t Packet.maxPayloadLength() {
    return 126;
  }

  command void* Packet.getPayload (message_t* msg, uint8_t len) {
    return msg;
  }

// ----------------- RadioAddress------------------------
  struct cc2520_set_address_data addr_data = {0x0001, 0x0000000000000001, 0x22};
  ieee_eui64_t ext_addr;
  int cc2520_file = -1;

  void openRadio () {
    if (cc2520_file == -1) {
      cc2520_file = open("/dev/radio", O_RDWR);
    }
  }

  // fix me: convert uint64_t to ieee_eui_64
  command ieee_eui64_t RadioAddress.getExtAddr() {
    memset(ext_addr.data, 0, sizeof(ieee_eui64_t));
    ext_addr.data[7] = 1;
  }

  // Change the short address of the radio.
  async command uint16_t RadioAddress.getShortAddr() {
    return addr_data.short_addr;
  }

  command void RadioAddress.setShortAddr(uint16_t address) {
    addr_data.short_addr = address;
    openRadio();
    ioctl(cc2520_file, CC2520_IO_RADIO_SET_ADDRESS, &addr_data);
  }

  //Change the PAN address of the radio.
  async command uint16_t RadioAddress.getPanAddr() {
    return addr_data.pan_id;
  }

  command void RadioAddress.setPanAddr(uint16_t address) {
    addr_data.pan_id = address;
    openRadio();
    ioctl(cc2520_file, CC2520_IO_RADIO_SET_ADDRESS, &addr_data);
  }

//----------- PacketMetadata ---

  link_metadata_t* getMetaLink (message_t* msg) {
    return &(((cc2520packet_metadata_t*) msg->metadata)->link);
  }

  cc2520_metadata_t* getMetaCC2520 (message_t* msg) {
    return &(((cc2520packet_metadata_t*) msg->metadata)->cc2520);
  }

  command uint8_t PacketMetadata.getLqi (message_t* msg) {
  //  return getMetaCC2520(msg)->lqi;
    return 255;
  }

  command uint8_t PacketMetadata.getRssi (message_t* msg) {
  //  return getMetaCC2520(msg)->rssi;
    return 255;
  }

  command void PacketMetadata.setRetries (message_t *msg, uint16_t maxRetries) {
    getMetaLink(msg)->maxRetries = maxRetries;
  }

  command void PacketMetadata.setRetryDelay (message_t *msg,
                                             uint16_t retryDelay) {
    getMetaLink(msg)->retryDelay = retryDelay;
  }

  command uint16_t PacketMetadata.getRetries(message_t *msg) {
    return getMetaLink(msg)->maxRetries;
  }

  command uint16_t PacketMetadata.getRetryDelay(message_t *msg) {
    getMetaLink(msg)->retryDelay;
  }

  command bool PacketMetadata.wasDelivered(message_t *msg) {
    return TRUE;
  }

  async command error_t PacketMetadata.requestAck(message_t* msg) {
    return SUCCESS;
  }

  async command error_t PacketMetadata.noAck(message_t* msg) {
    return SUCCESS;
  }

  async command bool PacketMetadata.wasAcked(message_t* msg) {
    return TRUE;
  }

}
