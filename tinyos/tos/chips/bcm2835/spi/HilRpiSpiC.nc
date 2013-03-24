

//#include <sam3spihardware.h>

configuration HilRpiSpiC
{
    provides
    {
        interface Resource[uint8_t];
        interface SpiByte[uint8_t];
//        interface FastSpiByte[uint8_t];
        interface SpiPacket[uint8_t];
        interface HplSam3SpiChipSelConfig[uint8_t];
        interface HplSam3SpiConfig;
    }
    uses {
        interface Init as SpiChipInit;
        interface ResourceConfigure[uint8_t];
    }
}
implementation
{
    components RealMainP;
    RealMainP.PlatformInit -> HilRpiSpiP.Init;

    components HplRpiSpiC;
    HplRpiSpiConfig = HplRpiSpiC;
    HilRpiSpiP.SpiChipInit = SpiChipInit;
    HilRpiSpiP.HplRpiSpiConfig     -> HplRpiSpiC;
    HilRpiSpiP.HplRpiSpiControl    -> HplRpiSpiC;
    HilRpiSpiP.HplRpiSpiStatus     -> HplRpiSpiC;
    HilRpiSpiP.HplRpiSpiInterrupts -> HplRpiSpiC;
    HplRpiSpiChipSelConfig[0] =  HplRpiSpiC.HplSam3SpiChipSelConfig0;
    HplRpiSpiChipSelConfig[1] =  HplRpiSpiC.HplSam3SpiChipSelConfig1;
//    HplRpiSpiChipSelConfig[2] =  HplRpiSpiC.HplSam3SpiChipSelConfig2;
//    HplRpiSpiChipSelConfig[3] =  HplRpiSpiC.HplSam3SpiChipSelConfig3;

    components new FcfsArbiterC(RPI_SPI_BUS) as ArbiterC;
    Resource = ArbiterC;
    ResourceConfigure = ArbiterC;
    HilRpiSpiP.ArbiterInfo -> ArbiterC;

    components new AsyncStdControlPowerManagerC() as PM;
    PM.AsyncStdControl -> HplRpiSpiC;
    PM.ArbiterInfo -> ArbiterC.ArbiterInfo;
    PM.ResourceDefaultOwner -> ArbiterC.ResourceDefaultOwner;

    components HilRpiSpiP;
    SpiByte = HilRpiSpiP.SpiByte;
    SpiPacket = HilRpiSpiP.SpiPacket;

//    components new FastSpiSam3C(SAM3_SPI_BUS);
//    FastSpiSam3C.SpiByte -> HilRpiSpiP.SpiByte;
//    FastSpiByte = FastSpiSam3C;

//    components HplSam3sGeneralIOC;
//    HilRpiSpiP.SpiPinMiso -> HplSam3sGeneralIOC.HplPioA12;
//    HilRpiSpiP.SpiPinMosi -> HplSam3sGeneralIOC.HplPioA13;
//    HilRpiSpiP.SpiPinSpck -> HplSam3sGeneralIOC.HplPioA14;

    components HplNVICC;
    HilRpiSpiP.SpiIrqControl -> HplNVICC.SPIInterrupt;
}
