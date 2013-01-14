
#include <stdio.h>
#include <sys/ioctl.h>
#include <stdlib.h>
#include <fcntl.h>


#include <CC2520RpiRadio.h>
#include <RadioConfig.h>
#include <Tasklet.h>

#include "CC2520RpiDriver.h"


// Handles all of the configuration settings for all of the layers.

module CC2520RpiRadioP {
  provides {
 //   interface CC2520DriverConfig;
 //   interface SoftwareAckConfig;
 //   interface UniqueConfig;
 //   interface CsmaConfig;
 //   interface TrafficMonitorConfig;
 //   interface RandomCollisionConfig;
 //   interface SlottedCollisionConfig;
    interface ActiveMessageConfig;
 //   interface DummyConfig;

//#ifdef LOW_POWER_LISTENING
//    interface LowPowerListeningConfig;
//#endif

    // temporarily here...
    // just to get it to compile for now
    interface SplitControl;
  }

  uses {
    interface Ieee154PacketLayer;
 //   interface RadioAlarm;
 //   interface RadioPacket as CC2520Packet;

 //   interface PacketTimeStamp<TRadio, uint32_t>;
  }
}

implementation {

  // temporary
  command error_t SplitControl.start() {

    int result = 0;
    int file_desc;
    struct cc2520_set_channel_data chan_data;
    struct cc2520_set_address_data addr_data;
    struct cc2520_set_txpower_data txpower_data;

    printf("Testing cc2520 driver...\n");
    file_desc = open("/dev/radio", O_RDWR);

    printf("Setting channel\n");

    chan_data.channel = 25;
    ioctl(file_desc, CC2520_IO_RADIO_SET_CHANNEL, &chan_data);

    printf("Setting address\n");
    addr_data.short_addr = 0x0001;
    addr_data.extended_addr = 0x0000000000000001;
    addr_data.pan_id = 0x22;
    ioctl(file_desc, CC2520_IO_RADIO_SET_ADDRESS, &addr_data);

    printf("Setting tx power\n");
    txpower_data.txpower = CC2520_TXPOWER_0DBM;
    ioctl(file_desc, CC2520_IO_RADIO_SET_TXPOWER, &txpower_data);

    printf("Turning on the radio...\n");
    ioctl(file_desc, CC2520_IO_RADIO_INIT, NULL);
    ioctl(file_desc, CC2520_IO_RADIO_ON, NULL);




    signal SplitControl.startDone(SUCCESS);
    return SUCCESS;
  }

  // temporary
  command error_t SplitControl.stop () {
    signal SplitControl.stopDone(SUCCESS);
    return SUCCESS;
  }

/*
// ----------------- CC2520DriverConfig -----------------

  async command uint8_t CC2520DriverConfig.headerLength(message_t* msg)
  {
    return offsetof(message_t, data) - sizeof(cc2520packet_header_t);
  }

  async command uint8_t CC2520DriverConfig.maxPayloadLength()
  {
    return sizeof(cc2520packet_header_t) + TOSH_DATA_LENGTH;
  }

  async command uint8_t CC2520DriverConfig.metadataLength(message_t* msg)
  {
    return 0;
  }

  async command uint8_t CC2520DriverConfig.headerPreloadLength()
  {
    // we need the fcf, dsn, destpan, and dest
    return 7;
  }

  async command bool CC2520DriverConfig.requiresRssiCca(message_t* msg)
  {
    return call Ieee154PacketLayer.isDataFrame(msg);
  }

//----------------- SoftwareAckConfig -----------------

  async command bool SoftwareAckConfig.requiresAckWait(message_t* msg)
  {
    return call Ieee154PacketLayer.requiresAckWait(msg);
  }

  async command bool SoftwareAckConfig.isAckPacket(message_t* msg)
  {
    return call Ieee154PacketLayer.isAckFrame(msg);
  }

  async command bool SoftwareAckConfig.verifyAckPacket(message_t* data, message_t* ack)
  {
    return call Ieee154PacketLayer.verifyAckReply(data, ack);
  }

  async command void SoftwareAckConfig.setAckRequired(message_t* msg, bool ack)
  {
    call Ieee154PacketLayer.setAckRequired(msg, ack);
  }

  async command bool SoftwareAckConfig.requiresAckReply(message_t* msg)
  {
    return call Ieee154PacketLayer.requiresAckReply(msg);
  }

  async command void SoftwareAckConfig.createAckPacket(message_t* data, message_t* ack)
  {
    call Ieee154PacketLayer.createAckReply(data, ack);
  }

#ifndef SOFTWAREACK_TIMEOUT
#define SOFTWAREACK_TIMEOUT 1000
#endif

  async command uint16_t SoftwareAckConfig.getAckTimeout()
  {
    return (uint16_t)(SOFTWAREACK_TIMEOUT);
  }

  tasklet_async command void SoftwareAckConfig.reportChannelError()
  {
#ifdef TRAFFIC_MONITOR
//    signal TrafficMonitorConfig.channelError();
#endif
  }

// ----------------- UniqueConfig -----------------

  async command uint8_t UniqueConfig.getSequenceNumber(message_t* msg)
  {
    return call Ieee154PacketLayer.getDSN(msg);
  }

  async command void UniqueConfig.setSequenceNumber(message_t* msg, uint8_t dsn)
  {
    call Ieee154PacketLayer.setDSN(msg, dsn);
  }

  async command am_addr_t UniqueConfig.getSender(message_t* msg)
  {
    return call Ieee154PacketLayer.getSrcAddr(msg);
  }

  tasklet_async command void UniqueConfig.reportChannelError()
  {
#ifdef TRAFFIC_MONITOR
//    signal TrafficMonitorConfig.channelError();
#endif
  }
*/
// ----------------- ActiveMessageConfig -----------------

  command am_addr_t ActiveMessageConfig.destination(message_t* msg)
  {
    return call Ieee154PacketLayer.getDestAddr(msg);
  }

  command void ActiveMessageConfig.setDestination(message_t* msg, am_addr_t addr)
  {
    call Ieee154PacketLayer.setDestAddr(msg, addr);
  }

  command am_addr_t ActiveMessageConfig.source(message_t* msg)
  {
    return call Ieee154PacketLayer.getSrcAddr(msg);
  }

  command void ActiveMessageConfig.setSource(message_t* msg, am_addr_t addr)
  {
    call Ieee154PacketLayer.setSrcAddr(msg, addr);
  }

  command am_group_t ActiveMessageConfig.group(message_t* msg)
  {
    return call Ieee154PacketLayer.getDestPan(msg);
  }

  command void ActiveMessageConfig.setGroup(message_t* msg, am_group_t grp)
  {
    call Ieee154PacketLayer.setDestPan(msg, grp);
  }

  command error_t ActiveMessageConfig.checkFrame(message_t* msg)
  {
    if( ! call Ieee154PacketLayer.isDataFrame(msg) )
      call Ieee154PacketLayer.createDataFrame(msg);

    return SUCCESS;
  }

/*
//----------------- CsmaConfig -----------------

  async command bool CsmaConfig.requiresSoftwareCCA(message_t* msg)
  {
    return call Ieee154PacketLayer.isDataFrame(msg);
  }

//----------------- TrafficMonitorConfig -----------------

  async command uint16_t TrafficMonitorConfig.getBytes(message_t* msg)
  {
    // pure airtime: preable (4 bytes), SFD (1 byte), length (1 byte), payload + CRC (len bytes)

    return call CC2520Packet.payloadLength(msg) + 6;
  }

//----------------- RandomCollisionConfig -----------------

  //
  // We try to use the same values as in CC2420
  //
  // CC2420_MIN_BACKOFF = 10 jiffies = 320 microsec
  // CC2420_BACKOFF_PERIOD = 10 jiffies
  // initial backoff = 0x1F * CC2420_BACKOFF_PERIOD = 310 jiffies = 9920 microsec
  // congestion backoff = 0x7 * CC2420_BACKOFF_PERIOD = 70 jiffies = 2240 microsec
  //

#ifndef LOW_POWER_LISTENING

#ifndef CC2520_BACKOFF_MIN
#define CC2520_BACKOFF_MIN 320
#endif

  async command uint16_t RandomCollisionConfig.getMinimumBackoff()
  {
    return (uint16_t)(CC2520_BACKOFF_MIN * RADIO_ALARM_MICROSEC);
  }

#ifndef CC2520_BACKOFF_INIT
#define CC2520_BACKOFF_INIT 4960    // instead of 9920
#endif

  async command uint16_t RandomCollisionConfig.getInitialBackoff(message_t* msg)
  {
    return (uint16_t)(CC2520_BACKOFF_INIT * RADIO_ALARM_MICROSEC);
  }

#ifndef CC2520_BACKOFF_CONG
#define CC2520_BACKOFF_CONG 2240
#endif

  async command uint16_t RandomCollisionConfig.getCongestionBackoff(message_t* msg)
  {
    return (uint16_t)(CC2520_BACKOFF_CONG * RADIO_ALARM_MICROSEC);
  }

#endif

  async command uint16_t RandomCollisionConfig.getTransmitBarrier(message_t* msg)
  {
    uint16_t time;

    // TODO: maybe we should use the embedded timestamp of the message
    time = call RadioAlarm.getNow();

    // estimated response time (download the message, etc) is 5-8 bytes
    if( call Ieee154PacketLayer.requiresAckReply(msg) )
      time += (uint16_t)(32 * (-5 + 16 + 11 + 5) * RADIO_ALARM_MICROSEC);
    else
      time += (uint16_t)(32 * (-5 + 5) * RADIO_ALARM_MICROSEC);

    return time;
  }

  tasklet_async event void RadioAlarm.fired()
  {
  }

//----------------- SlottedCollisionConfig -----------------

  async command uint16_t SlottedCollisionConfig.getInitialDelay()
  {
    return 300;
  }

  async command uint8_t SlottedCollisionConfig.getScheduleExponent()
  {
    return 1 + RADIO_ALARM_MILLI_EXP;
  }

  async command uint16_t SlottedCollisionConfig.getTransmitTime(message_t* msg)
  {
    // TODO: check if the timestamp is correct
    return call PacketTimeStamp.timestamp(msg);
  }

  async command uint16_t SlottedCollisionConfig.getCollisionWindowStart(message_t* msg)
  {
    // the preamble (4 bytes), SFD (1 byte), plus two extra for safety
    return (call PacketTimeStamp.timestamp(msg)) - (uint16_t)(7 * 32 * RADIO_ALARM_MICROSEC);
  }

  async command uint16_t SlottedCollisionConfig.getCollisionWindowLength(message_t* msg)
  {
    return (uint16_t)(2 * 7 * 32 * RADIO_ALARM_MICROSEC);
  }

//----------------- Dummy -----------------

  async command void DummyConfig.nothing()
  {
  }

//----------------- LowPowerListening -----------------

#ifdef LOW_POWER_LISTENING

  command bool LowPowerListeningConfig.needsAutoAckRequest(message_t* msg)
  {
    return call Ieee154PacketLayer.getDestAddr(msg) != TOS_BCAST_ADDR;
  }

  command bool LowPowerListeningConfig.ackRequested(message_t* msg)
  {
    return call Ieee154PacketLayer.getAckRequired(msg);
  }

  command uint16_t LowPowerListeningConfig.getListenLength()
  {
    return 5;
  }

  async command uint16_t RandomCollisionConfig.getMinimumBackoff()
  {
    return (uint16_t)(320 * RADIO_ALARM_MICROSEC);
  }

  async command uint16_t RandomCollisionConfig.getInitialBackoff(message_t* msg)
  {
    return (uint16_t)(1600 * RADIO_ALARM_MICROSEC);
  }

  async command uint16_t RandomCollisionConfig.getCongestionBackoff(message_t* msg)
  {
    return (uint16_t)(3200 * RADIO_ALARM_MICROSEC);
  }

#endif
*/
}
