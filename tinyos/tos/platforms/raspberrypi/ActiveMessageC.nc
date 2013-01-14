
//#include <RadioConfig.h>

configuration ActiveMessageC
{
  provides
  {
    interface SplitControl;

    interface AMSend[uint8_t id];
    interface Receive[uint8_t id];
 //   interface Receive as Snoop[uint8_t id];
// not sure if sendnotifier is needed
//    interface SendNotifier[am_id_t id];

    interface Packet;
    interface AMPacket;

    interface PacketAcknowledgements;
 //   interface LowPowerListening;

    // not required (aka telosa + cc2420 driver doesnt have them)
 //   interface PacketLink;
 //   interface RadioChannel;

 //   interface PacketTimeStamp<TMicro, uint32_t> as PacketTimeStampMicro;
 //   interface PacketTimeStamp<TMilli, uint32_t> as PacketTimeStampMilli;
  }
}

implementation
{
  components CC2520RpiActiveMessageC as MessageC;

//  components RadioControlP, HplSam3TCC;

  SplitControl = MessageC.SplitControl;
  //SplitControl = RadioControlP;
  //RadioControlP.LowRadioControl -> MessageC;
  //RadioControlP.TC -> HplSam3TCC.TC0; // We use TIOA1 which is channel 1 on TC0

  AMSend  = MessageC.AMSend;
  Receive = MessageC.Receive;
  // not doing snoop right now
 // Snoop   = MessageC.Snoop;
  //SendNotifier = MessageC;

  Packet   = MessageC.Packet;
  AMPacket = MessageC.AMPacket;


  PacketAcknowledgements = MessageC.PacketAcknowledgements;
/*  LowPowerListening      = MessageC.LowPowerListening;
  PacketLink             = MessageC.PacketLink;
  RadioChannel           = MessageC.RadioChannel;

  PacketTimeStampMilli = MessageC.PacketTimeStampMilli;
  PacketTimeStampMicro = MessageC.PacketTimeStampRadio;
*/
}
