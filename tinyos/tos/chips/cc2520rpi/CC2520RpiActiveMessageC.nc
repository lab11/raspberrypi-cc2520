
#include <RadioConfig.h>

#ifdef IEEE154FRAMES_ENABLED
#error "You cannot use ActiveMessageC with IEEE154FRAMES_ENABLED defined"
#endif

configuration CC2520RpiActiveMessageC
{
	provides
	{
		interface SplitControl;

		interface AMSend[am_id_t id];
		interface Receive[am_id_t id];
//		interface Receive as Snoop[am_id_t id];
//		interface SendNotifier[am_id_t id];

		interface Packet;
		interface AMPacket;

		interface PacketAcknowledgements;
/*		interface LowPowerListening;
		interface PacketLink;
		interface RadioChannel;

		interface PacketField<uint8_t> as PacketLinkQuality;
		interface PacketField<uint8_t> as PacketTransmitPower;
		interface PacketField<uint8_t> as PacketRSSI;

		interface LocalTime<TRadio> as LocalTimeRadio;
		interface PacketTimeStamp<TRadio, uint32_t> as PacketTimeStampRadio;
		interface PacketTimeStamp<TMilli, uint32_t> as PacketTimeStampMilli;
*/
	}
}

implementation
{
	components CC2520RpiRadioC as RadioC;

	SplitControl = RadioC.SplitControl;

	AMSend = RadioC.AMSend;
	Receive = RadioC.Receive;
//	Snoop = RadioC.Snoop;
//	SendNotifier = RadioC;

	Packet = RadioC.PacketForActiveMessage;
	AMPacket = RadioC;


	PacketAcknowledgements = RadioC;
/*	LowPowerListening = RadioC;
	PacketLink = RadioC;
	RadioChannel = RadioC;

	PacketLinkQuality = RadioC.PacketLinkQuality;
	PacketTransmitPower = RadioC.PacketTransmitPower;
	PacketRSSI = RadioC.PacketRSSI;

	LocalTimeRadio = RadioC;
	PacketTimeStampMilli = RadioC;
	PacketTimeStampRadio = RadioC;
*/
}
