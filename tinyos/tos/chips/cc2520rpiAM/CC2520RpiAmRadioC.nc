/*
 * Copyright (c) 2010, Vanderbilt University
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holder nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
 * COPYRIGHT HOLDER OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
 *
 * Author: Miklos Maroti, Janos Sallai
 * Author: Thomas Schmid (adapted to CC2520)
 */

#include <RadioConfig.h>

//#define TFRAMES_ENABLED 1

configuration CC2520RpiAmRadioC {
  provides {
    interface SplitControl;

    interface AMSend[am_id_t id];
    interface Receive[am_id_t id];
//    interface Receive as Snoop[am_id_t id];
 //   interface SendNotifier[am_id_t id];

    // for TOSThreads
  //  interface Receive as ReceiveDefault[am_id_t id];
  //  interface Receive as SnoopDefault[am_id_t id];

    interface AMPacket;
    interface Packet as PacketForActiveMessage;



    interface PacketAcknowledgements;
 //   interface LowPowerListening;
    interface PacketLink;
/*
//#ifdef TRAFFIC_MONITOR
//    interface TrafficMonitor;
//#endif

    interface RadioChannel;
*/
    interface PacketField<uint8_t> as PacketLinkQuality;
 //   interface PacketField<uint8_t> as PacketTransmitPower;
    interface PacketField<uint8_t> as PacketRSSI;

 //   interface LocalTime<TRadio> as LocalTimeRadio;
 //   interface PacketTimeStamp<TRadio, uint32_t> as PacketTimeStampRadio;
 //   interface PacketTimeStamp<TMilli, uint32_t> as PacketTimeStampMilli;

   // interface RadioAddress;
  }
}

implementation
{
#define UQ_METADATA_FLAGS "UQ_CC2520_METADATA_FLAGS"
#define UQ_RADIO_ALARM    "UQ_CC2520_RADIO_ALARM"


// -------- RadioP

  components CC2520RpiAmRadioP as AmRadioP;
  components CC2520RpiRadioP as RadioP;
  components CC2520RpiReceiveC;
  components CC2520RpiSendC;
  components CC2520RpiAmPacketC;
  components CC2520RpiAmPacketMetadataC;

  // dummy wiring
  AmRadioP.Send -> RadioP.Send;
  AmRadioP.Receive -> RadioP.Receive;

  components LocalIeeeEui64C;
  RadioP.LocalIeeeEui64 -> LocalIeeeEui64C.LocalIeeeEui64;

  PacketAcknowledgements = AmRadioP.PacketAcknowledgements;

  SplitControl = RadioP.SplitControl;

 // RadioAddress = RadioP.RadioAddress;

  PacketLinkQuality = AmRadioP.PacketLinkQuality;
  PacketRSSI = AmRadioP.PacketRSSI;

  AmRadioP.PacketMetadata -> RadioP.PacketMetadata;


//#ifdef RADIO_DEBUG
//  components AssertC;
//#endif

  AmRadioP.Ieee154PacketLayer -> Ieee154PacketLayerC;
 // RadioP.RadioAlarm -> RadioAlarmC.RadioAlarm[unique(UQ_RADIO_ALARM)];
 // RadioP.PacketTimeStamp -> TimeStampingLayerC;
 // RadioP.CC2520Packet -> RadioDriverLayerC;

// -------- RadioAlarm

 // components new RadioAlarmC();
 // RadioAlarmC.Alarm -> RadioDriverLayerC;

// -------- Active Message

  components new ActiveMessageLayerC();
  ActiveMessageLayerC.Config -> AmRadioP;
      // ActiveMessageLayerC.SubSend -> CC2520RpiSendC.BareSend;
  ActiveMessageLayerC.SubSend -> TinyosNetworkLayerC.TinyosSend;
 // ActiveMessageLayerC.SubReceive -> CC2520RpiReceiveC.BareReceive;
 // ActiveMessageLayerC.SubPacket -> TinyosNetworkLayerC.TinyosPacket;
 // ActiveMessageLayerC.SubSend -> AutoResourceAcquireLayerC;
  ActiveMessageLayerC.SubReceive -> TinyosNetworkLayerC.TinyosReceive;
  ActiveMessageLayerC.SubPacket -> TinyosNetworkLayerC.TinyosPacket;

  AMSend = ActiveMessageLayerC;
  Receive = ActiveMessageLayerC.Receive;
 // Snoop = ActiveMessageLayerC.Snoop;
 // SendNotifier = ActiveMessageLayerC;
  AMPacket = ActiveMessageLayerC;
  PacketForActiveMessage = ActiveMessageLayerC;

 // ReceiveDefault = ActiveMessageLayerC.ReceiveDefault;
 // SnoopDefault = ActiveMessageLayerC.SnoopDefault;
/*
// -------- Automatic RadioSend Resource

#ifndef IEEE154FRAMES_ENABLED
#ifndef TFRAMES_ENABLED
  components new AutoResourceAcquireLayerC();
  AutoResourceAcquireLayerC.Resource -> SendResourceC.Resource[unique(RADIO_SEND_RESOURCE)];
#else
  components new DummyLayerC() as AutoResourceAcquireLayerC;
#endif
  AutoResourceAcquireLayerC -> TinyosNetworkLayerC.TinyosSend;
#endif

// -------- RadioSend Resource
*/


// -------- Tinyos Network

  components new TinyosNetworkLayerC();
  components CC2520RpiAmUniqueC;
  components CC2520RpiAm154DummyP;

 // TinyosNetworkLayerC.SubSend -> UniqueLayerC;
 // TinyosNetworkLayerC.SubSend -> CC2520RpiSendC.BareSend;
  TinyosNetworkLayerC.SubSend -> CC2520RpiAmUniqueC.Send;
  CC2520RpiAmUniqueC.SubSend -> PacketLinkLayerC.Send;
//  TinyosNetworkLayerC.SubSend -> PacketLinkLayerC.Send;
  TinyosNetworkLayerC.SubReceive -> PacketLinkLayerC;
 // TinyosNetworkLayerC.SubReceive -> CC2520RpiReceiveC;
  TinyosNetworkLayerC.SubPacket -> Ieee154PacketLayerC.RadioPacket;

  CC2520RpiAm154DummyP.Ieee154Send -> TinyosNetworkLayerC.Ieee154Send;
  CC2520RpiAm154DummyP.Ieee154Receive -> TinyosNetworkLayerC.Ieee154Receive;

// -------- IEEE 802.15.4 Packet

  components new Ieee154PacketLayerC();
  Ieee154PacketLayerC.SubPacket -> PacketLinkLayerC;
 // Ieee154PacketLayerC.SubPacket -> CC2520RpiPacketC.RadioPacket;
/*
// -------- UniqueLayer Send part (wired twice)

  components new UniqueLayerC();
  UniqueLayerC.Config -> RadioP;
  UniqueLayerC.SubSend -> PacketLinkLayerC;
*/
// -------- Packet Link

  components new PacketLinkLayerC();
  PacketLink = PacketLinkLayerC;
//#ifdef CC2520_HARDWARE_ACK
//  PacketLinkLayerC.PacketAcknowledgements -> RadioDriverLayerC;
//#else
//  PacketLinkLayerC.PacketAcknowledgements -> SoftwareAckLayerC;
//#endif
  PacketLinkLayerC.SubSend -> CC2520RpiSendC.BareSend;
  PacketLinkLayerC.SubReceive -> CC2520RpiReceiveC.BareReceive;
  PacketLinkLayerC.SubPacket -> CC2520RpiAmPacketC.RadioPacket;
  PacketLinkLayerC.PacketAcknowledgements -> AmRadioP.PacketAcknowledgements;
 // PacketLinkLayerC -> LowPowerListeningLayerC.Send;
 // PacketLinkLayerC -> LowPowerListeningLayerC.Receive;
 // PacketLinkLayerC -> LowPowerListeningLayerC.RadioPacket;
/*
// -------- Low Power Listening

#ifdef LOW_POWER_LISTENING
  #warning "*** USING LOW POWER LISTENING LAYER"
  components new LowPowerListeningLayerC();
  LowPowerListeningLayerC.Config -> RadioP;
#ifdef CC2520_HARDWARE_ACK
  LowPowerListeningLayerC.PacketAcknowledgements -> RadioDriverLayerC;
#else
  LowPowerListeningLayerC.PacketAcknowledgements -> SoftwareAckLayerC;
#endif
#else
  components new LowPowerListeningDummyC() as LowPowerListeningLayerC;
#endif
  LowPowerListeningLayerC.SubControl -> MessageBufferLayerC;
  LowPowerListeningLayerC.SubSend -> MessageBufferLayerC;
  LowPowerListeningLayerC.SubReceive -> MessageBufferLayerC;
  LowPowerListeningLayerC.SubPacket -> TimeStampingLayerC;
  SplitControl = LowPowerListeningLayerC;
  LowPowerListening = LowPowerListeningLayerC;

// -------- MessageBuffer

  components new MessageBufferLayerC();
  MessageBufferLayerC.RadioSend -> CollisionAvoidanceLayerC;
  MessageBufferLayerC.RadioReceive -> UniqueLayerC;
  MessageBufferLayerC.RadioState -> TrafficMonitorLayerC;
  RadioChannel = MessageBufferLayerC;

// -------- UniqueLayer receive part (wired twice)

  UniqueLayerC.SubReceive -> CollisionAvoidanceLayerC;

// -------- CollisionAvoidance

#ifdef SLOTTED_MAC
  components new SlottedCollisionLayerC() as CollisionAvoidanceLayerC;
#else
  components new RandomCollisionLayerC() as CollisionAvoidanceLayerC;
#endif
  CollisionAvoidanceLayerC.Config -> RadioP;
  CollisionAvoidanceLayerC.SubSend -> SoftwareAckLayerC;
  CollisionAvoidanceLayerC.SubReceive -> SoftwareAckLayerC;
  CollisionAvoidanceLayerC.RadioAlarm -> RadioAlarmC.RadioAlarm[unique(UQ_RADIO_ALARM)];

// -------- SoftwareAcknowledgement

#ifndef CC2520_HARDWARE_ACK
  components new SoftwareAckLayerC();
  SoftwareAckLayerC.AckReceivedFlag -> MetadataFlagsLayerC.PacketFlag[unique(UQ_METADATA_FLAGS)];
  SoftwareAckLayerC.RadioAlarm -> RadioAlarmC.RadioAlarm[unique(UQ_RADIO_ALARM)];
  PacketAcknowledgements = SoftwareAckLayerC;
#else
  components new DummyLayerC() as SoftwareAckLayerC;
#endif
  SoftwareAckLayerC.Config -> RadioP;
  SoftwareAckLayerC.SubSend -> CsmaLayerC;
  SoftwareAckLayerC.SubReceive -> CsmaLayerC;

// -------- Carrier Sense

  components new DummyLayerC() as CsmaLayerC;
  CsmaLayerC.Config -> RadioP;
  CsmaLayerC -> TrafficMonitorLayerC.RadioSend;
  CsmaLayerC -> TrafficMonitorLayerC.RadioReceive;
  CsmaLayerC -> RadioDriverLayerC.RadioCCA;

// -------- TimeStamping

  components new TimeStampingLayerC();
  TimeStampingLayerC.LocalTimeRadio -> RadioDriverLayerC;
  TimeStampingLayerC.SubPacket -> MetadataFlagsLayerC;
  PacketTimeStampRadio = TimeStampingLayerC;
  PacketTimeStampMilli = TimeStampingLayerC;
  TimeStampingLayerC.TimeStampFlag -> MetadataFlagsLayerC.PacketFlag[unique(UQ_METADATA_FLAGS)];

// -------- MetadataFlags

  components new MetadataFlagsLayerC();
  MetadataFlagsLayerC.SubPacket -> RadioDriverLayerC;

// -------- Traffic Monitor

#ifdef TRAFFIC_MONITOR
  components new TrafficMonitorLayerC();
  TrafficMonitor = TrafficMonitorLayerC;
#else
  components new DummyLayerC() as TrafficMonitorLayerC;
#endif
  TrafficMonitorLayerC.Config -> RadioP;
  TrafficMonitorLayerC -> RadioDriverLayerC.RadioSend;
  TrafficMonitorLayerC -> RadioDriverLayerC.RadioReceive;
  TrafficMonitorLayerC -> RadioDriverLayerC.RadioState;

// -------- Driver

#ifdef CC2520_HARDWARE_ACK
  components CC2520DriverLayerC as RadioDriverLayerC;
  PacketAcknowledgements = RadioDriverLayerC;
  RadioDriverLayerC.Ieee154PacketLayer -> Ieee154PacketLayerC;
  RadioDriverLayerC.AckReceivedFlag -> MetadataFlagsLayerC.PacketFlag[unique(UQ_METADATA_FLAGS)];
#else
  components CC2520DriverLayerC as RadioDriverLayerC;
#endif
  RadioDriverLayerC.Config -> RadioP;
  RadioDriverLayerC.PacketTimeStamp -> TimeStampingLayerC;
  PacketTransmitPower = RadioDriverLayerC.PacketTransmitPower;
  PacketLinkQuality = RadioDriverLayerC.PacketLinkQuality;
  PacketRSSI = RadioDriverLayerC.PacketRSSI;
  LocalTimeRadio = RadioDriverLayerC;

  RadioDriverLayerC.TransmitPowerFlag -> MetadataFlagsLayerC.PacketFlag[unique(UQ_METADATA_FLAGS)];
  RadioDriverLayerC.RSSIFlag -> MetadataFlagsLayerC.PacketFlag[unique(UQ_METADATA_FLAGS)];
  RadioDriverLayerC.TimeSyncFlag -> MetadataFlagsLayerC.PacketFlag[unique(UQ_METADATA_FLAGS)];
  RadioDriverLayerC.RadioAlarm -> RadioAlarmC.RadioAlarm[unique(UQ_RADIO_ALARM)];
*/
}
